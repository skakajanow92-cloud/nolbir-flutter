#include "core/Statement.hpp"

#include <utility>

namespace litedb {

Statement::Statement(Database& db, const std::string& sql) : db_(&db) {
  int rc = sqlite3_prepare_v3(db.raw(), sql.c_str(),
                              static_cast<int>(sql.size()),
                              SQLITE_PREPARE_PERSISTENT, &stmt_, nullptr);
  if (rc != SQLITE_OK) {
    throw SqliteError("prepare hatasi: " + std::string(sqlite3_errmsg(db.raw())) +
                      " | SQL: " + sql);
  }
}

Statement::~Statement() {
  if (stmt_) sqlite3_finalize(stmt_);
}

Statement::Statement(Statement&& o) noexcept : db_(o.db_), stmt_(o.stmt_) {
  o.stmt_ = nullptr;
}

Statement& Statement::operator=(Statement&& o) noexcept {
  if (this != &o) {
    if (stmt_) sqlite3_finalize(stmt_);
    db_ = o.db_;
    stmt_ = o.stmt_;
    o.stmt_ = nullptr;
  }
  return *this;
}

Statement& Statement::reset() {
  sqlite3_reset(stmt_);
  sqlite3_clear_bindings(stmt_);
  return *this;
}

Statement& Statement::bind(int i, std::string_view v) {
  db_->check(sqlite3_bind_text(stmt_, i, v.data(), static_cast<int>(v.size()),
                               SQLITE_TRANSIENT),
             "bind(text)");
  return *this;
}

Statement& Statement::bind(int i, long long v) {
  db_->check(sqlite3_bind_int64(stmt_, i, v), "bind(int64)");
  return *this;
}

Statement& Statement::bind(int i, double v) {
  db_->check(sqlite3_bind_double(stmt_, i, v), "bind(double)");
  return *this;
}

Statement& Statement::bindNull(int i) {
  db_->check(sqlite3_bind_null(stmt_, i), "bind(null)");
  return *this;
}

bool Statement::step() {
  int rc = sqlite3_step(stmt_);
  if (rc == SQLITE_ROW) return true;
  if (rc == SQLITE_DONE) return false;
  throw SqliteError(std::string("step hatasi: ") + sqlite3_errmsg(db_->raw()));
}

void Statement::run() {
  while (step()) {
  }
}

std::string Statement::text(int col) const {
  const unsigned char* p = sqlite3_column_text(stmt_, col);
  int n = sqlite3_column_bytes(stmt_, col);
  return p ? std::string(reinterpret_cast<const char*>(p), n) : std::string();
}

long long Statement::int64(int col) const {
  return sqlite3_column_int64(stmt_, col);
}

double Statement::real(int col) const { return sqlite3_column_double(stmt_, col); }

bool Statement::isNull(int col) const {
  return sqlite3_column_type(stmt_, col) == SQLITE_NULL;
}

}  // namespace litedb
