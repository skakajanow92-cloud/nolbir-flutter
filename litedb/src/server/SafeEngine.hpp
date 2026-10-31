#pragma once
// SafeEngine: litedb::Engine'i cok thread'li bir sunucuda guvenle kullanmak icin
// hafif sarmalayici.
//
//  * YAZMA: tek bir yazici thread. write(f) gorevi kuyruga koyar ve commit
//    edilene kadar bekler. Yazici, kuyrukta biriken gorevleri TEK transaction
//    icinde toplu calistirir (grup commit). Her gorev kendi SAVEPOINT'indedir:
//    biri hata verirse yalniz o geri alinir, digerleri etkilenmez. Boylece
//    N esamanli yazma icin N yerine ~1 commit (ve durable modda ~1 fsync) olur.
//  * OKUMA: n adet ayri (WAL, query_only) baglanti havuzu. Okumalar yaziciyi
//    ve birbirini engellemez. Bir write() dondukten sonra baslayan her read()
//    o yazmayi gorur.
//  * cache(): zaten thread-safe; yazici kuyruguna girmez (SQLite'tan bagimsiz).
//
// Kurallar: write() icinde Engine::transaction() kullanma (yazici zaten
// transaction acmistir); write() icinden write() cagirma (kilitlenir, algilanir).
// Gorev icinde cache'e yazma geri alinmaz.
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <deque>
#include <exception>
#include <functional>
#include <future>
#include <memory>
#include <mutex>
#include <optional>
#include <stdexcept>
#include <string>
#include <thread>
#include <type_traits>
#include <vector>

#include "Engine.hpp"

namespace litedb {

namespace detail {
template <class R>
struct Slot {
  std::promise<R> p;
  std::optional<R> v;
};
template <>
struct Slot<void> {
  std::promise<void> p;
};
}  // namespace detail

struct SafeEngineOptions {
  std::string path;             // dosya yolu (":memory:" desteklenmez)
  size_t readers = 4;           // okuma baglantisi sayisi (>= 1)
  size_t maxBatch = 512;        // bir commit'te en fazla gorev
  size_t maxQueue = 20000;      // dolunca write() QueueFullError firlatir
  int lingerMicros = 0;         // ilk gorevden sonra ek toplanma bekleme suresi
  bool durable = false;         // true: synchronous=FULL (commit basina fsync)
  CacheOptions cache;
};

class QueueFullError : public std::runtime_error {
 public:
  QueueFullError() : std::runtime_error("yazma kuyrugu dolu") {}
};
class ShuttingDownError : public std::runtime_error {
 public:
  ShuttingDownError() : std::runtime_error("kapaniyor") {}
};

class SafeEngine {
 public:
  struct Stats {
    uint64_t batches = 0;     // yapilan commit sayisi
    uint64_t ops = 0;         // islenen yazma gorevi
    uint64_t failed = 0;      // hata veren gorev
    uint64_t maxBatch = 0;    // gorulen en buyuk toplu is
    uint64_t queued = 0;      // su an kuyrukta bekleyen
    size_t readers = 0;
    size_t readersBusy = 0;
    double avgBatch() const { return batches ? double(ops) / batches : 0.0; }
  };

  explicit SafeEngine(SafeEngineOptions opt)
      : opt_(std::move(opt)), primary_(checked(opt_), opt_.cache) {
    if (opt_.durable) primary_.db().exec("PRAGMA synchronous=FULL");
    // Sema yazici baglantida olustu; okuyucular sonra acilir.
    CacheOptions tiny;
    tiny.maxEntries = 1;
    for (size_t i = 0; i < opt_.readers; ++i) {
      readers_.push_back(std::make_unique<Engine>(opt_.path, tiny));
      readers_.back()->db().exec("PRAGMA query_only=ON");
      free_.push_back(i);
    }
    writer_ = std::thread([this] { writerLoop(); });
    writerId_ = writer_.get_id();
  }

  ~SafeEngine() {
    {
      std::lock_guard<std::mutex> lk(mu_);
      stop_ = true;
    }
    cv_.notify_all();
    if (writer_.joinable()) writer_.join();  // kuyruk bosalana kadar calisir
  }

  SafeEngine(const SafeEngine&) = delete;
  SafeEngine& operator=(const SafeEngine&) = delete;

  CacheStore& cache() { return primary_.cache; }

  // f(Engine&) yazici thread'de, toplu transaction icinde calisir; commit
  // edildikten sonra sonucu doner. f'in firlattigi istisna cagirana iletilir
  // ve yalniz f'in degisiklikleri geri alinir.
  template <class F>
  auto write(F&& f) -> std::invoke_result_t<F&, Engine&> {
    using R = std::invoke_result_t<F&, Engine&>;
    if (std::this_thread::get_id() == writerId_)
      throw std::logic_error("write() yazici thread'den cagrilamaz");
    auto slot = std::make_shared<Slot<R>>();
    auto fut = slot->p.get_future();
    Task t;
    t.run = [slot, fn = std::forward<F>(f)](Engine& e) mutable {
      if constexpr (std::is_void_v<R>) {
        fn(e);
      } else {
        slot->v.emplace(fn(e));
      }
    };
    t.finish = [slot](std::exception_ptr ep) {
      if (ep) {
        slot->p.set_exception(ep);
      } else {
        if constexpr (std::is_void_v<R>) {
          slot->p.set_value();
        } else {
          slot->p.set_value(std::move(*slot->v));
        }
      }
    };
    enqueue(std::move(t));
    return fut.get();
  }

  // f(Engine&) bir okuma baglantisinda calisir. Engine'in cache'ini kullanma;
  // cache() kullan.
  template <class F>
  auto read(F&& f) -> std::invoke_result_t<F&, Engine&> {
    Lease lease(*this);
    try {
      return f(lease.engine());
    } catch (...) {
      lease.poison();
      throw;
    }
  }

  Stats stats() {
    Stats s;
    s.batches = batches_.load();
    s.ops = ops_.load();
    s.failed = failed_.load();
    s.maxBatch = maxBatchSeen_.load();
    {
      std::lock_guard<std::mutex> lk(mu_);
      s.queued = queue_.size();
    }
    {
      std::lock_guard<std::mutex> lk(poolMu_);
      s.readers = readers_.size();
      s.readersBusy = readers_.size() - free_.size();
    }
    return s;
  }

 private:
  template <class R>
  using Slot = detail::Slot<R>;

  struct Task {
    std::function<void(Engine&)> run;
    std::function<void(std::exception_ptr)> finish;
  };

  static const std::string& checked(const SafeEngineOptions& o) {
    if (o.path.empty() || o.path == ":memory:" ||
        o.path.rfind("file::memory:", 0) == 0)
      throw std::invalid_argument(
          "SafeEngine bellek ici veritabanini desteklemez (dosya yolu ver)");
    if (o.readers == 0) throw std::invalid_argument("readers >= 1 olmali");
    if (o.maxBatch == 0) throw std::invalid_argument("maxBatch >= 1 olmali");
    return o.path;
  }

  // ---- Okuyucu havuzu ----
  class Lease {
   public:
    explicit Lease(SafeEngine& s) : s_(s) {
      std::unique_lock<std::mutex> lk(s_.poolMu_);
      s_.poolCv_.wait(lk, [&] { return !s_.free_.empty(); });
      idx_ = s_.free_.back();
      s_.free_.pop_back();
    }
    ~Lease() {
      if (poisoned_) {
        // Yarim kalmis bir sorgu acik okuma anlik goruntusunu (snapshot) tutar
        // ve sonraki okumalarin eski veri gormesine yol acar; hepsini sifirla.
        sqlite3* db = s_.readers_[idx_]->db().raw();
        for (sqlite3_stmt* st = nullptr; (st = sqlite3_next_stmt(db, st));)
          sqlite3_reset(st);
      }
      {
        std::lock_guard<std::mutex> lk(s_.poolMu_);
        s_.free_.push_back(idx_);
      }
      s_.poolCv_.notify_one();
    }
    Engine& engine() { return *s_.readers_[idx_]; }
    void poison() { poisoned_ = true; }

   private:
    SafeEngine& s_;
    size_t idx_ = 0;
    bool poisoned_ = false;
  };

  // ---- Yazici ----
  void enqueue(Task t) {
    {
      std::lock_guard<std::mutex> lk(mu_);
      if (stop_) throw ShuttingDownError();
      if (queue_.size() >= opt_.maxQueue) throw QueueFullError();
      queue_.push_back(std::move(t));
    }
    cv_.notify_one();
  }

  void writerLoop() {
    std::vector<Task> batch;
    batch.reserve(opt_.maxBatch);
    for (;;) {
      {
        std::unique_lock<std::mutex> lk(mu_);
        cv_.wait(lk, [&] { return stop_ || !queue_.empty(); });
        if (queue_.empty()) break;  // stop_ && bos
        if (opt_.lingerMicros > 0 && !stop_ && queue_.size() < opt_.maxBatch) {
          cv_.wait_for(lk, std::chrono::microseconds(opt_.lingerMicros),
                       [&] { return stop_ || queue_.size() >= opt_.maxBatch; });
        }
        size_t n = std::min(queue_.size(), opt_.maxBatch);
        for (size_t k = 0; k < n; ++k) {
          batch.push_back(std::move(queue_.front()));
          queue_.pop_front();
        }
      }
      runBatch(batch);
      batch.clear();
    }
  }

  void runBatch(std::vector<Task>& batch) {
    Database& db = primary_.db();
    std::vector<std::exception_ptr> errs(batch.size());
    std::exception_ptr fatal;
    bool txOpen = false;
    try {
      db.exec("BEGIN IMMEDIATE");
      txOpen = true;
      for (size_t i = 0; i < batch.size(); ++i) {
        db.exec("SAVEPOINT w");
        try {
          batch[i].run(primary_);
          db.exec("RELEASE w");
        } catch (...) {
          errs[i] = std::current_exception();
          // Bu da basarisiz olursa (ornegin SQLite tum transaction'i geri
          // aldiysa) disaridaki catch tum batch'i basarisiz sayar.
          db.exec("ROLLBACK TO w; RELEASE w");
        }
      }
      db.exec("COMMIT");
      txOpen = false;
    } catch (...) {
      fatal = std::current_exception();
      if (txOpen) {
        try {
          db.exec("ROLLBACK");
        } catch (...) {
        }
      }
    }

    uint64_t failed = 0;
    for (size_t i = 0; i < batch.size(); ++i) {
      std::exception_ptr ep = fatal ? fatal : errs[i];
      if (ep) ++failed;
      try {
        batch[i].finish(ep);
      } catch (...) {
      }
    }
    batches_.fetch_add(1, std::memory_order_relaxed);
    ops_.fetch_add(batch.size(), std::memory_order_relaxed);
    failed_.fetch_add(failed, std::memory_order_relaxed);
    uint64_t cur = maxBatchSeen_.load(std::memory_order_relaxed);
    while (batch.size() > cur &&
           !maxBatchSeen_.compare_exchange_weak(cur, batch.size())) {
    }
  }

  SafeEngineOptions opt_;
  Engine primary_;  // yalniz yazici thread kullanir (cache haric)

  std::mutex poolMu_;
  std::condition_variable poolCv_;
  std::vector<std::unique_ptr<Engine>> readers_;
  std::vector<size_t> free_;

  std::mutex mu_;
  std::condition_variable cv_;
  std::deque<Task> queue_;
  bool stop_ = false;

  std::atomic<uint64_t> batches_{0}, ops_{0}, failed_{0}, maxBatchSeen_{0};
  std::thread writer_;
  std::thread::id writerId_;
};

}  // namespace litedb
