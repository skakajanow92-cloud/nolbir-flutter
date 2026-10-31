#include <cassert>
#include <iostream>

#include "core/Database.hpp"
#include "core/Transaction.hpp"
#include "doc/DocumentStore.hpp"

using namespace litedb;

int main() {
  Database db(":memory:");
  DocumentStore docs(db);

  docs.put("users", "u1", R"({"name":"Ayse","age":30,"address":{"city":"Izmir"},"tags":["a","b"]})");
  docs.put("users", "u2", R"({"name":"Mehmet","age":25,"address":{"city":"Ankara"}})");
  docs.put("users", "u3", R"({"name":"Can","age":30,"address":{"city":"Izmir"}})");
  docs.put("notes", "n1", R"({"text":"merhaba"})");

  assert(docs.count("users") == 3);
  assert(docs.get("users", "u2").has_value());
  assert(!docs.get("users", "yok").has_value());

  // Alan sorgulari
  assert(docs.find("users", "age", 30).size() == 2);
  assert(docs.find("users", "address.city", std::string("Izmir")).size() == 2);
  assert(docs.find("users", "tags[0]", std::string("a")).size() == 1);
  assert(docs.find("notes", "age", 30).empty());  // koleksiyonlar ayri

  // Indeks + ayni sorgu
  docs.createIndex("age");
  assert(docs.find("users", "age", 25).size() == 1);

  // Ustune yazma
  docs.put("users", "u2", R"({"name":"Mehmet","age":26})");
  assert(docs.find("users", "age", 26).size() == 1);
  assert(docs.count("users") == 3);

  // Silme
  assert(docs.remove("users", "u3"));
  assert(!docs.remove("users", "u3"));
  assert(docs.count("users") == 2);

  // Gecersiz JSON reddedilir
  bool threw = false;
  try { docs.put("users", "bad", "{bozuk"); } catch (const SqliteError&) { threw = true; }
  assert(threw);

  // Yol enjeksiyonu reddedilir
  threw = false;
  try { docs.find("users", "x') OR 1=1 --", 1); } catch (const SqliteError&) { threw = true; }
  assert(threw);

  // Transaction: commit edilmezse geri alinir
  {
    Transaction t(db);
    docs.put("users", "tmp", R"({"age":99})");
  }
  assert(!docs.get("users", "tmp").has_value());
  {
    Transaction t(db);
    docs.put("users", "kalici", R"({"age":99})");
    t.commit();
  }
  assert(docs.get("users", "kalici").has_value());

  for (auto& d : docs.all("users")) std::cout << d.id << " -> " << d.body << "\n";
  std::cout << "TUM TESTLER GECTI\n";
}
