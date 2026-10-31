// Yazma verimi karsilastirmasi.
//   naif  : tum thread'ler tek Engine'i bir mutex ile paylasir, her yazma kendi
//           transaction'inda (BEGIN IMMEDIATE ... COMMIT) -- "sadece mutex" sarmalayici.
//   grup  : SafeEngine; eszamanli yazmalar tek transaction'da birlestirilir.
// Kullanim: bench_writes [thread=16] [yazma/thread=500]
#include <unistd.h>

#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#include "server/SafeEngine.hpp"

using namespace litedb;
using Clock = std::chrono::steady_clock;

static std::string tmpDir() {
  char tmpl[] = "/tmp/litedb-bench-XXXXXX";
  return ::mkdtemp(tmpl);
}
static void cleanup(const std::string& dir) {
  std::string cmd = "rm -rf '" + dir + "'";
  if (std::system(cmd.c_str()) != 0) {}
}

struct Result {
  double opsPerSec, p50ms, p99ms;
  double avgBatch;
};

template <class WriteFn>
static Result drive(int threads, int per, WriteFn write) {
  std::vector<std::vector<double>> lat(threads);
  auto t0 = Clock::now();
  std::vector<std::thread> ts;
  for (int t = 0; t < threads; ++t)
    ts.emplace_back([&, t] {
      lat[t].reserve(per);
      for (int i = 0; i < per; ++i) {
        auto a = Clock::now();
        write(t, i);
        lat[t].push_back(std::chrono::duration<double, std::milli>(Clock::now() - a).count());
      }
    });
  for (auto& t : ts) t.join();
  double secs = std::chrono::duration<double>(Clock::now() - t0).count();
  std::vector<double> all;
  for (auto& v : lat) all.insert(all.end(), v.begin(), v.end());
  std::sort(all.begin(), all.end());
  Result r;
  r.opsPerSec = all.size() / secs;
  r.p50ms = all[all.size() / 2];
  r.p99ms = all[std::min(all.size() - 1, all.size() * 99 / 100)];
  r.avgBatch = 1;
  return r;
}

static Result naive(int threads, int per, bool durable) {
  std::string dir = tmpDir();
  Result r;
  {
    Engine e(dir + "/n.db");
    if (durable) e.db().exec("PRAGMA synchronous=FULL");
    std::mutex mu;
    r = drive(threads, per, [&](int t, int i) {
      std::lock_guard<std::mutex> lk(mu);
      auto tx = e.transaction();
      e.docs.put("c", std::to_string(t) + "-" + std::to_string(i), "{\"v\":1}");
      tx.commit();
    });
  }
  cleanup(dir);
  return r;
}

static Result grouped(int threads, int per, bool durable) {
  std::string dir = tmpDir();
  Result r;
  {
    SafeEngineOptions o;
    o.path = dir + "/g.db";
    o.durable = durable;
    SafeEngine eng(o);
    r = drive(threads, per, [&](int t, int i) {
      eng.write([&](Engine& e) { e.docs.put("c", std::to_string(t) + "-" + std::to_string(i), "{\"v\":1}"); });
    });
    r.avgBatch = eng.stats().avgBatch();
  }
  cleanup(dir);
  return r;
}

int main(int argc, char** argv) {
  int threads = argc > 1 ? std::atoi(argv[1]) : 16;
  int per = argc > 2 ? std::atoi(argv[2]) : 500;
  std::printf("%d thread x %d yazma = %d yazma\n\n", threads, per, threads * per);
  std::printf("%-26s %12s %10s %10s %10s\n", "mod", "yazma/sn", "p50 ms", "p99 ms", "yazma/commit");
  for (bool durable : {false, true}) {
    int p = durable ? std::max(10, per / 5) : per;  // fsync'li mod yavas; daha az yazma
    Result a = naive(threads, p, durable);
    Result b = grouped(threads, p, durable);
    const char* tag = durable ? "synchronous=FULL" : "synchronous=NORMAL";
    std::printf("%-26s %12.0f %10.2f %10.2f %10s\n", (std::string("naif mutex, ") + tag).c_str(), a.opsPerSec, a.p50ms, a.p99ms, "1");
    std::printf("%-26s %12.0f %10.2f %10.2f %10.1f\n", (std::string("grup commit, ") + tag).c_str(), b.opsPerSec, b.p50ms, b.p99ms, b.avgBatch);
    std::printf("  -> kazanc: %.1fx   (%d yazma/thread)\n", b.opsPerSec / a.opsPerSec, p);
  }
  return 0;
}
