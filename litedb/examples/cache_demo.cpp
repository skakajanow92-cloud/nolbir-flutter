#include <atomic>
#include <climits>
#include <cassert>
#include <iostream>
#include <thread>
#include <vector>

#include "cache/CacheStore.hpp"

using namespace litedb;

int main() {
  // --- Temel islemler ---
  CacheStore c;
  assert(c.set("a", "1"));
  assert(*c.get("a") == "1");
  c.set("a", "2");
  assert(*c.get("a") == "2" && c.size() == 1);
  assert(!c.get("yok"));
  assert(c.exists("a") && !c.exists("yok"));
  assert(c.del("a") && !c.del("a") && !c.get("a"));

  // --- TTL (sahte saatle deterministik) ---
  long long now = 1000;
  CacheStore t({}, [&] { return now; });
  t.set("k", "v", 500);       // 1500'de dolar
  t.set("kalici", "x");
  assert(t.ttl("k") == 500 && t.ttl("kalici") == -1 && t.ttl("yok") == -2);
  now = 1499;
  assert(t.get("k") && t.ttl("k") == 1);
  now = 1500;
  assert(!t.get("k"));                       // tam sinirda dolmus
  assert(t.ttl("k") == -2 && t.size() == 1);  // tembel silme gerceklesti

  // expire / persist
  assert(t.expire("kalici", 100) && t.ttl("kalici") == 100);
  assert(t.expire("kalici", 0) && t.ttl("kalici") == -1);
  assert(!t.expire("yok", 100));

  // purgeExpired: hic erisilmeyenler temizlenir
  t.set("x1", "1", 10); t.set("x2", "2", 10); t.set("x3", "3", 1000);
  now = 1600;
  assert(t.purgeExpired() == 2 && t.size() == 2);  // kalici + x3
  assert(t.stats().expired >= 3);

  // set TTL'i sifirlar (Redis SET gibi)
  t.set("x3", "yeni");
  assert(t.ttl("x3") == -1);

  // --- LRU tahliye (girdi sayisina gore) ---
  CacheStore l({3, 0});
  l.set("a", "1"); l.set("b", "2"); l.set("c", "3");
  l.get("a");              // a en yeni, b en eski
  l.set("d", "4");         // b tahliye edilmeli
  assert(!l.exists("b") && l.exists("a") && l.exists("c") && l.exists("d"));
  assert(l.size() == 3 && l.stats().evictions == 1);
  // exists LRU'yu guncellemez: c en eski olmali
  l.exists("c");
  l.set("e", "5");
  assert(!l.exists("c"));

  // --- Bayt siniri ---
  CacheStore b({0, 10});   // anahtar+deger toplam en fazla 10 bayt
  b.set("a", "1234");      // 5 bayt
  b.set("b", "1234");      // 5 bayt -> toplam 10
  assert(b.size() == 2 && b.stats().bytes == 10);
  b.set("c", "1234");      // tahliye: a gider
  assert(!b.exists("a") && b.exists("b") && b.exists("c"));
  assert(!b.set("buyuk", "0123456789"));  // 15 bayt > 10: saklanmaz
  assert(!b.exists("buyuk"));
  b.set("c", "x");         // kucultme sayaci dogru tutmali
  assert(b.stats().bytes == 5 + 2);

  // --- incr ---
  CacheStore n;
  assert(n.incr("sayac") == 1 && n.incr("sayac", 5) == 6 && n.incr("sayac", -10) == -4);
  assert(*n.get("sayac") == "-4");
  n.set("metin", "abc");
  bool threw = false;
  try { n.incr("metin"); } catch (const std::invalid_argument&) { threw = true; }
  assert(threw);
  n.set("buyuk", std::to_string(LLONG_MAX));
  threw = false;
  try { n.incr("buyuk"); } catch (const std::overflow_error&) { threw = true; }
  assert(threw);
  // incr TTL'i korur
  long long now2 = 0;
  CacheStore n2({}, [&] { return now2; });
  n2.set("s", "5", 100);
  n2.incr("s");
  assert(*n2.get("s") == "6" && n2.ttl("s") == 100);

  // --- Istatistik ---
  CacheStore s;
  s.set("k", "v");
  s.get("k"); s.get("k"); s.get("yok");
  assert(s.stats().hits == 2 && s.stats().misses == 1);
  s.clear();
  assert(s.size() == 0 && s.stats().bytes == 0);

  // --- Thread guvenligi: 4 thread x 5000 incr ---
  CacheStore m({100, 0});
  std::vector<std::thread> th;
  for (int i = 0; i < 4; i++)
    th.emplace_back([&, i] {
      for (int j = 0; j < 5000; j++) {
        m.incr("toplam");
        m.set("k" + std::to_string((i * 5000 + j) % 300), "v");
        m.get("k" + std::to_string(j % 300));
      }
    });
  for (auto& x : th) x.join();
  // "toplam" tahliye edilmis olabilir; kapasiteyi asmadigini ve tutarliligi dogrula
  assert(m.size() <= 100);
  CacheStore m2;
  std::vector<std::thread> th2;
  for (int i = 0; i < 4; i++)
    th2.emplace_back([&] { for (int j = 0; j < 5000; j++) m2.incr("toplam"); });
  for (auto& x : th2) x.join();
  assert(*m2.get("toplam") == "20000");

  std::cout << "TUM ONBELLEK TESTLERI GECTI\n";
}
