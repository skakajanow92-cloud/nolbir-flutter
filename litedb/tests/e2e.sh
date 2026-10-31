#!/usr/bin/env bash
# Uctan uca test: litedbd'yi baslatir, curl ve litedb-cli ile dener.
# Kullanim: tests/e2e.sh <litedbd yolu> <litedb-cli yolu>
set -u
D="$(readlink -f "$1")"
C="$(readlink -f "$2")"
TMP="$(mktemp -d)"
PIDS=()
cleanup() { for p in "${PIDS[@]:-}"; do [ -n "$p" ] && kill "$p" 2>/dev/null; done; rm -rf "$TMP"; }
trap cleanup EXIT

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); }
bad() { FAIL=$((FAIL+1)); echo "BASARISIZ: $1"; [ -n "${2:-}" ] && echo "    $2"; }
eq()  { if [ "$2" = "$3" ]; then ok; else bad "$1" "beklenen='$3' gelen='$2'"; fi; }
has() { case "$2" in *"$3"*) ok;; *) bad "$1" "'$3' bulunamadi: $2";; esac; }
jget() { python3 -c 'import sys,json; d=json.loads(sys.argv[1]); print(eval(sys.argv[2]))' "$1" "$2" 2>/dev/null; }

start() {  # start <ad> [sunucu argumanlari...]  -> PID, PORT
  local name="$1"; shift
  LOG="$TMP/$name.log"
  "$D" --db "$TMP/$name.db" --port 0 "$@" >"$LOG" 2>&1 &
  PID=$!; PIDS+=("$PID")
  for _ in $(seq 1 100); do
    PORT=$(grep -o 'http://127.0.0.1:[0-9]*' "$LOG" 2>/dev/null | head -1 | sed 's/.*://')
    [ -n "$PORT" ] && return 0
    sleep 0.05
  done
  bad "sunucu basladi ($name)" "$(cat "$LOG")"; return 1
}
req() {  # req METOD YOL [curl argumanlari]  -> CODE, BODY
  local m="$1" p="$2"; shift 2
  CODE=$(curl -s -o "$TMP/body" -w '%{http_code}' -X "$m" "http://127.0.0.1:$PORT$p" "$@")
  BODY=$(cat "$TMP/body")
}

echo "== sunucu 1 (belirtecsiz, loopback)"
start s1 --max-body-mb 1 || exit 1
export LITEDB_URL="http://127.0.0.1:$PORT"
unset LITEDB_TOKEN

req GET /healthz;                         eq "healthz" "$CODE" 200
curl -s -D "$TMP/h" -o "$TMP/ui" "http://127.0.0.1:$PORT/"
has "arayuz basligi" "$(cat "$TMP/ui")" "<title>litedb</title>"
has "arayuz CSP" "$(cat "$TMP/h")" "Content-Security-Policy"
req GET /nope;                            eq "404" "$CODE" 404
req GET /api/nope;                        eq "api 404" "$CODE" 404

echo "== belgeler"
req PUT /api/docs/users/u1 --data-binary '{"name":"Ayşe","age":30,"adres":{"sehir":"Aşkabat"}}'
eq "doc put" "$CODE" 200
req PUT /api/docs/users/u2 --data-binary '{"name":"Can","age":25,"tags":["a","b"]}'
req GET /api/docs/users/u1;               eq "doc get" "$CODE" 200
eq "doc icerik" "$(jget "$BODY" "d['adres']['sehir']")" "Aşkabat"
req GET /api/docs/users/yok;              eq "doc 404" "$CODE" 404
req GET "/api/docs/users";                eq "doc list" "$(jget "$BODY" "d['total']")" 2
req GET "/api/docs/users?field=age&value=30"
eq "doc find int" "$(jget "$BODY" "d['items'][0]['id']")" u1
req GET "/api/docs/users?field=name&value=Can&type=string"
eq "doc find string" "$(jget "$BODY" "d['count']")" 1
req GET "/api/docs/users?field=adres.sehir&value=A%C5%9Fkabat"
eq "doc find nested+utf8" "$(jget "$BODY" "d['count']")" 1
req GET "/api/docs/users?field=bad%20field&value=1"
eq "doc find gecersiz alan" "$CODE" 400
req POST "/api/indexes/docs?field=age";   eq "index" "$CODE" 200
req PUT /api/docs/users/bad --data-binary '{gecersiz';    eq "gecersiz JSON" "$CODE" 400
printf '{"a":"\xff\xfe"}' > "$TMP/badutf"
req PUT /api/docs/users/bad --data-binary "@$TMP/badutf"; eq "gecersiz UTF-8" "$CODE" 400
req PUT /api/docs/users/bad;              eq "bos govde" "$CODE" 400
req GET /api/docs;                        eq "koleksiyonlar" "$(jget "$BODY" "d['collections'][0]['name']")" users
req PUT "/api/docs/a%2Fb/x%2Fy" --data-binary '{"ok":1}'
req GET "/api/docs/a%2Fb/x%2Fy";          eq "yuzde-kodlu id" "$CODE" 200
req DELETE /api/docs/users/u2;            eq "doc del" "$(jget "$BODY" "d['deleted']")" True
req DELETE /api/docs/users/u2;            eq "doc del tekrar" "$(jget "$BODY" "d['deleted']")" False
req PATCH /api/docs/users/u1;             eq "405" "$CODE" 405

echo "== graf"
req PUT /api/graph/nodes/alice --data-binary '{"label":"Person","props":{"age":30}}'; eq "node put" "$CODE" 200
req PUT /api/graph/nodes/bob   --data-binary '{"label":"Person"}'
req PUT /api/graph/nodes/carol --data-binary '{"label":"Person"}'
req PUT /api/graph/nodes/x --data-binary '[1]';           eq "node govde nesne degil" "$CODE" 400
req PUT /api/graph/edges --data-binary '{"src":"alice","rel":"FOLLOWS","dst":"bob"}'; eq "edge put" "$CODE" 200
req PUT /api/graph/edges --data-binary '{"src":"bob","rel":"FOLLOWS","dst":"carol"}'
req PUT /api/graph/edges --data-binary '{"src":"alice","rel":"FOLLOWS","dst":"yok"}'; eq "edge FK" "$CODE" 409
req GET /api/graph/nodes/alice;           eq "node get" "$(jget "$BODY" "d['props']['age']")" 30
req GET "/api/graph/nodes?label=Person";  eq "label listesi" "$(jget "$BODY" "len(d['ids'])")" 3
req GET "/api/graph/nodes/alice/neighbors?dir=out"; eq "komsu" "$(jget "$BODY" "d['ids']")" "['bob']"
req GET "/api/graph/nodes/bob/neighbors?dir=both"; eq "komsu both" "$(jget "$BODY" "sorted(d['ids'])")" "['alice', 'carol']"
req GET "/api/graph/traverse?start=alice&depth=5"; eq "traverse" "$(jget "$BODY" "[v['id'] for v in d['visits']]")" "['bob', 'carol']"
req GET "/api/graph/path?from=alice&to=carol";     eq "path" "$(jget "$BODY" "d['path']")" "['alice', 'bob', 'carol']"
req GET "/api/graph/path?from=carol&to=alice";     eq "path yok" "$(jget "$BODY" "d['found']")" False
req GET "/api/graph/traverse?start=alice&depth=99"; eq "depth sinirli" "$CODE" 400
req DELETE /api/graph/nodes/bob
req GET "/api/graph/edges?src=alice&rel=FOLLOWS&dst=bob"; eq "cascade" "$(jget "$BODY" "d['exists']")" False

echo "== zaman serisi"
NOW=$(($(date +%s) * 1000))
req POST /api/ts/cpu --data-binary "{\"points\":[{\"ts\":$((NOW-3000)),\"value\":10,\"tags\":{\"host\":\"a\"}},{\"ts\":$((NOW-2000)),\"value\":20,\"tags\":{\"host\":\"b\"}},{\"ts\":$((NOW-1000)),\"value\":30,\"tags\":{\"host\":\"a\"}}]}"
eq "ts batch" "$(jget "$BODY" "d['written']")" 3
req POST /api/ts/cpu --data-binary '{"value":40}';        eq "ts tek (simdi)" "$CODE" 200
req GET "/api/ts/cpu?from=$((NOW-5000))";                 eq "ts range" "$(jget "$BODY" "d['count']")" 4
req GET "/api/ts/cpu?from=$((NOW-5000))&tag=host&tagValue=a"; eq "ts tag" "$(jget "$BODY" "d['count']")" 2
req GET "/api/ts/cpu/stats?from=$((NOW-5000))";           eq "ts stats" "$(jget "$BODY" "d['sum']")" 100
req GET "/api/ts/cpu/downsample?from=$((NOW-5000))&bucket=60000&agg=max"; eq "ts downsample" "$CODE" 200
req GET /api/ts/cpu/latest;                               eq "ts latest" "$(jget "$BODY" "d['value']")" 40
req POST /api/ts/cpu --data-binary '{"value":"abc"}';     eq "ts gecersiz deger" "$CODE" 400
req POST /api/ts/cpu --data-binary '{"value":1,"ts":-5}'; eq "ts negatif zaman" "$CODE" 400
req GET /api/ts;                                          eq "seri listesi" "$(jget "$BODY" "d['series'][0]['name']")" cpu
req DELETE "/api/ts/cpu?before=$((NOW-1500))";            eq "ts prune" "$(jget "$BODY" "d['deleted']")" 2

echo "== onbellek"
req PUT "/api/cache/session%3Au1?ttl=60000" --data-binary 'abc'; eq "cache set" "$CODE" 200
req GET "/api/cache/session%3Au1";        eq "cache get" "$(jget "$BODY" "d['value']")" abc
has "cache ttl" "$(jget "$BODY" "d['ttl']")" ""
req POST "/api/cache/n/incr?delta=5";     eq "incr" "$(jget "$BODY" "d['value']")" 5
req POST "/api/cache/n/incr";             eq "incr 2" "$(jget "$BODY" "d['value']")" 6
req POST "/api/cache/session%3Au1/incr";  eq "incr tamsayi degil" "$CODE" 409
req POST "/api/cache/short/expire?ttl=1"; eq "expire yok" "$CODE" 404
req PUT "/api/cache/short?ttl=50" --data-binary 'x'
sleep 0.15
req GET /api/cache/short;                 eq "ttl doldu" "$CODE" 404
req DELETE /api/cache/n;                  eq "cache del" "$(jget "$BODY" "d['deleted']")" True

echo "== atomik islem (tx)"
req POST /api/tx --data-binary '{"ops":[{"op":"doc.put","coll":"tx","id":"a","doc":{"v":1}},{"op":"graph.node","id":"t1","label":"T"},{"op":"graph.node","id":"t2","label":"T"},{"op":"graph.edge","src":"t1","rel":"R","dst":"t2"},{"op":"ts.write","series":"txs","value":1.5}]}'
eq "tx basarili" "$(jget "$BODY" "d['applied']")" 5
req POST /api/tx --data-binary '{"ops":[{"op":"doc.put","coll":"tx","id":"b","doc":{"v":2}},{"op":"graph.edge","src":"t1","rel":"R","dst":"YOK"}]}'
eq "tx FK hatasi" "$CODE" 409
has "tx hata op indeksi" "$BODY" "op[1]"
req GET /api/docs/tx/b;                   eq "tx geri alindi (belge yok)" "$CODE" 404
req GET /api/docs/tx/a;                   eq "onceki tx kalici" "$CODE" 200
req POST /api/tx --data-binary '{"ops":[{"op":"bilinmeyen"}]}'; eq "tx bilinmeyen op" "$CODE" 400

echo "== guvenlik"
req GET /api/stats -H 'Host: evil.example.com';           eq "Host dogrulama" "$CODE" 403
req GET /api/stats -H "Origin: http://evil.example.com";  eq "Origin (CSRF)" "$CODE" 403
req PUT /api/docs/x/y -H "Origin: http://evil.example.com" -H 'Content-Type: text/plain' --data-binary '{}'
eq "Origin PUT" "$CODE" 403
req GET /api/stats -H "Origin: http://127.0.0.1:$PORT";   eq "ayni Origin" "$CODE" 200
req POST /api/tx -H 'Transfer-Encoding: chunked' --data-binary '{}'; eq "chunked" "$CODE" 501
head -c 2000000 /dev/zero | tr '\0' 'a' > "$TMP/big"
req PUT /api/docs/big/b -H 'Expect:' --data-binary "@$TMP/big";      eq "govde siniri 413" "$CODE" 413
printf 'GET /%0.sA' $(seq 1 3) >/dev/null
CODE=$(curl -s -o /dev/null -w '%{http_code}' -H "X-Big: $(head -c 20000 /dev/zero | tr '\0' 'a')" "http://127.0.0.1:$PORT/healthz")
eq "baslik siniri 431" "$CODE" 431
req GET "/api/docs/%ZZ";                  eq "gecersiz yuzde" "$CODE" 400
req GET "/api/cache/$(head -c 2000 /dev/zero | tr '\0' 'k')"; eq "uzun anahtar" "$CODE" 400

echo "== eszamanli yazma (HTTP)"
seq 1 200 | xargs -P 24 -I{} curl -s -o /dev/null -X PUT "http://127.0.0.1:$PORT/api/docs/par/k{}" --data-binary '{"n":{}}'
req GET "/api/docs/par?limit=1";          eq "200 esamanli belge" "$(jget "$BODY" "d['total']")" 200
# Yazici kuyruguna girip basarisiz olan gorevler: edge FK (409) ve tx FK (409) = 2.
# Gecersiz JSON/UTF-8 ve bos govde kuyruga girmeden 400 ile reddedilir (sayilmaz).
req GET "/api/stats?counts=1";            eq "yazici basarisiz gorev sayisi" "$(jget "$BODY" "d['writer']['failed']")" 2
has "stats counts" "$BODY" '"counts"'

echo "== CLI"
eq "cli put" "$($C -c doc put users cli1 '{"name":"Zeynep","age":41}')" '{"ok":true}'
eq "cli get" "$($C -c doc get users cli1)" '{"name":"Zeynep","age":41}'
has "cli find" "$($C -c doc find users age 41)" cli1
$C doc get users yokyok >"$TMP/o" 2>"$TMP/e"; RC=$?
eq "cli hata kodu" "$RC" 1
has "cli hata mesaji" "$(cat "$TMP/e")" "404"
$C cache set k1 merhaba --ttl 60s >/dev/null
eq "cli cache get" "$($C cache get k1)" merhaba
eq "cli incr" "$($C -c cache incr sayac 5)" '{"value":5}'
$C graph node put a1 Person '{"x":1}' >/dev/null; $C graph node put a2 Person >/dev/null
$C graph edge put a1 KNOWS a2 >/dev/null
eq "cli path" "$($C -c graph path a1 a2)" '{"found":true,"path":["a1","a2"]}'
$C ts write temp 21.5 --tags '{"oda":"salon"}' >/dev/null
has "cli ts latest" "$($C -c ts latest temp)" '"value":21.5'
has "cli ts range" "$($C -c ts range temp --from -1h)" '"count":1'
has "cli ts down" "$($C -c ts down temp --bucket 1m --from -1h)" '"buckets"'
echo '{"ops":[{"op":"doc.put","coll":"clitx","id":"1","doc":{"a":1}}]}' > "$TMP/tx.json"
has "cli tx" "$($C -c tx "$TMP/tx.json")" '"applied":1'
OUT=$(printf 'doc get users cli1\ncache get k1\nexit\n' | $C -c)
has "cli repl" "$OUT" Zeynep
has "cli repl 2" "$OUT" merhaba
has "cli stats" "$($C -c stats --counts)" '"counts"'
LITEDB_URL=http://127.0.0.1:1 $C health >/dev/null 2>&1; eq "cli baglanti hatasi kodu" "$?" 1
LITEDB_URL=https://example.com $C health >/dev/null 2>&1; eq "cli https reddi" "$?" 2
$C doc nope >/dev/null 2>&1; eq "cli kullanim hatasi kodu" "$?" 2
has "cli help" "$($C help)" "litedb-cli"

echo "== kalicilik ve kapanis"
kill -TERM "$PID"; wait "$PID" 2>/dev/null; RC=$?
eq "SIGTERM cikis kodu" "$RC" 0
has "kapanis mesaji" "$(cat "$LOG")" "kapatildi"
cp "$TMP/s1.db" "$TMP/s1b.db" 2>/dev/null
start s1 --max-body-mb 1 || exit 1   # ayni db dosyasi
export LITEDB_URL="http://127.0.0.1:$PORT"
req GET /api/docs/users/u1;               eq "yeniden baslatma: belge kalici" "$CODE" 200
req GET "/api/docs/par?limit=1";          eq "yeniden baslatma: 200 belge" "$(jget "$BODY" "d['total']")" 200
req GET /api/cache/k1;                    eq "onbellek kalici degil" "$CODE" 404

echo "== sunucu 2 (belirtecli)"
TOKEN="test-belirteci-uzun-ve-rastgele-1234"
start s2 --token "$TOKEN" || exit 1
req GET /api/stats;                       eq "belirtecsiz 401" "$CODE" 401
req GET /api/stats -H "Authorization: Bearer yanlis"; eq "yanlis belirtec 401" "$CODE" 401
req GET /api/stats -H "Authorization: Bearer $TOKEN"; eq "dogru belirtec" "$CODE" 200
req GET /healthz;                         eq "healthz belirtecsiz" "$CODE" 200
curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/" | grep -q 200 && ok || bad "arayuz belirtecsiz acilir"
export LITEDB_URL="http://127.0.0.1:$PORT"
# /healthz bilerek belirtecsiz acik; korunan bir uc (stats) belirtecsiz reddedilmeli.
$C stats >/dev/null 2>&1;                 RC=$?; eq "cli belirtecsiz basarisiz" "$RC" 1
LITEDB_TOKEN="$TOKEN" $C -c stats >/dev/null 2>&1; eq "cli LITEDB_TOKEN" "$?" 0
$C --token "$TOKEN" -c stats >/dev/null 2>&1;      eq "cli --token" "$?" 0

echo "== disa acik dinleme"
"$D" --db "$TMP/x.db" --host 0.0.0.0 --port 0 >"$TMP/x.log" 2>&1; RC=$?
eq "belirtecsiz 0.0.0.0 reddedilir" "$RC" 2
has "red mesaji" "$(cat "$TMP/x.log")" "Reddedildi"

echo
echo "gecen: $PASS  basarisiz: $FAIL"
[ "$FAIL" -eq 0 ]
