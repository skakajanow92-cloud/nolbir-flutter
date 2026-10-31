#include "ts/TimeSeriesStore.hpp"

#include <cctype>
#include <chrono>

namespace litedb {

Database& TimeSeriesStore::init(Database& db) {
  db.exec(
      "CREATE TABLE IF NOT EXISTS points("
      "  series TEXT    NOT NULL,"
      "  ts     INTEGER NOT NULL,"
      "  value  REAL    NOT NULL,"
      "  tags   TEXT    NOT NULL DEFAULT '{}' CHECK(json_valid(tags)),"
      "  PRIMARY KEY(series, ts)"
      ") WITHOUT ROWID;");
  return db;
}

TimeSeriesStore::TimeSeriesStore(Database& db)
    : db_(init(db)),
      write_(db,
             "INSERT INTO points(series,ts,value,tags) VALUES(?1,?2,?3,?4) "
             "ON CONFLICT(series,ts) DO UPDATE SET "
             "value=excluded.value, tags=excluded.tags"),
      range_(db,
             "SELECT ts,value,tags FROM points "
             "WHERE series=?1 AND ts>=?2 AND ts<?3 ORDER BY ts LIMIT ?4"),
      latest_(db,
              "SELECT ts,value,tags FROM points WHERE series=?1 "
              "ORDER BY ts DESC LIMIT 1"),
      stats_(db,
             "SELECT COUNT(*),MIN(value),MAX(value),SUM(value),AVG(value) "
             "FROM points WHERE series=?1 AND ts>=?2 AND ts<?3"),
      delBefore_(db, "DELETE FROM points WHERE series=?1 AND ts<?2"),
      delBeforeAll_(db, "DELETE FROM points WHERE ts<?1"),
      delSeries_(db, "DELETE FROM points WHERE series=?1"),
      count_(db, "SELECT COUNT(*) FROM points WHERE series=?1"),
      series_(db, "SELECT DISTINCT series FROM points ORDER BY series") {}

long long TimeSeriesStore::nowMs() {
  using namespace std::chrono;
  return duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
}

// ---------- Yazma ----------

void TimeSeriesStore::write(const std::string& series, long long ts, double value,
                            const std::string& tagsJson) {
  write_.reset().bind(1, series).bind(2, ts).bind(3, value).bind(4, tagsJson).run();
}

void TimeSeriesStore::writeBatch(const std::string& series,
                                 const std::vector<Point>& points) {
  db_.exec("SAVEPOINT litedb_ts_batch");
  try {
    for (const Point& p : points) write(series, p.ts, p.value, p.tags);
    db_.exec("RELEASE litedb_ts_batch");
  } catch (...) {
    db_.exec("ROLLBACK TO litedb_ts_batch; RELEASE litedb_ts_batch");
    throw;
  }
}

// ---------- Okuma ----------

std::vector<TimeSeriesStore::Point> TimeSeriesStore::range(
    const std::string& series, long long from, long long to, int limit) {
  range_.reset().bind(1, series).bind(2, from).bind(3, to).bind(4, limit);
  std::vector<Point> out;
  while (range_.step()) out.push_back({range_.int64(0), range_.real(1), range_.text(2)});
  range_.reset();
  return out;
}

Statement& TimeSeriesStore::tagStmt(const std::string& key) {
  auto it = tagCache_.find(key);
  if (it != tagCache_.end()) return it->second;
  if (key.empty()) throw SqliteError("bos etiket anahtari");
  for (unsigned char c : key)
    if (!(std::isalnum(c) || c == '_' || c == '.'))
      throw SqliteError("gecersiz etiket anahtari: " + key);
  // Anahtar dogrulandi; SQL'e sabit olarak gomulur.
  std::string sql =
      "SELECT ts,value,tags FROM points WHERE series=?1 AND ts>=?2 AND ts<?3 "
      "AND json_extract(tags,'$." + key + "')=?4 ORDER BY ts LIMIT ?5";
  return tagCache_.emplace(key, Statement(db_, sql)).first->second;
}

std::vector<TimeSeriesStore::Point> TimeSeriesStore::rangeByTag(
    const std::string& series, long long from, long long to,
    const std::string& tagKey, const Value& tagValue, int limit) {
  Statement& st = tagStmt(tagKey);
  st.reset().bind(1, series).bind(2, from).bind(3, to);
  std::visit([&](const auto& v) { st.bind(4, v); }, tagValue);
  st.bind(5, limit);
  std::vector<Point> out;
  while (st.step()) out.push_back({st.int64(0), st.real(1), st.text(2)});
  st.reset();
  return out;
}

std::optional<TimeSeriesStore::Point> TimeSeriesStore::latest(
    const std::string& series) {
  latest_.reset().bind(1, series);
  std::optional<Point> out;
  if (latest_.step())
    out = Point{latest_.int64(0), latest_.real(1), latest_.text(2)};
  latest_.reset();
  return out;
}

std::optional<TimeSeriesStore::Stats> TimeSeriesStore::stats(
    const std::string& series, long long from, long long to) {
  stats_.reset().bind(1, series).bind(2, from).bind(3, to);
  std::optional<Stats> out;
  if (stats_.step() && stats_.int64(0) > 0)
    out = Stats{stats_.int64(0), stats_.real(1), stats_.real(2), stats_.real(3),
                stats_.real(4)};
  stats_.reset();
  return out;
}

Statement& TimeSeriesStore::downsampleStmt(Agg agg) {
  auto it = dsCache_.find(static_cast<int>(agg));
  if (it != dsCache_.end()) return it->second;

  std::string expr, extra;
  switch (agg) {
    case Agg::Avg:   expr = "AVG(value)"; break;
    case Agg::Min:   expr = "MIN(value)"; break;
    case Agg::Max:   expr = "MAX(value)"; break;
    case Agg::Sum:   expr = "SUM(value)"; break;
    case Agg::Count: expr = "COUNT(*)"; break;
    // SQLite: tek bir MIN()/MAX() varken "bos" sutun o satirdan gelir.
    case Agg::First: expr = "value"; extra = ",MIN(ts)"; break;
    case Agg::Last:  expr = "value"; extra = ",MAX(ts)"; break;
  }
  std::string sql =
      "SELECT (ts/?4)*?4 AS b, " + expr + ", COUNT(*)" + extra +
      " FROM points WHERE series=?1 AND ts>=?2 AND ts<?3 GROUP BY b ORDER BY b";
  return dsCache_.emplace(static_cast<int>(agg), Statement(db_, sql)).first->second;
}

std::vector<TimeSeriesStore::Bucket> TimeSeriesStore::downsample(
    const std::string& series, long long from, long long to, long long bucketMs,
    Agg agg) {
  if (bucketMs <= 0) throw SqliteError("bucketMs pozitif olmali");
  Statement& st = downsampleStmt(agg);
  st.reset().bind(1, series).bind(2, from).bind(3, to).bind(4, bucketMs);
  std::vector<Bucket> out;
  while (st.step()) out.push_back({st.int64(0), st.real(1), st.int64(2)});
  st.reset();
  return out;
}

// ---------- Retention / bakim ----------

long long TimeSeriesStore::deleteBefore(const std::string& series, long long ts) {
  delBefore_.reset().bind(1, series).bind(2, ts).run();
  return db_.changes();
}

long long TimeSeriesStore::deleteBeforeAll(long long ts) {
  delBeforeAll_.reset().bind(1, ts).run();
  return db_.changes();
}

long long TimeSeriesStore::removeSeries(const std::string& series) {
  delSeries_.reset().bind(1, series).run();
  return db_.changes();
}

long long TimeSeriesStore::count(const std::string& series) {
  count_.reset().bind(1, series);
  long long n = count_.step() ? count_.int64(0) : 0;
  count_.reset();
  return n;
}

std::vector<std::string> TimeSeriesStore::listSeries() {
  series_.reset();
  std::vector<std::string> out;
  while (series_.step()) out.push_back(series_.text(0));
  series_.reset();
  return out;
}

}  // namespace litedb
