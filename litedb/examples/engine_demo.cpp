#include <cassert>
#include <filesystem>
#include <iostream>

#include "Engine.hpp"

using namespace litedb;

int main() {
  const std::string path = "/tmp/litedb_engine_demo.db";
  for (auto ext : {"", "-wal", "-shm"}) std::filesystem::remove(path + ext);

  {
    Engine e(path);
    {
      auto tx = e.transaction();
      e.docs.put("users", "u1", R"({"name":"Ayse","age":30})");
      e.docs.put("users", "u2", R"({"name":"Can","age":25})");
      e.graph.addNode("u1", "Person");
      e.graph.addNode("u2", "Person");
      e.graph.addEdge("u1", "follows", "u2");
      e.ts.write("login", 1000, 1, R"({"user":"u1"})");
      e.ts.write("login", 2000, 1, R"({"user":"u2"})");
      tx.commit();
    }
    e.cache.set("session:u1", "token123", 60000);

    // Geri alinan islem hicbir modelde iz birakmaz
    {
      auto tx = e.transaction();
      e.docs.put("users", "u3", R"({"name":"Hayalet"})");
      e.graph.addNode("u3", "Person");
      e.ts.write("login", 3000, 1);
    }
    assert(!e.docs.get("users", "u3") && !e.graph.getNode("u3") && e.ts.count("login") == 2);

    // Hata ortada olursa (olmayan dugume kenar) transaction geri alinir
    bool threw = false;
    try {
      auto tx = e.transaction();
      e.docs.put("users", "u4", R"({"name":"X"})");
      e.graph.addEdge("u1", "follows", "yok");  // FK hatasi
      tx.commit();
    } catch (const SqliteError&) { threw = true; }
    assert(threw && !e.docs.get("users", "u4"));

    assert(*e.cache.get("session:u1") == "token123");
  }  // Engine kapanir

  {
    Engine e(path);  // yeniden ac: kalici veriler duruyor, onbellek bos
    assert(e.docs.count("users") == 2);
    assert(e.docs.find("users", "age", 30).size() == 1);
    assert(e.graph.hasEdge("u1", "follows", "u2"));
    assert((e.graph.shortestPath("u1", "u2") == std::vector<std::string>{"u1", "u2"}));
    assert(e.ts.count("login") == 2 && e.ts.latest("login")->ts == 2000);
    assert(!e.cache.get("session:u1"));
  }

  for (auto ext : {"", "-wal", "-shm"}) std::filesystem::remove(path + ext);
  std::cout << "TUM ENGINE TESTLERI GECTI\n";
}
