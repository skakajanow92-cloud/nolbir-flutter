#include "core/Database.hpp"

namespace litedb {

Database::Database(const std::string& path) {
  int rc = sqlite3_open_v2(
      path.c_str(), &db_,
      SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX,
      nullptr);
  if (rc != SQLITE_OK) {
    std::string msg = db_ ? sqlite3_errmsg(db_) : "bellek yetersiz";
    sqlite3_close(db_);
    db_ = nullptr;
    throw SqliteError("veritabani acilamadi: " + msg);
  }
  sqlite3_busy_timeout(db_, 5000);
  exec("PRAGMA journal_mode=WAL;"
       "PRAGMA synchronous=NORMAL;"
       "PRAGMA foreign_keys=ON;");
}

Database::~Database() {
  if (db_) sqlite3_close_v2(db_);
}

void Database::exec(const std::string& sql) {
  char* err = nullptr;
  int rc = sqlite3_exec(db_, sql.c_str(), nullptr, nullptr, &err);
  if (rc != SQLITE_OK) {
    std::string msg = err ? err : sqlite3_errstr(rc);
    sqlite3_free(err);
    throw SqliteError("exec hatasi: " + msg);
  }
}

void Database::check(int rc, const char* what) const {
  if (rc != SQLITE_OK && rc != SQLITE_ROW && rc != SQLITE_DONE) {
    throw SqliteError(std::string(what) + ": " + sqlite3_errmsg(db_));
  }
}

}  // namespace litedb
