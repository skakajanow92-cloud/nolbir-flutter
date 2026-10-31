#include <algorithm>
#include <cassert>
#include <iostream>

#include "core/Database.hpp"
#include "core/Transaction.hpp"
#include "doc/DocumentStore.hpp"
#include "graph/GraphStore.hpp"

using namespace litedb;
using Path = std::vector<std::string>;

int main() {
  Database db(":memory:");
  GraphStore g(db);

  for (auto id : {"ali", "ayse", "can", "deniz", "ela"})
    g.addNode(id, "Person", std::string(R"({"name":")") + id + "\"}");
  g.addNode("izmir", "City");

  // ali -> ayse -> can -> deniz   ve   ali -> can ;  deniz -> ali (dongu)
  g.addEdge("ali", "follows", "ayse");
  g.addEdge("ayse", "follows", "can");
  g.addEdge("can", "follows", "deniz");
  g.addEdge("deniz", "follows", "ali", R"({"since":2024})");
  g.addEdge("ali", "lives_in", "izmir");
  g.addEdge("ayse", "lives_in", "izmir");

  assert(g.countNodes() == 6 && g.countEdges() == 6);
  assert(g.getNode("ali")->label == "Person");
  assert(!g.getNode("yok"));
  assert(g.nodesByLabel("Person").size() == 5);

  // Komsuluk ve yon
  assert(g.neighbors("ali", "follows") == Path{"ayse"});
  assert(g.neighbors("ali").size() == 2);                     // ayse + izmir
  assert(g.neighbors("izmir", "", Direction::In).size() == 2);  // ali, ayse
  assert(g.neighbors("can", "follows", Direction::Both).size() == 2);  // ayse, deniz
  assert(g.hasEdge("ali", "follows", "ayse"));
  assert(!g.hasEdge("ayse", "follows", "ali"));

  // Kenar ozellikleri
  auto es = g.edgesOf("deniz", "follows");
  assert(es.size() == 1 && es[0].props == R"({"since":2024})");

  // Kenar ustune yazma sayiyi artirmaz
  g.addEdge("ali", "follows", "ayse", R"({"w":2})");
  assert(g.countEdges() == 6);

  // Gezinme (dongulu graf, sonlanmali)
  auto t = g.traverse("ali", 10, "follows");
  assert(t.size() == 3);  // ayse, can, deniz
  assert(t[0].id == "ayse" && t[0].depth == 1);
  assert(t[2].id == "deniz" && t[2].depth == 3);
  assert(g.traverse("ali", 1, "follows").size() == 1);
  assert(g.traverse("yok", 5).empty());

  // En kisa yol
  assert((g.shortestPath("ali", "deniz", 10, "follows") == Path{"ali", "ayse", "can", "deniz"}));
  g.addEdge("ali", "follows", "can");  // kisayol
  assert((g.shortestPath("ali", "deniz", 10, "follows") == Path{"ali", "can", "deniz"}));
  assert(g.shortestPath("ali", "ela", 10).empty());          // ulasilamaz
  assert(g.shortestPath("ali", "deniz", 1, "follows").empty());  // derinlik siniri
  assert((g.shortestPath("ali", "ali") == Path{"ali"}));
  assert(g.shortestPath("ayse", "ali", 10, "follows", Direction::In).size() == 2);

  // Self-loop Both modunda tek sayilir
  g.addEdge("ela", "knows", "ela");
  assert(g.edgesOf("ela", "knows", Direction::Both).size() == 1);

  // FK: olmayan dugume kenar eklenemez
  bool threw = false;
  try { g.addEdge("ali", "follows", "hayalet"); } catch (const SqliteError&) { threw = true; }
  assert(threw);

  // Gecersiz JSON props reddedilir
  threw = false;
  try { g.addNode("x", "T", "{bozuk"); } catch (const SqliteError&) { threw = true; }
  assert(threw);

  // Dugum guncelleme kenarlari silmemeli
  long long before = g.countEdges();
  g.addNode("ali", "Person", R"({"name":"Ali","age":40})");
  assert(g.countEdges() == before);

  // Dugum silme bagli kenarlari da siler
  assert(g.removeNode("izmir"));
  assert(!g.removeNode("izmir"));
  assert(g.neighbors("ali", "lives_in").empty());
  assert(g.removeEdge("ali", "follows", "can"));
  assert(!g.removeEdge("ali", "follows", "can"));

  // Coklu-model: belge + graf ayni transaction'da, geri alinabilir
  DocumentStore docs(db);
  {
    Transaction tx(db);
    docs.put("users", "u1", R"({"name":"Z"})");
    g.addNode("u1", "Person");
    g.addEdge("u1", "follows", "ali");
    // commit yok -> hepsi geri alinir
  }
  assert(!docs.get("users", "u1") && !g.getNode("u1"));
  {
    Transaction tx(db);
    docs.put("users", "u1", R"({"name":"Z"})");
    g.addNode("u1", "Person");
    g.addEdge("u1", "follows", "ali");
    tx.commit();
  }
  assert(docs.get("users", "u1") && g.hasEdge("u1", "follows", "ali"));

  std::cout << "TUM GRAF TESTLERI GECTI\n";
}
