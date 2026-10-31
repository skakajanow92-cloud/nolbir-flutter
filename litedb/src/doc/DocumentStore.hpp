#pragma once
#include <optional>
#include <string>
#include <unordered_map>
#include <variant>
#include <vector>

#include "core/Database.hpp"
#include "core/Statement.hpp"

namespace litedb {

// MongoDB benzeri belge deposu. Belgeler JSON metni olarak `docs` tablosunda
// tutulur: (koleksiyon, id) -> govde. Gecersiz JSON reddedilir.
class DocumentStore {
 public:
  using Value = std::variant<long long, double, std::string>;

  struct Doc {
    std::string id;
    std::string body;  // JSON metni
  };

  explicit DocumentStore(Database& db);

  // Ekler veya ayni id varsa uzerine yazar. Gecersiz JSON -> SqliteError.
  void put(const std::string& coll, const std::string& id,
           const std::string& json);

  std::optional<std::string> get(const std::string& coll, const std::string& id);

  // Silindiyse true, boyle bir belge yoksa false.
  bool remove(const std::string& coll, const std::string& id);

  long long count(const std::string& coll);

  // Alan esitligine gore arama. path ornekleri: "age", "address.city",
  // "tags[0]". Yalnizca harf, rakam, '_', '.', '[' ve ']' kabul edilir.
  std::vector<Doc> find(const std::string& coll, const std::string& path,
                        const Value& value, int limit = 1000);

  // Tum koleksiyon (id sirasiyla).
  std::vector<Doc> all(const std::string& coll, int limit = 1000);

  // find() sorgulari icin alan indeksi olusturur (tum koleksiyonlarda gecerli).
  void createIndex(const std::string& path);

 private:
  static Database& init(Database& db);
  static std::string jsonPath(const std::string& path);  // dogrular, "$.x" yapar
  Statement& findStmt(const std::string& path);

  Database& db_;
  Statement put_, get_, del_, count_, all_;
  std::unordered_map<std::string, Statement> findCache_;
};

}  // namespace litedb
