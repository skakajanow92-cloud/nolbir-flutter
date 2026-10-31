#include <cassert>
#include <cmath>
#include <iostream>

#include "core/Database.hpp"
#include "core/Transaction.hpp"
#include "doc/DocumentStore.hpp"
#include "graph/GraphStore.hpp"
#include "ts/TimeSeriesStore.hpp"

using namespace litedb;

static bool eq(double a, double b) { return std::fabs(a - b) < 1e-9; }

int main() {
  Database db(":memory:");
  TimeSeriesStore ts(db);

  // 10 nokta: t=0,1000,...,9000 ms, deger = 1..10
  for (int i = 0; i < 10; i++)
    ts.write("cpu", i * 1000, i + 1, i % 2 ? R"({"host":"b"})" : R"({"host":"a"})");

  assert(ts.count("cpu") == 10);

  // Aralik: from dahil, to haric
  assert(ts.range("cpu", 2000, 5000).size() == 3);           // 2000,3000,4000
  assert(ts.range("cpu", 2000, 5000)[0].value == 3);
  assert(ts.range("cpu", 0, 100000, 4).size() == 4);          // limit
  assert(ts.range("yok", 0, 100000).empty());

  // Son nokta
  assert(ts.latest("cpu")->ts == 9000 && ts.latest("cpu")->value == 10);
  assert(!ts.latest("yok"));

  // Ayni zamana yazma ustune yazar
  ts.write("cpu", 9000, 99);
  assert(ts.count("cpu") == 10 && ts.latest("cpu")->value == 99);
  ts.write("cpu", 9000, 10, R"({"host":"b"})");

  // Istatistik
  auto s = ts.stats("cpu", 0, 10000);
  assert(s && s->count == 10 && eq(s->min, 1) && eq(s->max, 10) &&
         eq(s->sum, 55) && eq(s->avg, 5.5));
  assert(!ts.stats("cpu", 50000, 60000));

  // Downsample: 5 saniyelik kovalar -> [0,5000) ve [5000,10000)
  auto avg = ts.downsample("cpu", 0, 10000, 5000, Agg::Avg);
  assert(avg.size() == 2 && avg[0].start == 0 && avg[1].start == 5000);
  assert(eq(avg[0].value, 3) && eq(avg[1].value, 8) && avg[0].count == 5);
  assert(eq(ts.downsample("cpu", 0, 10000, 5000, Agg::Min)[1].value, 6));
  assert(eq(ts.downsample("cpu", 0, 10000, 5000, Agg::Max)[0].value, 5));
  assert(eq(ts.downsample("cpu", 0, 10000, 5000, Agg::Sum)[1].value, 40));
  assert(eq(ts.downsample("cpu", 0, 10000, 5000, Agg::Count)[0].value, 5));
  assert(eq(ts.downsample("cpu", 0, 10000, 5000, Agg::First)[1].value, 6));
  assert(eq(ts.downsample("cpu", 0, 10000, 5000, Agg::Last)[0].value, 5));
  assert(eq(ts.downsample("cpu", 0, 10000, 5000, Agg::Last)[1].value, 10));
  // bos kovalar atlanir
  ts.write("seyrek", 1000, 1);
  ts.write("seyrek", 9000, 2);
  assert(ts.downsample("seyrek", 0, 10000, 2000, Agg::Avg).size() == 2);
  bool threw = false;
  try { ts.downsample("cpu", 0, 10, 0, Agg::Avg); } catch (const SqliteError&) { threw = true; }
  assert(threw);

  // Etiket filtresi
  assert(ts.rangeByTag("cpu", 0, 10000, "host", std::string("a")).size() == 5);
  assert(ts.rangeByTag("cpu", 0, 10000, "host", std::string("b")).size() == 5);
  threw = false;
  try { ts.rangeByTag("cpu", 0, 1, "x') OR 1=1 --", 1LL); } catch (const SqliteError&) { threw = true; }
  assert(threw);

  // Toplu yazma: gecersiz etiket ortada -> hicbiri yazilmaz
  threw = false;
  try {
    ts.writeBatch("mem", {{0, 1}, {1, 2, "{bozuk"}, {2, 3}});
  } catch (const SqliteError&) { threw = true; }
  assert(threw && ts.count("mem") == 0);
  ts.writeBatch("mem", {{0, 1}, {1, 2}, {2, 3}});
  assert(ts.count("mem") == 3);

  // Acik Transaction icinde toplu yazma (SAVEPOINT) ve dis geri alma
  {
    Transaction tx(db);
    ts.writeBatch("mem", {{10, 1}, {11, 2}});
    assert(ts.count("mem") == 5);
  }  // commit yok
  assert(ts.count("mem") == 3);

  // Retention
  assert(ts.deleteBefore("cpu", 5000) == 5);
  assert(ts.count("cpu") == 5 && ts.range("cpu", 0, 100000)[0].ts == 5000);
  assert(ts.deleteBeforeAll(1500) == 4);  // seyrek:1000 + mem:0,1,2
  assert(ts.count("seyrek") == 1 && ts.count("mem") == 0);
  assert(ts.removeSeries("seyrek") == 1 && ts.count("seyrek") == 0);

  auto names = ts.listSeries();
  assert((names == std::vector<std::string>{"cpu"}));

  // Coklu model: belge + graf + zaman serisi ayni transaction'da
  DocumentStore docs(db);
  GraphStore g(db);
  {
    Transaction tx(db);
    docs.put("hosts", "h1", R"({"name":"a"})");
    g.addNode("h1", "Host");
    ts.write("temp", TimeSeriesStore::nowMs(), 42.5);
    tx.commit();
  }
  assert(docs.get("hosts", "h1") && g.getNode("h1") && ts.count("temp") == 1);

  std::cout << "TUM ZAMAN SERISI TESTLERI GECTI\n";
}
