# litedb

Tek SQLite dosyasi uzerinde hafif, cok modelli gomulu veritabani (C++17).
Uzerine thread-safe sarmalayici (`SafeEngine`), HTTP sunucusu (`litedbd`),
tarayici arayuzu ve terminal istemcisi (`litedb-cli`) eklidir.

| Model | Sinif | Depolama |
|---|---|---|
| Belge (MongoDB benzeri) | `DocumentStore` | SQLite (`docs`) |
| Graf (Neo4j benzeri) | `GraphStore` | SQLite (`nodes`, `edges`) |
| Zaman serisi (InfluxDB benzeri) | `TimeSeriesStore` | SQLite (`points`) |
| Onbellek (Redis benzeri) | `CacheStore` | Bellek (LRU + TTL) |
| Iliskisel | dogrudan `db.exec` / `Statement` | SQLite |

## Derleme ve test
```
cmake -B build && cmake --build build -j
ctest --test-dir build --output-on-failure      # safe_engine + e2e
cmake -B build-tsan -DLITEDB_SANITIZE=thread    # ThreadSanitizer ile
```
Gereksinim: C++17, SQLite >= 3.38 (JSON fonksiyonlari), CMake >= 3.18.
`third_party/sqlite/sqlite3.c` (amalgamation) varsa o derlenir, yoksa sistem SQLite'i.
e2e testi icin `curl` ve `python3` gerekir.

## Sunucu: litedbd
```
./build/litedbd --db veri.db                      # http://127.0.0.1:7070
./build/litedbd --db veri.db --host 0.0.0.0 --token-file /etc/litedb.token --durable
```
Tarayicidan `http://sunucu:7070/` acilir (Belgeler, Graf, Zaman serisi, Onbellek,
Durum sekmeleri). Belirtec istenirse sag ustteki alana girilir.

- **Guvenlik:** varsayilan dinleme `127.0.0.1`. Loopback disinda belirtecsiz
  baslamayi reddeder (`--insecure-no-auth` ile bilerek asilabilir). Belirtec:
  `--token-file` (onerilir) veya `LITEDB_TOKEN`; istekte `Authorization: Bearer ...`.
  `/healthz` ve arayuz sayfasinin kendisi belirtecsiz aciktir, veri uclari degil.
  TLS yoktur: `ssh -L 7070:127.0.0.1:7070 sunucu` ya da nginx/caddy ters vekili kullanin.
  Baska bir alan adiyla erisilecekse `--allow-host` verin.
- **Veri dosyasi** yerel diskte olmali (WAL; NFS/SMB uzerinde guvenilir degildir).
  Tek `litedbd` sureci bir dosyaya sahip olmalidir.
- Secenekler icin `litedbd --help`.

### REST API (ozet)
Tum yanitlar JSON'dur (onbellek degeri hariz: duz metin).

| Alan | Uclar |
|---|---|
| genel | `GET /healthz`, `GET /api/stats[?counts=1]`, `POST /api/tx` (atomik toplu islem) |
| belge | `GET /api/docs`, `GET /api/docs/{koleksiyon}[?field=&value=&type=&limit=]`, `PUT/GET/DELETE /api/docs/{koleksiyon}/{id}`, `POST /api/indexes/docs?field=` |
| graf | `/api/graph/nodes[/{id}]`, `/api/graph/nodes/{id}/edges`, `/api/graph/nodes/{id}/neighbors`, `/api/graph/edges`, `/api/graph/traverse`, `/api/graph/path` |
| zaman serisi | `GET /api/ts`, `POST /api/ts/{seri}`, `GET /api/ts/{seri}[/latest|/stats|/downsample]`, `DELETE /api/ts/{seri}` |
| onbellek | `PUT/GET/DELETE /api/cache/{anahtar}`, `POST /api/cache/{anahtar}/incr`, `/ttl`, `/expire` |

`POST /api/tx` govdesi `{"ops":[{"op":"doc.put",...},{"op":"graph.edge",...}]}`:
tum islemler tek transaction'da, biri hata verirse hicbiri uygulanmaz.

## CLI: litedb-cli
Bagimliligi yok; HTTP uzerinden calisir, yerelde de uzak sunucuda da ayni.
```
export LITEDB_URL=http://sunucu:7070 LITEDB_TOKEN=...
litedb-cli doc put users u1 '{"name":"Ayse","age":30}'
litedb-cli doc find users age 30
litedb-cli graph edge put u1 KNOWS u2
litedb-cli ts write cpu 0.73 --tags '{"host":"a"}'
litedb-cli ts down cpu --bucket 1m --from -1h
litedb-cli cache set oturum:u1 abc --ttl 60s
litedb-cli                 # etkilesimli kabuk (veya: litedb-cli -c < komutlar.txt)
```
JSON argumani dogrudan metin, `@dosya` ya da `-` (stdin) olabilir. Tum komutlar
icin `litedb-cli help`. Cikis kodu: 0 basari, 1 sunucu/ag hatasi, 2 kullanim hatasi.

## Kutuphane olarak (sunucusuz)
```cpp
#include "Engine.hpp"
using namespace litedb;

Engine e("data.db");
{
  auto tx = e.transaction();            // belge + graf + zaman serisi atomik
  e.docs.put("users", "u1", R"({"name":"Ayse","age":30})");
  e.graph.addNode("u1", "Person");
  e.ts.write("login", TimeSeriesStore::nowMs(), 1);
  tx.commit();
}
e.cache.set("session:u1", "abc", 60000);  // 60 sn TTL
```
`Engine` tek thread'den kullanilmalidir. Cok thread'li kullanim icin `SafeEngine`:
```cpp
#include "server/SafeEngine.hpp"
SafeEngineOptions o; o.path = "data.db"; o.readers = 4;
SafeEngine eng(o);
eng.write([&](Engine& e) { e.docs.put("users", "u1", R"({"a":1})"); });   // commit'ten sonra doner
auto doc = eng.read([&](Engine& e) { return e.docs.get("users", "u1"); });
eng.cache().set("k", "v", 1000);
```

## Yazma darbogazi nasil genisletildi
SQLite ayni anda tek yazici kabul eder; bu kalkmaz, ama maliyeti paylasilir:
- **Tek yazici thread + grup commit:** esamanli `write()` cagrilari kuyrukta birikir,
  yazici hepsini TEK transaction'da calistirir. Her gorev kendi SAVEPOINT'indedir:
  biri hata verirse yalniz o geri alinir. `--durable` (synchronous=FULL) ile fsync
  maliyeti de yazmalar arasinda bolusulur.
- **Okuma havuzu:** `query_only` WAL baglantilari; okumalar yaziciyi ve birbirini
  engellemez. `write()` dondukten sonra baslayan her `read()` o yazmayi gorur.
- **Geri basinc:** kuyruk `--max-queue` degerini asarsa API 503 doner.
- Onbellek SQLite'a ve yazici kuyruguna girmez, kendi mutex'iyle thread-safe'tir.

Olcum (`build/bench_writes`, 16 thread, bu test ortaminin diski; kendi diskinizde
tekrarlayin):

| mod | naif mutex | grup commit | kazanc |
|---|---|---|---|
| synchronous=NORMAL | ~37.5 bin yazma/sn | ~55.9 bin yazma/sn | 1.5x |
| synchronous=FULL (`--durable`) | ~4.6 bin yazma/sn | ~20.4 bin yazma/sn | 4.5x |

Kazanc, esamanli yazici sayisi arttikca ve diskte fsync pahali oldukca buyur.

## Bilinmesi gerekenler
- `SafeEngine::write()` icinde `Engine::transaction()` kullanma ve `write()` icinden
  `write()` cagirma (yazici zaten transaction acmistir; ikincisi kilitlenir, algilanir).
- Onbellek SQLite transaction'larina katilmaz, kalici degildir; gorev icinde cache'e
  yazma geri alinmaz.
- Zaman serisinde anahtar `(seri, zaman)`: ayni milisaniyedeki iki nokta birbirinin
  uzerine yazar. Zaman damgalari negatif olmamali.
- Belge sorgusu tek alan esitligidir; graf gezintisi dugum basina bir SQL calistirir
  (binlerce dugum rahat, milyonlarca yavas).
- Varsayilan `synchronous=NORMAL`: elektrik kesilirse son commit'ler kaybolabilir
  (dosya bozulmaz). Kritik veri icin `--durable`.
- Yedek icin calisirken `sqlite3 veri.db ".backup yedek.db"` veya `VACUUM INTO`;
  `-wal` dosyasini tek basina kopyalamayin. Replikasyon/yuksek erisilebilirlik yoktur.
