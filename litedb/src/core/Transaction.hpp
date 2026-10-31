#pragma once
#include "core/Database.hpp"

namespace litedb {

// RAII transaction: commit() cagrilmazsa yok edilirken ROLLBACK yapar.
class Transaction {
 public:
  explicit Transaction(Database& db) : db_(db) { db_.exec("BEGIN IMMEDIATE"); }
  ~Transaction() {
    if (!done_) {
      try { db_.exec("ROLLBACK"); } catch (...) {}
    }
  }
  Transaction(const Transaction&) = delete;
  Transaction& operator=(const Transaction&) = delete;

  void commit() {
    db_.exec("COMMIT");
    done_ = true;
  }

 private:
  Database& db_;
  bool done_ = false;
};

}  // namespace litedb
