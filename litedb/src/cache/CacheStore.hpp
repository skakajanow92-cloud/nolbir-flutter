#pragma once
#include <cstddef>
#include <functional>
#include <list>
#include <mutex>
#include <optional>
#include <string>
#include <unordered_map>

namespace litedb {

struct CacheOptions {
  size_t maxEntries = 10000;  // 0 = sinirsiz
  size_t maxBytes = 0;        // anahtar+deger boyutlarinin toplami; 0 = sinirsiz
};

// Redis benzeri, tamamen bellek ici onbellek: LRU tahliye + TTL.
// SQLite kullanmaz ve Transaction'lara katilmaz (geri alinmaz, kalici degildir).
// Thread-safe'tir (ic mutex).
//
// TTL "tembel" islenir: suresi dolan girdi erisildiginde silinir. Hic
// erisilmeyenleri temizlemek icin purgeExpired()'i periyodik cagir.
class CacheStore {
 public:
  using Clock = std::function<long long()>;  // milisaniye dondurur

  struct Stats {
    size_t entries;  // suresi dolmus ama henuz temizlenmemisler dahil
    size_t bytes;
    long long hits, misses, evictions, expired;
  };

  // clock: test icin sahte saat verilebilir; bos ise steady_clock (ms) kullanilir.
  explicit CacheStore(CacheOptions options = {}, Clock clock = nullptr);

  // ttlMs <= 0 -> suresiz. Tek basina maxBytes'tan buyuk girdi saklanmaz
  // (false doner, varsa eski degeri silinir).
  bool set(const std::string& key, const std::string& value, long long ttlMs = 0);

  std::optional<std::string> get(const std::string& key);  // LRU'yu gunceller
  bool del(const std::string& key);
  bool exists(const std::string& key);  // LRU'yu guncellemez

  // ttlMs > 0: sureyi ayarlar; ttlMs == 0: sureyi kaldirir. Anahtar yoksa false.
  bool expire(const std::string& key, long long ttlMs);
  // Kalan sure (ms); -1 = suresiz; -2 = anahtar yok.
  long long ttl(const std::string& key);

  // Sayac: deger tam sayi olmali (yoksa 0'dan baslar, suresiz). TTL korunur.
  // Tam sayi degilse std::invalid_argument, tasmada std::overflow_error.
  long long incr(const std::string& key, long long delta = 1);

  size_t purgeExpired();  // temizlenen girdi sayisi
  void clear();
  size_t size();
  Stats stats();

 private:
  struct Entry {
    std::string key, value;
    long long expiresAt;  // 0 = suresiz
  };
  using List = std::list<Entry>;
  using Map = std::unordered_map<std::string, List::iterator>;

  static size_t sizeOf(const Entry& e) { return e.key.size() + e.value.size(); }
  bool expired(const Entry& e, long long now) const {
    return e.expiresAt != 0 && now >= e.expiresAt;
  }
  void eraseIt(Map::iterator it);
  Map::iterator findLive(const std::string& key, long long now);
  void evictIfNeeded();

  CacheOptions opt_;
  Clock clock_;
  std::mutex mu_;
  List lru_;  // on = en yeni kullanilan
  Map map_;
  size_t bytes_ = 0;
  long long hits_ = 0, misses_ = 0, evictions_ = 0, expiredCount_ = 0;
};

}  // namespace litedb
