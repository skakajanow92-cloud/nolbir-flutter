#include "cache/CacheStore.hpp"

#include <charconv>
#include <chrono>
#include <climits>
#include <iterator>
#include <stdexcept>

namespace litedb {

namespace {
long long steadyMs() {
  using namespace std::chrono;
  return duration_cast<milliseconds>(steady_clock::now().time_since_epoch()).count();
}
}  // namespace

CacheStore::CacheStore(CacheOptions options, Clock clock)
    : opt_(options), clock_(clock ? std::move(clock) : Clock(steadyMs)) {}

void CacheStore::eraseIt(Map::iterator it) {
  bytes_ -= sizeOf(*it->second);
  lru_.erase(it->second);
  map_.erase(it);
}

CacheStore::Map::iterator CacheStore::findLive(const std::string& key,
                                               long long now) {
  auto it = map_.find(key);
  if (it == map_.end()) return it;
  if (expired(*it->second, now)) {
    eraseIt(it);
    ++expiredCount_;
    return map_.end();
  }
  return it;
}

void CacheStore::evictIfNeeded() {
  while (!lru_.empty() &&
         ((opt_.maxEntries && lru_.size() > opt_.maxEntries) ||
          (opt_.maxBytes && bytes_ > opt_.maxBytes))) {
    eraseIt(map_.find(lru_.back().key));
    ++evictions_;
  }
}

bool CacheStore::set(const std::string& key, const std::string& value,
                     long long ttlMs) {
  std::lock_guard<std::mutex> lk(mu_);
  long long now = clock_();
  auto it = map_.find(key);
  if (it != map_.end()) eraseIt(it);

  size_t sz = key.size() + value.size();
  if (opt_.maxBytes && sz > opt_.maxBytes) return false;

  lru_.push_front({key, value, ttlMs > 0 ? now + ttlMs : 0});
  map_[key] = lru_.begin();
  bytes_ += sz;
  evictIfNeeded();
  return true;
}

std::optional<std::string> CacheStore::get(const std::string& key) {
  std::lock_guard<std::mutex> lk(mu_);
  auto it = findLive(key, clock_());
  if (it == map_.end()) {
    ++misses_;
    return std::nullopt;
  }
  lru_.splice(lru_.begin(), lru_, it->second);  // en one tasi
  ++hits_;
  return it->second->value;
}

bool CacheStore::del(const std::string& key) {
  std::lock_guard<std::mutex> lk(mu_);
  auto it = findLive(key, clock_());
  if (it == map_.end()) return false;
  eraseIt(it);
  return true;
}

bool CacheStore::exists(const std::string& key) {
  std::lock_guard<std::mutex> lk(mu_);
  return findLive(key, clock_()) != map_.end();
}

bool CacheStore::expire(const std::string& key, long long ttlMs) {
  std::lock_guard<std::mutex> lk(mu_);
  long long now = clock_();
  auto it = findLive(key, now);
  if (it == map_.end()) return false;
  it->second->expiresAt = ttlMs > 0 ? now + ttlMs : 0;
  return true;
}

long long CacheStore::ttl(const std::string& key) {
  std::lock_guard<std::mutex> lk(mu_);
  long long now = clock_();
  auto it = findLive(key, now);
  if (it == map_.end()) return -2;
  if (it->second->expiresAt == 0) return -1;
  return it->second->expiresAt - now;
}

long long CacheStore::incr(const std::string& key, long long delta) {
  std::lock_guard<std::mutex> lk(mu_);
  auto it = findLive(key, clock_());

  long long cur = 0;
  if (it != map_.end()) {
    const std::string& v = it->second->value;
    auto res = std::from_chars(v.data(), v.data() + v.size(), cur);
    if (res.ec != std::errc{} || res.ptr != v.data() + v.size())
      throw std::invalid_argument("deger tam sayi degil: " + key);
  }
  if ((delta > 0 && cur > LLONG_MAX - delta) ||
      (delta < 0 && cur < LLONG_MIN - delta))
    throw std::overflow_error("incr tasmasi: " + key);

  long long next = cur + delta;
  std::string nv = std::to_string(next);
  if (it != map_.end()) {
    bytes_ = bytes_ - it->second->value.size() + nv.size();
    it->second->value = nv;
    lru_.splice(lru_.begin(), lru_, it->second);
  } else {
    lru_.push_front({key, nv, 0});
    map_[key] = lru_.begin();
    bytes_ += key.size() + nv.size();
  }
  evictIfNeeded();
  return next;
}

size_t CacheStore::purgeExpired() {
  std::lock_guard<std::mutex> lk(mu_);
  long long now = clock_();
  size_t n = 0;
  for (auto li = lru_.begin(); li != lru_.end();) {
    if (expired(*li, now)) {
      auto next = std::next(li);
      eraseIt(map_.find(li->key));
      li = next;
      ++n;
      ++expiredCount_;
    } else {
      ++li;
    }
  }
  return n;
}

void CacheStore::clear() {
  std::lock_guard<std::mutex> lk(mu_);
  lru_.clear();
  map_.clear();
  bytes_ = 0;
}

size_t CacheStore::size() {
  std::lock_guard<std::mutex> lk(mu_);
  return lru_.size();
}

CacheStore::Stats CacheStore::stats() {
  std::lock_guard<std::mutex> lk(mu_);
  return {lru_.size(), bytes_, hits_, misses_, evictions_, expiredCount_};
}

}  // namespace litedb
