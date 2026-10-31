#pragma once
static const char* const kUiHtml = R"LITEDB_UI(<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>litedb</title>
<style>
:root{--bg:#f6f7f9;--panel:#fff;--ink:#1b1f24;--mute:#667085;--line:#e3e6ea;--accent:#2563eb;--accent-ink:#fff;--ok:#16a34a;--bad:#dc2626;--code:#f1f3f6}
@media (prefers-color-scheme:dark){:root{--bg:#0f1216;--panel:#171b21;--ink:#e6e9ee;--mute:#98a2b3;--line:#262c35;--accent:#5b8def;--accent-ink:#0b1220;--ok:#34d399;--bad:#f87171;--code:#1e242c}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);font:14px/1.5 system-ui,-apple-system,Segoe UI,Roboto,sans-serif}
header{display:flex;flex-wrap:wrap;gap:12px;align-items:center;padding:12px 16px;background:var(--panel);border-bottom:1px solid var(--line)}
header h1{font-size:16px;margin:0;letter-spacing:.2px}
.dot{width:9px;height:9px;border-radius:50%;background:var(--mute);display:inline-block;margin-right:6px}
.dot.ok{background:var(--ok)}.dot.bad{background:var(--bad)}
.grow{flex:1}
nav{display:flex;gap:4px;padding:8px 16px 0;overflow-x:auto}
nav button{border:1px solid transparent;border-bottom:none;background:none;color:var(--mute);padding:8px 14px;border-radius:8px 8px 0 0;cursor:pointer;font:inherit}
nav button.on{background:var(--panel);color:var(--ink);border-color:var(--line);font-weight:600}
main{background:var(--panel);border-top:1px solid var(--line);padding:16px;min-height:60vh}
.grid{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:16px}
@media (max-width:820px){.grid{grid-template-columns:minmax(0,1fr)}}
fieldset{border:1px solid var(--line);border-radius:10px;margin:0 0 14px;padding:12px}
legend{padding:0 6px;color:var(--mute);font-size:12px;text-transform:uppercase;letter-spacing:.6px}
label{display:block;font-size:12px;color:var(--mute);margin:8px 0 3px}
input,textarea,select{width:100%;padding:7px 9px;border:1px solid var(--line);border-radius:7px;background:var(--bg);color:var(--ink);font:inherit}
textarea{min-height:110px;font-family:ui-monospace,Menlo,Consolas,monospace;font-size:13px}
.row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.row>*{flex:1;min-width:110px}
.row>button{flex:0 0 auto}
button.btn{padding:7px 13px;border-radius:7px;border:1px solid var(--line);background:var(--bg);color:var(--ink);cursor:pointer;font:inherit}
button.btn.pri{background:var(--accent);color:var(--accent-ink);border-color:var(--accent)}
button.btn.danger{color:var(--bad)}
button.chip{padding:3px 10px;border-radius:99px;border:1px solid var(--line);background:var(--bg);color:var(--ink);cursor:pointer;font:inherit;margin:0 6px 6px 0}
.actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:10px}
pre{background:var(--code);border-radius:8px;padding:10px;margin:8px 0 0;overflow:auto;max-height:420px;font:12.5px/1.45 ui-monospace,Menlo,Consolas,monospace;white-space:pre-wrap;word-break:break-word}
pre.err{color:var(--bad)}
.muted{color:var(--mute)}
.item{display:flex;gap:10px;align-items:baseline;padding:6px 8px;border-bottom:1px solid var(--line);cursor:pointer}
.item:hover{background:var(--code)}
.item b{min-width:80px}.item code{color:var(--mute);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;flex:1}
.cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(170px,1fr));gap:10px}
.card{border:1px solid var(--line);border-radius:10px;padding:10px 12px}
.card .k{font-size:12px;color:var(--mute)}.card .v{font-size:22px;font-weight:600;font-variant-numeric:tabular-nums}
svg.chart{width:100%;height:220px;background:var(--code);border-radius:8px}
svg.chart text{fill:var(--mute);font-size:11px}
svg.chart polyline{fill:none;stroke:var(--accent);stroke-width:1.6}
svg.chart line{stroke:var(--line)}
.hint{font-size:12px;color:var(--mute);margin-top:6px}
</style>
</head>
<body>
<header>
  <h1>litedb</h1>
  <span><span id="dot" class="dot"></span><span id="status" class="muted">bağlanıyor…</span></span>
  <span class="grow"></span>
  <label style="margin:0;display:flex;gap:6px;align-items:center">Belirteç
    <input id="token" type="password" autocomplete="off" placeholder="gerekirse" style="width:180px"></label>
</header>
<nav id="tabs"></nav>
<main id="view"></main>

<script>
"use strict";
const $ = (s, el = document) => el.querySelector(s);
const enc = encodeURIComponent;

function h(tag, props, ...kids) {
  const el = document.createElement(tag);
  for (const [k, v] of Object.entries(props || {})) {
    if (k.startsWith("on")) el.addEventListener(k.slice(2), v);
    else if (k === "class") el.className = v;
    else if (k in el) el[k] = v;
    else el.setAttribute(k, v);
  }
  for (const c of kids.flat()) if (c != null) el.append(c.nodeType ? c : document.createTextNode(String(c)));
  return el;
}

let token = "";
try { token = sessionStorage.getItem("litedb-token") || ""; } catch (e) {}
$("#token").value = token;
$("#token").addEventListener("change", e => {
  token = e.target.value.trim();
  try { sessionStorage.setItem("litedb-token", token); } catch (e) {}
  ping(); show(current);
});

async function api(method, path, body) {
  const headers = {};
  if (token) headers["Authorization"] = "Bearer " + token;
  if (body !== undefined) headers["Content-Type"] = "application/json";
  const res = await fetch(path, { method, headers, body });
  const text = await res.text();
  let data = text;
  try { data = JSON.parse(text); } catch (e) {}
  if (!res.ok) throw new Error(res.status === 401 ? "Yetkisiz: sağ üstten belirteci girin" : (data && data.error) || ("HTTP " + res.status));
  return data;
}

function out() { return h("pre", { class: "muted" }, "sonuç burada görünür"); }
function fmt(d) { return typeof d === "string" ? d : JSON.stringify(d, null, 2); }
async function run(pre, fn) {
  try { const d = await fn(); pre.className = ""; pre.textContent = fmt(d); return d; }
  catch (e) { pre.className = "err"; pre.textContent = e.message; }
}
function field(label, el) { return h("div", {}, h("label", {}, label), el); }
function inp(ph, val) { return h("input", { placeholder: ph || "", value: val || "" }); }
function btn(text, fn, cls) { return h("button", { class: "btn " + (cls || ""), onclick: fn }, text); }
function parseJSON(text, what) {
  try { return JSON.parse(text); } catch (e) { throw new Error(what + ": geçersiz JSON"); }
}
// "now", "-5m", "-2h", "-1d" ya da epoch milisaniye
function parseTime(s, def) {
  s = (s || "").trim();
  if (!s) return def;
  if (s === "now") return Date.now();
  const m = /^-(\d+)([smhd])$/.exec(s);
  if (m) return Date.now() - Number(m[1]) * { s: 1e3, m: 6e4, h: 36e5, d: 864e5 }[m[2]];
  if (/^\d+$/.test(s)) return Number(s);
  throw new Error("zaman: now, -5m, -2h, -1d ya da epoch ms");
}

/* ---------------- Belgeler ---------------- */
function tabDocs(root) {
  const coll = inp("koleksiyon", "users"), id = inp("id"), body = h("textarea", {}, '{\n  "ad": "Ayşe",\n  "yas": 30\n}');
  const field_ = inp("alan (ör. yas, adres.sehir)"), value = inp("değer"), type = h("select", {}, ["auto", "string", "int", "real"].map(t => h("option", {}, t)));
  const colls = h("div", {}), items = h("div", {}), o = out();
  const path = () => `/api/docs/${enc(coll.value)}/${enc(id.value)}`;
  async function refresh() {
    try {
      const d = await api("GET", "/api/docs");
      colls.replaceChildren(...(d.collections.length ? d.collections.map(c => h("button", { class: "chip", onclick: () => { coll.value = c.name; list(); } }, `${c.name} (${c.count})`)) : [h("span", { class: "muted" }, "henüz koleksiyon yok")]));
    } catch (e) { colls.textContent = e.message; }
  }
  function render(d) {
    items.replaceChildren(...d.items.map(it => h("div", { class: "item", onclick: () => { id.value = it.id; body.value = JSON.stringify(it.doc, null, 2); } }, h("b", {}, it.id), h("code", {}, JSON.stringify(it.doc)))));
    if (!d.items.length) items.textContent = "sonuç yok";
  }
  const list = () => run(o, async () => { const d = await api("GET", `/api/docs/${enc(coll.value)}?limit=200`); render(d); return { toplam: d.total, gösterilen: d.count }; });
  const search = () => run(o, async () => { const d = await api("GET", `/api/docs/${enc(coll.value)}?field=${enc(field_.value)}&value=${enc(value.value)}&type=${type.value}&limit=200`); render(d); return { bulunan: d.count }; });
  root.append(h("div", { class: "grid" },
    h("div", {},
      h("fieldset", {}, h("legend", {}, "Belge"),
        h("div", { class: "row" }, field("Koleksiyon", coll), field("Id", id)),
        field("JSON gövde", body),
        h("div", { class: "actions" },
          btn("Kaydet", () => run(o, async () => { const r = await api("PUT", path(), body.value); refresh(); return r; }), "pri"),
          btn("Getir", () => run(o, async () => { const d = await api("GET", path()); body.value = JSON.stringify(d, null, 2); return d; })),
          btn("Sil", () => run(o, async () => { const r = await api("DELETE", path()); refresh(); return r; }), "danger")),
        o),
      h("fieldset", {}, h("legend", {}, "Alana göre ara"),
        h("div", { class: "row" }, field("Alan", field_), field("Değer", value), field("Tür", type), btn("Ara", search)),
        h("div", { class: "hint" }, "Sık aranan alanlar için indeks oluşturmak sorguyu hızlandırır."),
        h("div", { class: "actions" }, btn("Bu alana indeks oluştur", () => run(o, () => api("POST", `/api/indexes/docs?field=${enc(field_.value)}`)))))),
    h("div", {},
      h("fieldset", {}, h("legend", {}, "Koleksiyonlar"), colls, h("div", { class: "actions" }, btn("Seçili koleksiyonu listele", list))),
      h("fieldset", {}, h("legend", {}, "Belgeler (satıra tıkla → düzenle)"), items))));
  refresh();
}

/* ---------------- Graf ---------------- */
function tabGraph(root) {
  const nid = inp("id"), label = inp("etiket (ör. Person)"), nprops = h("textarea", { style: "min-height:60px" }, "{}");
  const src = inp("kaynak"), rel = inp("ilişki (ör. FOLLOWS)"), dst = inp("hedef"), eprops = h("textarea", { style: "min-height:60px" }, "{}");
  const qid = inp("dugum id"), qrel = inp("ilişki (boş = hepsi)"), dir = h("select", {}, ["out", "in", "both"].map(t => h("option", {}, t))), depth = inp("derinlik", "3"), to = inp("hedef (yol için)");
  const o = out();
  const qs = () => `rel=${enc(qrel.value)}&dir=${dir.value}`;
  root.append(h("div", { class: "grid" },
    h("div", {},
      h("fieldset", {}, h("legend", {}, "Düğüm"),
        h("div", { class: "row" }, field("Id", nid), field("Etiket", label)),
        field("Özellikler (JSON)", nprops),
        h("div", { class: "actions" },
          btn("Kaydet", () => run(o, () => api("PUT", `/api/graph/nodes/${enc(nid.value)}`, JSON.stringify({ label: label.value, props: parseJSON(nprops.value, "özellikler") }))), "pri"),
          btn("Getir", () => run(o, () => api("GET", `/api/graph/nodes/${enc(nid.value)}`))),
          btn("Etikete göre listele", () => run(o, () => api("GET", `/api/graph/nodes?label=${enc(label.value)}`))),
          btn("Sil", () => run(o, () => api("DELETE", `/api/graph/nodes/${enc(nid.value)}`)), "danger"))),
      h("fieldset", {}, h("legend", {}, "Kenar"),
        h("div", { class: "row" }, field("Kaynak", src), field("İlişki", rel), field("Hedef", dst)),
        field("Özellikler (JSON)", eprops),
        h("div", { class: "hint" }, "Kenar eklemeden önce iki düğüm de var olmalı."),
        h("div", { class: "actions" },
          btn("Kaydet", () => run(o, () => api("PUT", "/api/graph/edges", JSON.stringify({ src: src.value, rel: rel.value, dst: dst.value, props: parseJSON(eprops.value, "özellikler") }))), "pri"),
          btn("Var mı?", () => run(o, () => api("GET", `/api/graph/edges?src=${enc(src.value)}&rel=${enc(rel.value)}&dst=${enc(dst.value)}`))),
          btn("Sil", () => run(o, () => api("DELETE", `/api/graph/edges?src=${enc(src.value)}&rel=${enc(rel.value)}&dst=${enc(dst.value)}`)), "danger")))),
    h("div", {},
      h("fieldset", {}, h("legend", {}, "Sorgu"),
        h("div", { class: "row" }, field("Düğüm", qid), field("İlişki", qrel), field("Yön", dir)),
        h("div", { class: "row" }, field("Derinlik", depth), field("Hedef (en kısa yol)", to)),
        h("div", { class: "actions" },
          btn("Kenarlar", () => run(o, () => api("GET", `/api/graph/nodes/${enc(qid.value)}/edges?${qs()}`))),
          btn("Komşular", () => run(o, () => api("GET", `/api/graph/nodes/${enc(qid.value)}/neighbors?${qs()}`))),
          btn("Gezin (BFS)", () => run(o, () => api("GET", `/api/graph/traverse?start=${enc(qid.value)}&depth=${enc(depth.value)}&${qs()}`))),
          btn("En kısa yol", () => run(o, () => api("GET", `/api/graph/path?from=${enc(qid.value)}&to=${enc(to.value)}&depth=${enc(depth.value)}&${qs()}`))))),
      o)));
}

/* ---------------- Zaman serisi ---------------- */
function chart(points) {
  const NS = "http://www.w3.org/2000/svg", W = 600, H = 220, P = { l: 48, r: 10, t: 10, b: 22 };
  const svg = document.createElementNS(NS, "svg");
  svg.setAttribute("viewBox", `0 0 ${W} ${H}`); svg.setAttribute("class", "chart");
  svg.setAttribute("role", "img"); svg.setAttribute("aria-label", "zaman serisi grafiği");
  if (!points.length) return svg;
  const xs = points.map(p => p.x), ys = points.map(p => p.y);
  const x0 = Math.min(...xs), x1 = Math.max(...xs), y0 = Math.min(...ys), y1 = Math.max(...ys);
  const sx = x => P.l + (x1 === x0 ? 0.5 : (x - x0) / (x1 - x0)) * (W - P.l - P.r);
  const sy = y => H - P.b - (y1 === y0 ? 0.5 : (y - y0) / (y1 - y0)) * (H - P.t - P.b);
  const add = (tag, attrs, text) => { const e = document.createElementNS(NS, tag); for (const k in attrs) e.setAttribute(k, attrs[k]); if (text != null) e.textContent = text; svg.append(e); };
  for (const f of [0, 0.5, 1]) { const y = y0 + (y1 - y0) * f; add("line", { x1: P.l, x2: W - P.r, y1: sy(y), y2: sy(y) }); add("text", { x: 4, y: sy(y) + 4 }, +y.toPrecision(4)); }
  add("text", { x: P.l, y: H - 6 }, new Date(x0).toLocaleTimeString());
  add("text", { x: W - P.r, y: H - 6, "text-anchor": "end" }, new Date(x1).toLocaleTimeString());
  add("polyline", { points: points.map(p => `${sx(p.x).toFixed(1)},${sy(p.y).toFixed(1)}`).join(" ") });
  return svg;
}
function tabTs(root) {
  const name = inp("seri", "cpu"), val = inp("değer"), tags = h("textarea", { style: "min-height:50px" }, "{}");
  const from = inp("başlangıç", "-1h"), to = inp("bitiş", "now"), agg = h("select", {}, ["ham", "avg", "min", "max", "sum", "count", "first", "last"].map(t => h("option", {}, t))), bucket = inp("kova (ms)", "60000");
  const series = h("div", {}), chartBox = h("div", {}), o = out();
  async function refresh() {
    try {
      const d = await api("GET", "/api/ts");
      series.replaceChildren(...(d.series.length ? d.series.map(s => h("button", { class: "chip", onclick: () => { name.value = s.name; query(); } }, `${s.name} (${s.count})`)) : [h("span", { class: "muted" }, "henüz seri yok")]));
    } catch (e) { series.textContent = e.message; }
  }
  async function query() {
    await run(o, async () => {
      const f = parseTime(from.value, 0), t = parseTime(to.value, Date.now()) + 1;
      let pts, d;
      if (agg.value === "ham") { d = await api("GET", `/api/ts/${enc(name.value)}?from=${f}&to=${t}&limit=5000`); pts = d.points.map(p => ({ x: p.ts, y: p.value })); }
      else { d = await api("GET", `/api/ts/${enc(name.value)}/downsample?from=${f}&to=${t}&bucket=${enc(bucket.value)}&agg=${agg.value}`); pts = d.buckets.map(b => ({ x: b.start, y: b.value })); }
      chartBox.replaceChildren(chart(pts));
      return d;
    });
  }
  root.append(h("div", { class: "grid" },
    h("div", {},
      h("fieldset", {}, h("legend", {}, "Seriler"), series),
      h("fieldset", {}, h("legend", {}, "Nokta yaz"),
        h("div", { class: "row" }, field("Seri", name), field("Değer", val)),
        field("Etiketler (JSON)", tags),
        h("div", { class: "hint" }, "Zaman damgası sunucu saatidir (ms)."),
        h("div", { class: "actions" },
          btn("Yaz", () => run(o, async () => { const r = await api("POST", `/api/ts/${enc(name.value)}`, JSON.stringify({ value: Number(val.value), tags: parseJSON(tags.value, "etiketler") })); refresh(); return r; }), "pri"),
          btn("Son nokta", () => run(o, () => api("GET", `/api/ts/${enc(name.value)}/latest`))),
          btn("Seriyi sil", () => run(o, async () => { const r = await api("DELETE", `/api/ts/${enc(name.value)}`); refresh(); return r; }), "danger")))),
    h("div", {},
      h("fieldset", {}, h("legend", {}, "Sorgu"),
        h("div", { class: "row" }, field("Başlangıç", from), field("Bitiş", to)),
        h("div", { class: "row" }, field("Toplama", agg), field("Kova (ms)", bucket), btn("Çiz", query)),
        h("div", { class: "hint" }, "Zaman: now, -5m, -2h, -1d veya epoch ms."),
        chartBox, o))));
  refresh();
}

/* ---------------- Önbellek ---------------- */
function tabCache(root) {
  const key = inp("anahtar"), val = h("textarea", { style: "min-height:70px" }), ttl = inp("TTL ms (0 = süresiz)", "0"), o = out();
  const k = () => `/api/cache/${enc(key.value)}`;
  root.append(h("div", { class: "grid" },
    h("div", {}, h("fieldset", {}, h("legend", {}, "Anahtar"),
      field("Anahtar", key), field("Değer", val), field("TTL (ms)", ttl),
      h("div", { class: "actions" },
        btn("Ayarla", () => run(o, () => api("PUT", `${k()}?ttl=${enc(ttl.value || 0)}`, val.value)), "pri"),
        btn("Getir", () => run(o, async () => { const d = await api("GET", k()); val.value = d.value; return d; })),
        btn("Artır (+1)", () => run(o, () => api("POST", `${k()}/incr?delta=1`))),
        btn("Sil", () => run(o, () => api("DELETE", k())), "danger")))),
    h("div", {}, h("fieldset", {}, h("legend", {}, "Önbellek"),
      h("div", { class: "actions" }, btn("İstatistik", () => run(o, () => api("GET", "/api/cache"))), btn("Tümünü temizle", () => { if (confirm("Tüm önbellek silinsin mi?")) run(o, () => api("DELETE", "/api/cache")); }, "danger")),
      h("div", { class: "hint" }, "Önbellek bellekte durur, yeniden başlatmada silinir."), o))));
}

/* ---------------- Durum ---------------- */
let timer = null;
function tabStats(root) {
  const box = h("div", { class: "cards" }), err = h("div", { class: "muted" });
  root.append(box, err, h("div", { class: "hint" }, "Ortalama toplu iş = bir commit'te birleşen ortalama yazma sayısı. Yüksekse grup commit çalışıyor demektir."));
  const card = (k, v) => h("div", { class: "card" }, h("div", { class: "k" }, k), h("div", { class: "v" }, v));
  async function load() {
    try {
      const s = await api("GET", "/api/stats?counts=1"); err.textContent = "";
      const n = x => Number(x).toLocaleString("tr-TR", { maximumFractionDigits: 2 });
      box.replaceChildren(
        card("Yazma işlemi", n(s.writer.ops)), card("Commit sayısı", n(s.writer.batches)), card("Ortalama toplu iş", n(s.writer.avgBatch)),
        card("En büyük toplu iş", n(s.writer.maxBatch)), card("Kuyrukta", n(s.writer.queued)), card("Hatalı yazma", n(s.writer.failed)),
        card("Okuyucu (meşgul/toplam)", `${s.readers.busy}/${s.readers.total}`),
        card("Belge", n(s.counts.docs)), card("Düğüm", n(s.counts.nodes)), card("Kenar", n(s.counts.edges)), card("Zaman serisi noktası", n(s.counts.points)),
        card("Önbellek girdisi", n(s.cache.entries)), card("Önbellek isabet", n(s.cache.hits)), card("Önbellek ıskalama", n(s.cache.misses)));
    } catch (e) { err.textContent = e.message; }
  }
  load(); timer = setInterval(load, 2000);
}

/* ---------------- İskelet ---------------- */
const TABS = [["Belgeler", tabDocs], ["Graf", tabGraph], ["Zaman serisi", tabTs], ["Önbellek", tabCache], ["Durum", tabStats]];
let current = 0;
function show(i) {
  current = i;
  if (timer) { clearInterval(timer); timer = null; }
  [...$("#tabs").children].forEach((b, j) => b.classList.toggle("on", j === i));
  const v = $("#view"); v.replaceChildren(); TABS[i][1](v);
}
$("#tabs").append(...TABS.map(([t], i) => h("button", { onclick: () => show(i) }, t)));

async function ping() {
  try { await api("GET", "/api/stats"); $("#dot").className = "dot ok"; $("#status").textContent = "bağlı"; }
  catch (e) { $("#dot").className = "dot bad"; $("#status").textContent = e.message; }
}
ping(); setInterval(ping, 10000); show(0);
</script>
</body>
</html>
)LITEDB_UI";
