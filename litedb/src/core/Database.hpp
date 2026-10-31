#pragma once
#include <sqlite3.h>

#include <stdexcept>
#include <string>

namespace litedb {

class SqliteError : public std::runtime_error {
 public:
  using std::runtime_error::runtime_error;
};

// Tek bir SQLite baglantisini yoneten RAII sinifi.
// path olarak ":memory:" verilirse bellek ici veritabani acilir.
class Database {
 public:
  explicit Database(const std::string& path);
  ~Database();

  Database(const Database&) = delete;
  Database& operator=(const Database&) = delete;

  sqlite3* raw() const noexcept { return db_; }

  // Sonuc dondurmeyen (veya sonucu umursamadigimiz) SQL calistirir.
  void exec(const std::string& sql);

  // Son INSERT/UPDATE/DELETE'ten etkilenen satir sayisi.
  int changes() const noexcept { return sqlite3_changes(db_); }

  // rc hata kodunu kontrol eder, hataliysa SqliteError firlatir.
  void check(int rc, const char* what) const;

 private:
  sqlite3* db_ = nullptr;
};

}  // namespace litedb
