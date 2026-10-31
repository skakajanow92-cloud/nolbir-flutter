#pragma once
#include <sqlite3.h>

#include <string>
#include <string_view>

#include "core/Database.hpp"

namespace litedb {

// Hazirlanmis (prepared) SQL ifadesi sarmalayicisi. Bir kez hazirla,
// reset() + bind() + step() ile defalarca kullan.
// Parametre ve sutun indeksleri: bind 1'den, sutun 0'dan baslar.
class Statement {
 public:
  Statement(Database& db, const std::string& sql);
  ~Statement();

  Statement(Statement&& o) noexcept;
  Statement& operator=(Statement&& o) noexcept;
  Statement(const Statement&) = delete;
  Statement& operator=(const Statement&) = delete;

  // Onceki calistirmayi ve baglamalari temizler. Zincirlenebilir.
  Statement& reset();

  Statement& bind(int i, std::string_view v);
  Statement& bind(int i, long long v);
  Statement& bind(int i, int v) { return bind(i, static_cast<long long>(v)); }
  Statement& bind(int i, double v);
  Statement& bindNull(int i);

  // Bir satir hazirsa true, bittiyse false doner.
  bool step();
  // Satir donmeyen ifadeyi (INSERT/DELETE...) sonuna kadar calistirir.
  void run();

  std::string text(int col) const;
  long long int64(int col) const;
  double real(int col) const;
  bool isNull(int col) const;

 private:
  Database* db_ = nullptr;
  sqlite3_stmt* stmt_ = nullptr;
};

}  // namespace litedb
