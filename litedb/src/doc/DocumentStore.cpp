#include "doc/DocumentStore.hpp"

#include <cctype>
#include <functional>

namespace litedb {

Database& DocumentStore::init(Database& db) {
  db.exec(
      "CREATE TABLE IF NOT EXISTS docs("
      "  coll TEXT NOT NULL,"
      "  id   TEXT NOT NULL,"
      "  body TEXT NOT NULL CHECK(json_valid(body)),"
      "  PRIMARY KEY(coll, id)"
      ") WITHOUT ROWID;");
  return db;
}

DocumentStore::DocumentStore(Database& db)
    : db_(init(db)),
      put_(db,
           "INSERT INTO docs(coll,id,body) VALUES(?1,?2,?3) "
           "ON CONFLICT(coll,id) DO UPDATE SET body=excluded.body"),
      get_(db, "SELECT body FROM docs WHERE coll=?1 AND id=?2"),
      del_(db, "DELETE FROM docs WHERE coll=?1 AND id=?2"),
      count_(db, "SELECT COUNT(*) FROM docs WHERE coll=?1"),
      all_(db, "SELECT id, body FROM docs WHERE coll=?1 ORDER BY id LIMIT ?2") {}

void DocumentStore::put(const std::string& coll, const std::string& id,
                        const std::string& json) {
  put_.reset().bind(1, coll).bind(2, id).bind(3, json).run();
}

std::optional<std::string> DocumentStore::get(const std::string& coll,
                                              const std::string& id) {
  get_.reset().bind(1, coll).bind(2, id);
  std::optional<std::string> out;
  if (get_.step()) out = get_.text(0);
  get_.reset();  // okuma imlecini serbest birak
  return out;
}

bool DocumentStore::remove(const std::string& coll, const std::string& id) {
  del_.reset().bind(1, coll).bind(2, id).run();
  return db_.changes() > 0;
}

long long DocumentStore::count(const std::string& coll) {
  count_.reset().bind(1, coll);
  long long n = count_.step() ? count_.int64(0) : 0;
  count_.reset();
  return n;
}

std::string DocumentStore::jsonPath(const std::string& path) {
  if (path.empty()) throw SqliteError("bos alan yolu");
  for (unsigned char c : path) {
    if (!(std::isalnum(c) || c == '_' || c == '.' || c == '[' || c == ']')) {
      throw SqliteError("gecersiz alan yolu: " + path);
    }
  }
  // "tags[0]" gibi yollar "$.tags[0]" olur; "[0]" ile baslayan yol "$[0]" olur.
  return path[0] == '[' ? "$" + path : "$." + path;
}

Statement& DocumentStore::findStmt(const std::string& path) {
  auto it = findCache_.find(path);
  if (it != findCache_.end()) return it->second;
  // Yol SQL'e sabit olarak gomulur (dogrulandi); boylece alan indeksi
  // planlayici tarafindan kullanilabilir.
  std::string sql =
      "SELECT id, body FROM docs WHERE coll=?1 AND json_extract(body,'" +
      jsonPath(path) + "')=?2 ORDER BY id LIMIT ?3";
  return findCache_.emplace(path, Statement(db_, sql)).first->second;
}

std::vector<DocumentStore::Doc> DocumentStore::find(const std::string& coll,
                                                    const std::string& path,
                                                    const Value& value,
                                                    int limit) {
  Statement& st = findStmt(path);
  st.reset().bind(1, coll);
  std::visit([&](const auto& v) { st.bind(2, v); }, value);
  st.bind(3, limit);

  std::vector<Doc> out;
  while (st.step()) out.push_back({st.text(0), st.text(1)});
  st.reset();
  return out;
}

std::vector<DocumentStore::Doc> DocumentStore::all(const std::string& coll,
                                                   int limit) {
  all_.reset().bind(1, coll).bind(2, limit);
  std::vector<Doc> out;
  while (all_.step()) out.push_back({all_.text(0), all_.text(1)});
  all_.reset();
  return out;
}

void DocumentStore::createIndex(const std::string& path) {
  std::string jp = jsonPath(path);
  std::string name = "idx_docs_";
  for (unsigned char c : path) name += std::isalnum(c) ? static_cast<char>(c) : '_';
  name += "_" + std::to_string(std::hash<std::string>{}(path) % 100000);
  db_.exec("CREATE INDEX IF NOT EXISTS " + name +
           " ON docs(coll, json_extract(body,'" + jp + "'))");
}

}  // namespace litedb
