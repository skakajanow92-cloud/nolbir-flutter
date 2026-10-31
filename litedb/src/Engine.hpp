#pragma once
#include <string>

#include "cache/CacheStore.hpp"
#include "core/Database.hpp"
#include "core/Transaction.hpp"
#include "doc/DocumentStore.hpp"
#include "graph/GraphStore.hpp"
#include "ts/TimeSeriesStore.hpp"

namespace litedb {

// Tum modelleri tek SQLite dosyasi (ve bellek ici onbellek) uzerinde birlestirir.
//
//   Engine e("data.db");
//   e.docs.put("users", "u1", R"({"name":"Ayse"})");
//   e.graph.addNode("u1", "Person");
//   e.ts.write("login", TimeSeriesStore::nowMs(), 1);
//   e.cache.set("session:u1", "abc", 60000);
//
//   { auto tx = e.transaction();  // belge + graf + zaman serisi birlikte atomik
//     e.docs.put(...); e.graph.addEdge(...); tx.commit(); }
//
// Thread notu: SQLite tabanli store'lar (docs, graph, ts) hazir ifadeleri
// paylastigi icin ayni anda tek thread'den kullanilmalidir (sunucuda tek
// islem kuyrugu veya disaridan mutex). `cache` thread-safe'tir.
class Engine {
 public:
  explicit Engine(const std::string& path, CacheOptions cacheOptions = {})
      : db_(path), docs(db_), graph(db_), ts(db_), cache(cacheOptions) {}

  Engine(const Engine&) = delete;
  Engine& operator=(const Engine&) = delete;

  Database& db() { return db_; }
  Transaction transaction() { return Transaction(db_); }

 private:
  Database db_;  // once olusmali: store'lar buna baglanir

 public:
  DocumentStore docs;
  GraphStore graph;
  TimeSeriesStore ts;
  CacheStore cache;
};

}  // namespace litedb
