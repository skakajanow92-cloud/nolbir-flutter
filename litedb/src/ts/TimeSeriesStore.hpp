#pragma once
#include <optional>
#include <string>
#include <unordered_map>
#include <variant>
#include <vector>

#include "core/Database.hpp"
#include "core/Statement.hpp"

namespace litedb {

enum class Agg { Avg, Min, Max, Sum, Count, First, Last };

// InfluxDB benzeri zaman serisi deposu. Her nokta: (seri, zaman, deger, etiketler).
// Zaman damgasi tam sayidir; milisaniye (Unix epoch) onerilir, nowMs() verir.
// Zaman araliklari [from, to) yani from dahil, to haric. Zaman damgalari
// negatif olmamalidir (downsample kovalari bunu varsayar).
class TimeSeriesStore {
 public:
  using Value = std::variant<long long, double, std::string>;

  struct Point {
    long long ts;
    double value;
    std::string tags = "{}";  // JSON nesnesi, ornek: {"host":"a","dc":"eu"}
  };
  struct Stats {
    long long count;
    double min, max, sum, avg;
  };
  struct Bucket {
    long long start;   // kovanin baslangic zamani (bucketMs'in kati)
    double value;      // secilen toplama sonucu
    long long count;   // kovadaki nokta sayisi
  };

  explicit TimeSeriesStore(Database& db);

  static long long nowMs();

  // Yazar; ayni (seri, ts) varsa degeri gunceller.
  void write(const std::string& series, long long ts, double value,
             const std::string& tagsJson = "{}");

  // Hepsi tek atomik islemde yazilir; biri basarisiz olursa hicbiri yazilmaz.
  // Acik bir Transaction icinde de guvenle cagrilabilir (SAVEPOINT kullanir).
  void writeBatch(const std::string& series, const std::vector<Point>& points);

  std::vector<Point> range(const std::string& series, long long from,
                           long long to, int limit = 100000);

  // Etiket esitligine gore filtreli aralik. tagKey: harf/rakam/'_'/'.'.
  std::vector<Point> rangeByTag(const std::string& series, long long from,
                                long long to, const std::string& tagKey,
                                const Value& tagValue, int limit = 100000);

  std::optional<Point> latest(const std::string& series);

  // Aralikta nokta yoksa nullopt.
  std::optional<Stats> stats(const std::string& series, long long from,
                             long long to);

  // [from,to) araligini bucketMs genisliginde kovalara bolup her birini
  // toplar. Bos kovalar listede yer almaz.
  std::vector<Bucket> downsample(const std::string& series, long long from,
                                 long long to, long long bucketMs, Agg agg);

  // --- Retention (eski veriyi temizleme) --- silinen satir sayisini dondurur
  long long deleteBefore(const std::string& series, long long ts);
  long long deleteBeforeAll(long long ts);
  long long removeSeries(const std::string& series);

  long long count(const std::string& series);
  std::vector<std::string> listSeries();

 private:
  static Database& init(Database& db);
  Statement& tagStmt(const std::string& key);
  Statement& downsampleStmt(Agg agg);

  Database& db_;
  Statement write_, range_, latest_, stats_;
  Statement delBefore_, delBeforeAll_, delSeries_, count_, series_;
  std::unordered_map<std::string, Statement> tagCache_;
  std::unordered_map<int, Statement> dsCache_;
};

}  // namespace litedb
