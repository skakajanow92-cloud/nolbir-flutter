// SafeEngine testi: eszamanlilik, hata yalitimi, atomiklik, geri alma, kapanis.
// ThreadSanitizer ile de calistirilir: cmake -DLITEDB_SANITIZE=thread
#include <unistd.h>

#include <atomic>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <thread>
#include <vector>

#include "server/SafeEngine.hpp"

using namespace litedb;

static int g_fail = 0;
#define CHECK(cond)                                                          \
  do {                                                                       \
    if (!(cond)) {                                                           \
      std::fprintf(stderr, "BASARISIZ %s:%d: %s\n", __FILE__, __LINE__, #cond); \
      ++g_fail;                                                              \
    }                                                                        \
  } while (0)

static std::string tmpDb() {
  char tmpl[] = "/tmp/litedb-test-XXXXXX";
  int fd = ::mkstemp(tmpl);
  ::close(fd);
  return tmpl;
}
static void cleanup(const std::string& p) {
  ::unlink(p.c_str());
  ::unlink((p + "-wal").c_str());
  ::unlink((p + "-shm").c_str());
}

static void testConcurrent() {
  std::string path = tmpDb();
  {
    SafeEngineOptions o;
    o.path = path;
    o.readers = 4;
    SafeEngine eng(o);
    constexpr int W = 16, N = 200;
    std::atomic<bool> stop{false};
    std::atomic<long> reads{0};
    std::vector<std::thread> ts;
    for (int r = 0; r < 6; ++r)
      ts.emplace_back([&] {
        while (!stop) {
          eng.read([](Engine& e) { return e.docs.count("c"); });
          ++reads;
        }
      });
    std::vector<std::thread> ws;
    for (int w = 0; w < W; ++w)
      ws.emplace_back([&, w] {
        for (int i = 0; i < N; ++i) {
          std::string id = std::to_string(w) + "-" + std::to_string(i);
          eng.write([&](Engine& e) { e.docs.put("c", id, "{\"w\":" + std::to_string(w) + "}"); });
          // yazdiktan sonra okuma hemen gormeli (read-your-writes)
          auto got = eng.read([&](Engine& e) { return e.docs.get("c", id); });
          CHECK(got.has_value());
        }
      });
    for (auto& t : ws) t.join();
    stop = true;
    for (auto& t : ts) t.join();
    CHECK(eng.read([](Engine& e) { return e.docs.count("c"); }) == W * N);
    auto st = eng.stats();
    CHECK(st.ops == static_cast<uint64_t>(W * N));
    CHECK(st.batches <= st.ops);
    CHECK(st.failed == 0);
    std::printf("  esamanli: %llu yazma, %llu commit (ort. %.1f/commit), %ld okuma\n",
                (unsigned long long)st.ops, (unsigned long long)st.batches, st.avgBatch(), reads.load());
  }
  cleanup(path);
}

static void testIsolation() {
  std::string path = tmpDb();
  {
    SafeEngineOptions o;
    o.path = path;
    o.lingerMicros = 2000;  // gorevlerin ayni batch'e dusme sansini artir
    SafeEngine eng(o);
    std::atomic<int> sqlErr{0}, rtErr{0}, ok{0};
    std::vector<std::thread> ts;
    for (int i = 0; i < 40; ++i)
      ts.emplace_back([&, i] {
        try {
          eng.write([&](Engine& e) {
            e.docs.put("iso", "ok" + std::to_string(i), "{}");
            if (i % 4 == 1) e.docs.put("iso", "bad" + std::to_string(i), "{gecersiz");  // SqliteError
            if (i % 4 == 2) throw std::runtime_error("kasitli");
            // kenar: olmayan dugum -> FOREIGN KEY hatasi
            if (i % 4 == 3) e.graph.addEdge("yok1", "r", "yok2");
          });
          ++ok;
        } catch (const SqliteError&) {
          ++sqlErr;
        } catch (const std::runtime_error&) {
          ++rtErr;
        }
      });
    for (auto& t : ts) t.join();
    CHECK(ok == 10);
    CHECK(sqlErr == 20);  // i%4==1 (10) ve i%4==3 (10)
    CHECK(rtErr == 10);
    // Basarisiz gorevlerin "ok<i>" yazilari da geri alinmis olmali; yalniz ok olanlar kalir.
    CHECK(eng.read([](Engine& e) { return e.docs.count("iso"); }) == 10);
    CHECK(eng.read([](Engine& e) { return e.graph.countEdges(); }) == 0);
  }
  cleanup(path);
}

static void testAtomicMultiModel() {
  std::string path = tmpDb();
  {
    SafeEngineOptions o;
    o.path = path;
    SafeEngine eng(o);
    try {
      eng.write([](Engine& e) {
        e.docs.put("m", "a", "{}");
        e.graph.addNode("n1", "X");
        e.ts.write("s", 1, 1.0);
        throw std::runtime_error("geri al");
      });
      CHECK(false);
    } catch (const std::runtime_error&) {
    }
    CHECK(eng.read([](Engine& e) { return e.docs.count("m"); }) == 0);
    CHECK(eng.read([](Engine& e) { return e.graph.countNodes(); }) == 0);
    CHECK(eng.read([](Engine& e) { return e.ts.count("s"); }) == 0);

    eng.write([](Engine& e) {
      e.docs.put("m", "a", "{}");
      e.graph.addNode("n1", "X");
      e.ts.write("s", 1, 1.0);
    });
    CHECK(eng.read([](Engine& e) { return e.docs.count("m"); }) == 1);
    CHECK(eng.read([](Engine& e) { return e.graph.countNodes(); }) == 1);
    CHECK(eng.read([](Engine& e) { return e.ts.count("s"); }) == 1);

    // ts.writeBatch (kendi SAVEPOINT'i) ic ice kullanilabilmeli
    eng.write([](Engine& e) { e.ts.writeBatch("b", {{1, 1, "{}"}, {2, 2, "{}"}, {3, 3, "{}"}}); });
    CHECK(eng.read([](Engine& e) { return e.ts.count("b"); }) == 3);

    // Okuma baglantisi yazmaya izin vermemeli (query_only)
    bool threw = false;
    try {
      eng.read([](Engine& e) { e.docs.put("m", "zzz", "{}"); });
    } catch (const SqliteError&) {
      threw = true;
    }
    CHECK(threw);
    CHECK(eng.read([](Engine& e) { return e.docs.count("m"); }) == 1);

    // Hatali okumadan sonra havuz baglantisi saglam kalmali
    for (int i = 0; i < 20; ++i)
      CHECK(eng.read([](Engine& e) { return e.docs.count("m"); }) == 1);
  }
  cleanup(path);
}

static void testQueueFullAndReentrancy() {
  std::string path = tmpDb();
  {
    SafeEngineOptions o;
    o.path = path;
    o.maxQueue = 4;
    o.maxBatch = 1;
    SafeEngine eng(o);
    std::atomic<int> full{0}, ok{0};
    std::vector<std::thread> ts;
    for (int i = 0; i < 24; ++i)
      ts.emplace_back([&] {
        try {
          eng.write([](Engine&) { std::this_thread::sleep_for(std::chrono::milliseconds(15)); });
          ++ok;
        } catch (const QueueFullError&) {
          ++full;
        }
      });
    for (auto& t : ts) t.join();
    CHECK(full > 0);
    CHECK(ok + full == 24);

    bool logic = false;
    try {
      eng.write([&](Engine&) { eng.write([](Engine&) {}); });
    } catch (const std::logic_error&) {
      logic = true;
    }
    CHECK(logic);
    eng.write([](Engine&) {});  // kilitlenmedi
  }
  cleanup(path);
}

static void testShutdownDrains() {
  std::string path = tmpDb();
  std::atomic<int> done{0};
  {
    SafeEngineOptions o;
    o.path = path;
    SafeEngine eng(o);
    std::vector<std::thread> ts;
    for (int i = 0; i < 8; ++i)
      ts.emplace_back([&, i] {
        for (int k = 0; k < 50; ++k) {
          eng.write([&](Engine& e) { e.docs.put("d", std::to_string(i) + "." + std::to_string(k), "{}"); });
          ++done;
        }
      });
    for (auto& t : ts) t.join();
  }  // yikici: yazici thread'i bosaltip durdurur
  // Yeniden ac: veri kalici olmali
  {
    SafeEngineOptions o;
    o.path = path;
    SafeEngine eng(o);
    CHECK(eng.read([](Engine& e) { return e.docs.count("d"); }) == 400);
  }
  CHECK(done == 400);
  cleanup(path);
}

static void testRejectsMemory() {
  bool threw = false;
  try {
    SafeEngineOptions o;
    o.path = ":memory:";
    SafeEngine eng(o);
  } catch (const std::invalid_argument&) {
    threw = true;
  }
  CHECK(threw);
}

int main() {
  std::puts("SafeEngine testleri");
  testConcurrent();
  testIsolation();
  testAtomicMultiModel();
  testQueueFullAndReentrancy();
  testShutdownDrains();
  testRejectsMemory();
  if (g_fail) {
    std::printf("%d kontrol basarisiz\n", g_fail);
    return 1;
  }
  std::puts("tamam");
  return 0;
}
