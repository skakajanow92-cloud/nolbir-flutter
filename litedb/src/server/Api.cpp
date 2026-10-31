#include "server/Api.hpp"

#include <algorithm>
#include <charconv>
#include <climits>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <variant>

#include "server/Json.hpp"

namespace litedb {

namespace {

constexpr size_t kMaxName = 256;
constexpr size_t kMaxKey = 1024;
constexpr size_t kMaxOps = 10000;
constexpr size_t kMaxPathBudget = 256;

struct HttpError {
  int status;
  std::string msg;
  std::vector<std::pair<std::string, std::string>> headers;
};

[[noreturn]] void fail(int status, std::string msg) {
  throw HttpError{status, std::move(msg), {}};
}

Response jsonResp(int status, std::string body) {
  Response r;
  r.status = status;
  r.body = std::move(body);
  return r;
}
Response okResp() { return jsonResp(200, "{\"ok\":true}"); }
Response errResp(int status, const std::string& msg) {
  return jsonResp(status, "{\"error\":" + json::quote(msg) + "}");
}

// ---- Parametre yardimcilari ----

bool parseLL(const std::string& s, long long& out) {
  if (s.empty()) return false;
  const char* b = s.data();
  const char* e = b + s.size();
  if (*b == '+') ++b;
  auto r = std::from_chars(b, e, out);
  return r.ec == std::errc{} && r.ptr == e;
}

bool parseDouble(const std::string& s, double& out) {
  if (s.empty()) return false;
  char* end = nullptr;
  out = std::strtod(s.c_str(), &end);
  return end == s.c_str() + s.size() && std::isfinite(out);
}

std::string qget(const Request& r, const char* k, const std::string& def = "") {
  auto it = r.query.find(k);
  return it == r.query.end() ? def : it->second;
}

std::string qneed(const Request& r, const char* k) {
  auto it = r.query.find(k);
  if (it == r.query.end() || it->second.empty())
    fail(400, std::string("'") + k + "' parametresi gerekli");
  return it->second;
}

long long qint(const Request& r, const char* k, long long def, long long lo,
               long long hi) {
  auto it = r.query.find(k);
  if (it == r.query.end() || it->second.empty()) return def;
  long long v;
  if (!parseLL(it->second, v))
    fail(400, std::string("'") + k + "' tam sayi olmali");
  if (v < lo || v > hi)
    fail(400, std::string("'") + k + "' " + std::to_string(lo) + ".." +
                  std::to_string(hi) + " araliginda olmali");
  return v;
}

Direction qdir(const Request& r) {
  std::string d = qget(r, "dir", "out");
  if (d == "out") return Direction::Out;
  if (d == "in") return Direction::In;
  if (d == "both") return Direction::Both;
  fail(400, "dir: out, in veya both olmali");
}

// type: auto|string|int|real. auto: tam sayi gibi gorunuyorsa int, ondalikli
// ise real, aksi halde string.
template <class V>
V typedValue(const std::string& v, const std::string& type) {
  if (type == "string") return V(v);
  if (type == "int") {
    long long n;
    if (!parseLL(v, n)) fail(400, "deger tam sayi degil");
    return V(n);
  }
  if (type == "real") {
    double d;
    if (!parseDouble(v, d)) fail(400, "deger sayi degil");
    return V(d);
  }
  if (type != "auto" && !type.empty()) fail(400, "type: auto, string, int veya real");
  long long n;
  if (parseLL(v, n)) return V(n);
  double d;
  if (parseDouble(v, d)) return V(d);
  return V(v);
}

std::string checkedName(const std::string& s, const char* what,
                        size_t maxLen = kMaxName) {
  if (s.empty()) fail(400, std::string(what) + " bos olamaz");
  if (s.size() > maxLen)
    fail(400, std::string(what) + " cok uzun (en fazla " + std::to_string(maxLen) + ")");
  if (s.find('\0') != std::string::npos) fail(400, std::string(what) + " gecersiz");
  if (!json::validUtf8(s)) fail(400, std::string(what) + " gecerli UTF-8 degil");
  return s;
}

// ---- Govde (JSON) yardimcilari ----

json::Value parseBody(const Request& r) {
  if (r.body.empty()) fail(400, "govde bos");
  if (!json::validUtf8(r.body)) fail(400, "govde gecerli UTF-8 degil");
  return json::parse(r.body);
}

const json::Value& needObject(const json::Value& v, const char* what = "govde") {
  if (!v.isObject()) fail(400, std::string(what) + " bir JSON nesnesi olmali");
  return v;
}

std::string jstr(const json::Value& o, const char* key, bool required,
                 const std::string& def = "") {
  const json::Value* v = o.find(key);
  if (!v || v->isNull()) {
    if (required) fail(400, std::string("'") + key + "' alani gerekli");
    return def;
  }
  if (!v->isString()) fail(400, std::string("'") + key + "' metin olmali");
  return v->str;
}

double jnum(const json::Value& o, const char* key, bool required, double def = 0) {
  const json::Value* v = o.find(key);
  if (!v || v->isNull()) {
    if (required) fail(400, std::string("'") + key + "' alani gerekli");
    return def;
  }
  if (!v->isNumber()) fail(400, std::string("'") + key + "' sayi olmali");
  return v->asDouble();
}

long long jts(const json::Value& o, const char* key, bool required, long long def) {
  const json::Value* v = o.find(key);
  if (!v || v->isNull()) {
    if (required) fail(400, std::string("'") + key + "' alani gerekli");
    return def;
  }
  if (!v->isNumber() || !v->isInt) fail(400, std::string("'") + key + "' tam sayi olmali");
  if (v->i < 0) fail(400, std::string("'") + key + "' negatif olamaz");
  return v->i;
}

// Nesne alanini (yoksa "{}") kompakt JSON metni olarak dondurur.
std::string jobj(const json::Value& o, const char* key) {
  const json::Value* v = o.find(key);
  if (!v || v->isNull()) return "{}";
  if (!v->isObject()) fail(400, std::string("'") + key + "' bir nesne olmali");
  return json::dump(*v);
}

// ---- Hata siniflandirma ----

std::pair<int, std::string> classify(const std::string& m) {
  if (m.find("FOREIGN KEY") != std::string::npos)
    return {409, "iliskili dugum bulunamadi"};
  if (m.find("json_valid") != std::string::npos) return {400, "gecersiz JSON"};
  if (m.find("constraint failed") != std::string::npos)
    return {400, "kisit ihlali: gecersiz deger"};
  for (const char* p : {"gecersiz", "bos alan", "bos etiket", "bucketMs"})
    if (m.rfind(p, 0) == 0) return {400, m};
  return {500, "ic hata"};
}

bool constEq(const std::string& a, const std::string& b) {
  size_t n = std::max(a.size(), b.size());
  unsigned char diff = a.size() == b.size() ? 0 : 1;
  for (size_t i = 0; i < n; ++i) {
    unsigned char x = i < a.size() ? static_cast<unsigned char>(a[i]) : 0;
    unsigned char y = i < b.size() ? static_cast<unsigned char>(b[i]) : 0;
    diff |= static_cast<unsigned char>(x ^ y);
  }
  return diff == 0;
}

std::vector<std::string> splitPath(const std::string& raw) {
  std::vector<std::string> out;
  std::string p = raw;
  if (p.size() > 1 && p.back() == '/') p.pop_back();
  size_t pos = 1;  // bastaki '/'
  while (pos <= p.size()) {
    size_t e = p.find('/', pos);
    std::string part = p.substr(pos, e == std::string::npos ? e : e - pos);
    std::string dec;
    if (!urlDecode(part, false, dec)) fail(400, "gecersiz yuzde kodlamasi");
    out.push_back(std::move(dec));
    if (e == std::string::npos) break;
    pos = e + 1;
  }
  if (out.size() == 1 && out[0].empty()) out.clear();
  return out;
}

Response methodNotAllowed() { return errResp(405, "yontem desteklenmiyor"); }

std::string agg2s(Agg a) {
  switch (a) {
    case Agg::Avg: return "avg";
    case Agg::Min: return "min";
    case Agg::Max: return "max";
    case Agg::Sum: return "sum";
    case Agg::Count: return "count";
    case Agg::First: return "first";
    case Agg::Last: return "last";
  }
  return "avg";
}

Agg parseAgg(const std::string& s) {
  for (Agg a : {Agg::Avg, Agg::Min, Agg::Max, Agg::Sum, Agg::Count, Agg::First,
                Agg::Last})
    if (agg2s(a) == s) return a;
  fail(400, "agg: avg, min, max, sum, count, first veya last");
}

std::string pointJson(const TimeSeriesStore::Point& p) {
  return "{\"ts\":" + std::to_string(p.ts) + ",\"value\":" + json::number(p.value) +
         ",\"tags\":" + p.tags + "}";
}

std::string edgeJson(const GraphStore::Edge& e) {
  return "{\"src\":" + json::quote(e.src) + ",\"rel\":" + json::quote(e.rel) +
         ",\"dst\":" + json::quote(e.dst) + ",\"props\":" + e.props + "}";
}

std::string strList(const std::vector<std::string>& v) {
  std::string o = "[";
  for (size_t i = 0; i < v.size(); ++i) {
    if (i) o += ",";
    o += json::quote(v[i]);
  }
  return o + "]";
}

}  // namespace

Api::Api(SafeEngine& engine, ApiOptions opt) : eng_(engine), opt_(std::move(opt)) {}

bool Api::admitPath(const std::string& kind, const std::string& key) {
  std::lock_guard<std::mutex> lk(pathMu_);
  size_t n = 0;
  for (const auto& p : seenPaths_) {
    if (p.first != kind) continue;
    if (p.second == key) return true;
    ++n;
  }
  return n < kMaxPathBudget;
}

void Api::notePath(const std::string& kind, const std::string& key) {
  std::lock_guard<std::mutex> lk(pathMu_);
  for (const auto& p : seenPaths_)
    if (p.first == kind && p.second == key) return;
  seenPaths_.emplace_back(kind, key);
}

// ---------------------------------------------------------------- guvenlik

void Api::guard(const Request& r) {
  std::string host = r.header("host");
  if (opt_.hostCheck) {
    std::string h = host;
    if (!h.empty() && h[0] == '[') {
      size_t e = h.find(']');
      if (e != std::string::npos) h = h.substr(0, e + 1);
    } else {
      size_t c = h.rfind(':');
      if (c != std::string::npos) h = h.substr(0, c);
    }
    bool ok = false;
    for (const auto& a : opt_.allowedHosts)
      if (a == h) ok = true;
    if (!ok) fail(403, "Host basligi izinli degil");
  }
  if (opt_.token.empty()) {
    // Belirteci olmayan (yalniz yerel) kullanimda baska sitelerin tarayicidan
    // yazma yapmasini (CSRF) onlemek icin Origin ile Host eslesmeli.
    std::string origin = r.header("origin");
    if (!origin.empty()) {
      size_t p = origin.find("://");
      std::string oh = p == std::string::npos ? origin : origin.substr(p + 3);
      if (oh != host) fail(403, "farkli kaynak (Origin) reddedildi");
    }
    return;
  }
  const std::string pre = "Bearer ";
  std::string a = r.header("authorization");
  if (a.rfind(pre, 0) != 0 || !constEq(a.substr(pre.size()), opt_.token)) {
    HttpError e{401, "yetkisiz: gecerli bir Bearer belirteci gerekli", {}};
    e.headers.emplace_back("WWW-Authenticate", "Bearer");
    throw e;
  }
}

// ---------------------------------------------------------------- ana giris

Response Api::handle(const Request& req) {
  Response resp;
  try {
    if (req.path == "/favicon.ico") {
      resp.status = 204;
    } else if (req.path == "/healthz") {
      resp = jsonResp(200, "{\"ok\":true}");
    } else if (req.path == "/" || req.path == "/index.html") {
      if (req.method != "GET") return methodNotAllowed();
      resp.contentType = "text/html; charset=utf-8";
      resp.body = opt_.uiHtml ? opt_.uiHtml : "<h1>litedb</h1>";
      resp.headers.emplace_back(
          "Content-Security-Policy",
          "default-src 'none'; script-src 'unsafe-inline'; style-src "
          "'unsafe-inline'; connect-src 'self'; img-src data:; base-uri 'none'; "
          "form-action 'none'; frame-ancestors 'none'");
      resp.headers.emplace_back("X-Frame-Options", "DENY");
    } else if (req.path.rfind("/api/", 0) == 0 || req.path == "/api") {
      guard(req);
      resp = route(req, splitPath(req.path));
    } else {
      resp = errResp(404, "bulunamadi");
    }
  } catch (const HttpError& e) {
    resp = errResp(e.status, e.msg);
    for (const auto& h : e.headers) resp.headers.push_back(h);
  } catch (const json::ParseError& e) {
    resp = errResp(400, e.what());
  } catch (const QueueFullError&) {
    resp = errResp(503, "sunucu mesgul: yazma kuyrugu dolu");
    resp.headers.emplace_back("Retry-After", "1");
  } catch (const ShuttingDownError&) {
    resp = errResp(503, "sunucu kapaniyor");
  } catch (const SqliteError& e) {
    auto c = classify(e.what());
    if (c.first >= 500) std::fprintf(stderr, "litedbd: SQLite hatasi: %s\n", e.what());
    resp = errResp(c.first, c.second);
  } catch (const std::invalid_argument& e) {
    resp = errResp(409, e.what());
  } catch (const std::overflow_error& e) {
    resp = errResp(400, e.what());
  } catch (const std::exception& e) {
    std::fprintf(stderr, "litedbd: beklenmeyen hata: %s\n", e.what());
    resp = errResp(500, "ic hata");
  }
  resp.headers.emplace_back("Cache-Control", "no-store");
  resp.headers.emplace_back("Referrer-Policy", "no-referrer");
  return resp;
}

Response Api::route(const Request& r, const std::vector<std::string>& s) {
  if (s.size() < 2) return errResp(404, "bulunamadi");
  const std::string& area = s[1];
  if (area == "docs") return docs(r, s);
  if (area == "graph") return graph(r, s);
  if (area == "ts") return ts(r, s);
  if (area == "cache") return cache(r, s);
  if (area == "tx" && s.size() == 2) return tx(r);
  if (area == "stats" && s.size() == 2) return stats(r);
  if (area == "indexes" && s.size() == 3 && s[2] == "docs") {
    if (r.method != "POST") return methodNotAllowed();
    std::string field = qneed(r, "field");
    if (!admitPath("doc", field)) fail(400, "cok fazla farkli alan yolu");
    eng_.write([&](Engine& e) { e.docs.createIndex(field); });
    notePath("doc", field);
    return okResp();
  }
  return errResp(404, "bulunamadi");
}

// ---------------------------------------------------------------- belgeler

Response Api::docs(const Request& r, const std::vector<std::string>& s) {
  const std::string& m = r.method;
  if (s.size() == 2) {
    if (m != "GET") return methodNotAllowed();
    return jsonResp(200, eng_.read([&](Engine& e) {
      Statement st(e.db(),
                   "SELECT coll, COUNT(*) FROM docs GROUP BY coll ORDER BY coll "
                   "LIMIT 1000");
      std::string o = "{\"collections\":[";
      bool first = true;
      while (st.step()) {
        if (!first) o += ",";
        first = false;
        o += "{\"name\":" + json::quote(st.text(0)) +
             ",\"count\":" + std::to_string(st.int64(1)) + "}";
      }
      return o + "]}";
    }));
  }

  std::string coll = checkedName(s[2], "koleksiyon");
  if (s.size() == 3) {
    if (m != "GET") return methodNotAllowed();
    int limit = static_cast<int>(qint(r, "limit", 100, 1, 10000));
    std::string field = qget(r, "field");
    bool search = !field.empty();
    DocumentStore::Value val = 0LL;
    if (search) {
      if (!admitPath("doc", field)) fail(400, "cok fazla farkli alan yolu");
      auto it = r.query.find("value");
      if (it == r.query.end()) fail(400, "'value' parametresi gerekli");
      val = typedValue<DocumentStore::Value>(it->second, qget(r, "type", "auto"));
    }
    std::string out = eng_.read([&](Engine& e) {
      std::vector<DocumentStore::Doc> docs =
          search ? e.docs.find(coll, field, val, limit) : e.docs.all(coll, limit);
      std::string o = "{";
      if (!search) o += "\"total\":" + std::to_string(e.docs.count(coll)) + ",";
      o += "\"count\":" + std::to_string(docs.size()) + ",\"items\":[";
      for (size_t i = 0; i < docs.size(); ++i) {
        if (i) o += ",";
        o += "{\"id\":" + json::quote(docs[i].id) + ",\"doc\":" + docs[i].body + "}";
      }
      return o + "]}";
    });
    if (search) notePath("doc", field);
    return jsonResp(200, std::move(out));
  }

  if (s.size() != 4) return errResp(404, "bulunamadi");
  std::string id = checkedName(s[3], "id");
  if (m == "PUT") {
    // Govde once burada dogrulanir (UTF-8 + sozdizimi); SQLite'in CHECK'i ikinci
    // savunma hattidir.
    json::Value doc = parseBody(r);
    (void)doc;
    eng_.write([&](Engine& e) { e.docs.put(coll, id, r.body); });
    return okResp();
  }
  if (m == "GET") {
    auto doc = eng_.read([&](Engine& e) { return e.docs.get(coll, id); });
    if (!doc) return errResp(404, "belge bulunamadi");
    return jsonResp(200, *doc);
  }
  if (m == "DELETE") {
    bool removed = eng_.write([&](Engine& e) { return e.docs.remove(coll, id); });
    return jsonResp(200, std::string("{\"deleted\":") + (removed ? "true" : "false") + "}");
  }
  return methodNotAllowed();
}

// ---------------------------------------------------------------- graf

Response Api::graph(const Request& r, const std::vector<std::string>& s) {
  const std::string& m = r.method;
  if (s.size() < 3) return errResp(404, "bulunamadi");
  const std::string& what = s[2];

  if (what == "nodes") {
    if (s.size() == 3) {
      if (m == "GET") {
        std::string label = qneed(r, "label");
        auto ids = eng_.read([&](Engine& e) { return e.graph.nodesByLabel(label); });
        return jsonResp(200, "{\"ids\":" + strList(ids) + "}");
      }
      if (m == "DELETE") return methodNotAllowed();
      return methodNotAllowed();
    }
    std::string id = checkedName(s[3], "dugum id");
    if (s.size() == 4) {
      if (m == "PUT") {
        json::Value b = parseBody(r);
        needObject(b);
        std::string label = jstr(b, "label", false);
        std::string props = jobj(b, "props");
        eng_.write([&](Engine& e) { e.graph.addNode(id, label, props); });
        return okResp();
      }
      if (m == "GET") {
        auto n = eng_.read([&](Engine& e) { return e.graph.getNode(id); });
        if (!n) return errResp(404, "dugum bulunamadi");
        return jsonResp(200, "{\"id\":" + json::quote(n->id) + ",\"label\":" +
                                 json::quote(n->label) + ",\"props\":" + n->props + "}");
      }
      if (m == "DELETE") {
        bool removed = eng_.write([&](Engine& e) { return e.graph.removeNode(id); });
        return jsonResp(200, std::string("{\"deleted\":") + (removed ? "true" : "false") + "}");
      }
      return methodNotAllowed();
    }
    if (s.size() == 5 && m == "GET" && (s[4] == "edges" || s[4] == "neighbors")) {
      std::string rel = qget(r, "rel");
      Direction dir = qdir(r);
      if (s[4] == "edges") {
        auto edges = eng_.read([&](Engine& e) { return e.graph.edgesOf(id, rel, dir); });
        std::string o = "{\"edges\":[";
        for (size_t i = 0; i < edges.size(); ++i) {
          if (i) o += ",";
          o += edgeJson(edges[i]);
        }
        return jsonResp(200, o + "]}");
      }
      auto ids = eng_.read([&](Engine& e) { return e.graph.neighbors(id, rel, dir); });
      return jsonResp(200, "{\"ids\":" + strList(ids) + "}");
    }
    return errResp(404, "bulunamadi");
  }

  if (what == "edges" && s.size() == 3) {
    if (m == "PUT") {
      json::Value b = parseBody(r);
      needObject(b);
      std::string src = checkedName(jstr(b, "src", true), "src");
      std::string rel = checkedName(jstr(b, "rel", true), "rel");
      std::string dst = checkedName(jstr(b, "dst", true), "dst");
      std::string props = jobj(b, "props");
      eng_.write([&](Engine& e) { e.graph.addEdge(src, rel, dst, props); });
      return okResp();
    }
    std::string src = checkedName(qneed(r, "src"), "src");
    std::string rel = checkedName(qneed(r, "rel"), "rel");
    std::string dst = checkedName(qneed(r, "dst"), "dst");
    if (m == "DELETE") {
      bool removed = eng_.write([&](Engine& e) { return e.graph.removeEdge(src, rel, dst); });
      return jsonResp(200, std::string("{\"deleted\":") + (removed ? "true" : "false") + "}");
    }
    if (m == "GET") {
      bool has = eng_.read([&](Engine& e) { return e.graph.hasEdge(src, rel, dst); });
      return jsonResp(200, std::string("{\"exists\":") + (has ? "true" : "false") + "}");
    }
    return methodNotAllowed();
  }

  if (what == "traverse" && s.size() == 3) {
    if (m != "GET") return methodNotAllowed();
    std::string start = checkedName(qneed(r, "start"), "start");
    int depth = static_cast<int>(qint(r, "depth", 3, 1, 32));
    std::string rel = qget(r, "rel");
    Direction dir = qdir(r);
    auto visits = eng_.read(
        [&](Engine& e) { return e.graph.traverse(start, depth, rel, dir); });
    std::string o = "{\"visits\":[";
    for (size_t i = 0; i < visits.size(); ++i) {
      if (i) o += ",";
      o += "{\"id\":" + json::quote(visits[i].id) +
           ",\"depth\":" + std::to_string(visits[i].depth) + "}";
    }
    return jsonResp(200, o + "]}");
  }

  if (what == "path" && s.size() == 3) {
    if (m != "GET") return methodNotAllowed();
    std::string from = checkedName(qneed(r, "from"), "from");
    std::string to = checkedName(qneed(r, "to"), "to");
    int depth = static_cast<int>(qint(r, "depth", 10, 1, 32));
    std::string rel = qget(r, "rel");
    Direction dir = qdir(r);
    auto path = eng_.read(
        [&](Engine& e) { return e.graph.shortestPath(from, to, depth, rel, dir); });
    return jsonResp(200, "{\"found\":" + std::string(path.empty() ? "false" : "true") +
                             ",\"path\":" + strList(path) + "}");
  }
  return errResp(404, "bulunamadi");
}

// ---------------------------------------------------------------- zaman serisi

namespace {
TimeSeriesStore::Point parsePoint(const json::Value& p, long long nowMs) {
  needObject(p, "nokta");
  TimeSeriesStore::Point pt;
  pt.ts = jts(p, "ts", false, nowMs);
  pt.value = jnum(p, "value", true);
  pt.tags = jobj(p, "tags");
  return pt;
}
}  // namespace

Response Api::ts(const Request& r, const std::vector<std::string>& s) {
  const std::string& m = r.method;
  if (s.size() == 2) {
    if (m != "GET") return methodNotAllowed();
    return jsonResp(200, eng_.read([&](Engine& e) {
      std::string o = "{\"series\":[";
      auto names = e.ts.listSeries();
      for (size_t i = 0; i < names.size(); ++i) {
        if (i) o += ",";
        o += "{\"name\":" + json::quote(names[i]) +
             ",\"count\":" + std::to_string(e.ts.count(names[i])) + "}";
      }
      return o + "]}";
    }));
  }
  std::string series = checkedName(s[2], "seri");

  if (s.size() == 3) {
    if (m == "POST") {
      json::Value b = parseBody(r);
      needObject(b);
      long long now = TimeSeriesStore::nowMs();
      std::vector<TimeSeriesStore::Point> pts;
      const json::Value* arr = b.find("points");
      if (arr) {
        if (!arr->isArray() || arr->arr.empty()) fail(400, "'points' bos olmayan bir dizi olmali");
        if (arr->arr.size() > 100000) fail(400, "en fazla 100000 nokta");
        for (const auto& p : arr->arr) pts.push_back(parsePoint(p, now));
      } else {
        pts.push_back(parsePoint(b, now));
      }
      eng_.write([&](Engine& e) {
        if (pts.size() == 1)
          e.ts.write(series, pts[0].ts, pts[0].value, pts[0].tags);
        else
          e.ts.writeBatch(series, pts);
      });
      return jsonResp(200, "{\"ok\":true,\"written\":" + std::to_string(pts.size()) + "}");
    }
    if (m == "GET") {
      long long from = qint(r, "from", 0, 0, LLONG_MAX);
      long long to = qint(r, "to", LLONG_MAX, 0, LLONG_MAX);
      int limit = static_cast<int>(qint(r, "limit", 1000, 1, 100000));
      std::string tag = qget(r, "tag");
      TimeSeriesStore::Value tv = 0LL;
      if (!tag.empty()) {
        if (!admitPath("tag", tag)) fail(400, "cok fazla farkli etiket anahtari");
        auto it = r.query.find("tagValue");
        if (it == r.query.end()) fail(400, "'tagValue' parametresi gerekli");
        tv = typedValue<TimeSeriesStore::Value>(it->second, qget(r, "tagType", "auto"));
      }
      auto pts = eng_.read([&](Engine& e) {
        return tag.empty() ? e.ts.range(series, from, to, limit)
                           : e.ts.rangeByTag(series, from, to, tag, tv, limit);
      });
      if (!tag.empty()) notePath("tag", tag);
      std::string o = "{\"count\":" + std::to_string(pts.size()) + ",\"points\":[";
      for (size_t i = 0; i < pts.size(); ++i) {
        if (i) o += ",";
        o += pointJson(pts[i]);
      }
      return jsonResp(200, o + "]}");
    }
    if (m == "DELETE") {
      std::string before = qget(r, "before");
      long long n;
      if (!before.empty()) {
        long long ts;
        if (!parseLL(before, ts) || ts < 0) fail(400, "'before' negatif olmayan tam sayi olmali");
        n = eng_.write([&](Engine& e) { return e.ts.deleteBefore(series, ts); });
      } else {
        n = eng_.write([&](Engine& e) { return e.ts.removeSeries(series); });
      }
      return jsonResp(200, "{\"deleted\":" + std::to_string(n) + "}");
    }
    return methodNotAllowed();
  }

  if (s.size() == 4 && m == "GET") {
    const std::string& what = s[3];
    if (what == "latest") {
      auto p = eng_.read([&](Engine& e) { return e.ts.latest(series); });
      if (!p) return errResp(404, "nokta yok");
      return jsonResp(200, pointJson(*p));
    }
    long long from = qint(r, "from", 0, 0, LLONG_MAX);
    long long to = qint(r, "to", LLONG_MAX, 0, LLONG_MAX);
    if (what == "stats") {
      auto st = eng_.read([&](Engine& e) { return e.ts.stats(series, from, to); });
      if (!st) return jsonResp(200, "{\"count\":0}");
      return jsonResp(200, "{\"count\":" + std::to_string(st->count) +
                               ",\"min\":" + json::number(st->min) +
                               ",\"max\":" + json::number(st->max) +
                               ",\"sum\":" + json::number(st->sum) +
                               ",\"avg\":" + json::number(st->avg) + "}");
    }
    if (what == "downsample") {
      long long bucket = qint(r, "bucket", 0, 1, LLONG_MAX);
      if (bucket == 0) fail(400, "'bucket' (ms) parametresi gerekli");
      Agg agg = parseAgg(qget(r, "agg", "avg"));
      auto bs = eng_.read(
          [&](Engine& e) { return e.ts.downsample(series, from, to, bucket, agg); });
      std::string o = "{\"buckets\":[";
      for (size_t i = 0; i < bs.size(); ++i) {
        if (i) o += ",";
        o += "{\"start\":" + std::to_string(bs[i].start) +
             ",\"value\":" + json::number(bs[i].value) +
             ",\"count\":" + std::to_string(bs[i].count) + "}";
      }
      return jsonResp(200, o + "]}");
    }
  }
  return errResp(404, "bulunamadi");
}

// ---------------------------------------------------------------- onbellek

Response Api::cache(const Request& r, const std::vector<std::string>& s) {
  const std::string& m = r.method;
  CacheStore& c = eng_.cache();
  if (s.size() == 2) {
    if (m == "DELETE") {
      c.clear();
      return okResp();
    }
    if (m == "GET") {
      auto st = c.stats();
      return jsonResp(200, "{\"entries\":" + std::to_string(st.entries) +
                               ",\"bytes\":" + std::to_string(st.bytes) +
                               ",\"hits\":" + std::to_string(st.hits) +
                               ",\"misses\":" + std::to_string(st.misses) +
                               ",\"evictions\":" + std::to_string(st.evictions) +
                               ",\"expired\":" + std::to_string(st.expired) + "}");
    }
    return methodNotAllowed();
  }
  std::string key = checkedName(s[2], "anahtar", kMaxKey);
  if (s.size() == 3) {
    if (m == "PUT") {
      long long ttl = qint(r, "ttl", 0, 0, LLONG_MAX / 2);
      bool stored = c.set(key, r.body, ttl);
      return jsonResp(200, std::string("{\"ok\":true,\"stored\":") + (stored ? "true" : "false") + "}");
    }
    if (m == "GET") {
      auto v = c.get(key);
      if (!v) return errResp(404, "anahtar yok");
      return jsonResp(200, "{\"key\":" + json::quote(key) + ",\"value\":" + json::quote(*v) +
                               ",\"ttl\":" + std::to_string(c.ttl(key)) + "}");
    }
    if (m == "DELETE") {
      bool d = c.del(key);
      return jsonResp(200, std::string("{\"deleted\":") + (d ? "true" : "false") + "}");
    }
    return methodNotAllowed();
  }
  if (s.size() == 4 && m == "POST") {
    if (s[3] == "incr") {
      long long delta = qint(r, "delta", 1, LLONG_MIN / 2, LLONG_MAX / 2);
      return jsonResp(200, "{\"value\":" + std::to_string(c.incr(key, delta)) + "}");
    }
    if (s[3] == "expire") {
      long long ttl = qint(r, "ttl", 0, 0, LLONG_MAX / 2);
      if (!c.expire(key, ttl)) return errResp(404, "anahtar yok");
      return okResp();
    }
  }
  if (s.size() == 4 && m == "GET" && s[3] == "ttl")
    return jsonResp(200, "{\"ttl\":" + std::to_string(c.ttl(key)) + "}");
  return errResp(404, "bulunamadi");
}

// ---------------------------------------------------------------- islem (tx)

Response Api::tx(const Request& r) {
  if (r.method != "POST") return methodNotAllowed();
  json::Value b = parseBody(r);
  needObject(b);
  const json::Value* ops = b.find("ops");
  if (!ops || !ops->isArray() || ops->arr.empty())
    fail(400, "'ops' bos olmayan bir dizi olmali");
  if (ops->arr.size() > kMaxOps) fail(400, "en fazla " + std::to_string(kMaxOps) + " islem");

  struct Op {
    std::string kind, a, b2, c, props;  // anlami islem turune gore
    long long ts = 0;
    double value = 0;
  };
  std::vector<Op> list;
  long long now = TimeSeriesStore::nowMs();
  for (size_t i = 0; i < ops->arr.size(); ++i) {
    const json::Value& o = ops->arr[i];
    try {
      needObject(o, "islem");
      Op op;
      op.kind = jstr(o, "op", true);
      if (op.kind == "doc.put") {
        op.a = checkedName(jstr(o, "coll", true), "coll");
        op.b2 = checkedName(jstr(o, "id", true), "id");
        const json::Value* d = o.find("doc");
        if (!d) fail(400, "'doc' alani gerekli");
        op.props = json::dump(*d);
      } else if (op.kind == "doc.del") {
        op.a = checkedName(jstr(o, "coll", true), "coll");
        op.b2 = checkedName(jstr(o, "id", true), "id");
      } else if (op.kind == "graph.node") {
        op.a = checkedName(jstr(o, "id", true), "id");
        op.b2 = jstr(o, "label", false);
        op.props = jobj(o, "props");
      } else if (op.kind == "graph.node.del") {
        op.a = checkedName(jstr(o, "id", true), "id");
      } else if (op.kind == "graph.edge") {
        op.a = checkedName(jstr(o, "src", true), "src");
        op.b2 = checkedName(jstr(o, "rel", true), "rel");
        op.c = checkedName(jstr(o, "dst", true), "dst");
        op.props = jobj(o, "props");
      } else if (op.kind == "graph.edge.del") {
        op.a = checkedName(jstr(o, "src", true), "src");
        op.b2 = checkedName(jstr(o, "rel", true), "rel");
        op.c = checkedName(jstr(o, "dst", true), "dst");
      } else if (op.kind == "ts.write") {
        op.a = checkedName(jstr(o, "series", true), "series");
        op.ts = jts(o, "ts", false, now);
        op.value = jnum(o, "value", true);
        op.props = jobj(o, "tags");
      } else {
        fail(400, "bilinmeyen islem: " + op.kind);
      }
      list.push_back(std::move(op));
    } catch (const HttpError& e) {
      fail(e.status, "op[" + std::to_string(i) + "]: " + e.msg);
    }
  }

  eng_.write([&](Engine& e) {
    size_t i = 0;
    try {
      for (; i < list.size(); ++i) {
        const Op& op = list[i];
        if (op.kind == "doc.put") e.docs.put(op.a, op.b2, op.props);
        else if (op.kind == "doc.del") e.docs.remove(op.a, op.b2);
        else if (op.kind == "graph.node") e.graph.addNode(op.a, op.b2, op.props);
        else if (op.kind == "graph.node.del") e.graph.removeNode(op.a);
        else if (op.kind == "graph.edge") e.graph.addEdge(op.a, op.b2, op.c, op.props);
        else if (op.kind == "graph.edge.del") e.graph.removeEdge(op.a, op.b2, op.c);
        else if (op.kind == "ts.write") e.ts.write(op.a, op.ts, op.value, op.props);
      }
    } catch (const SqliteError& ex) {
      // Tum gorev (tx) geri alinir; hangi islemin hata verdigini bildir.
      auto c = classify(ex.what());
      if (c.first >= 500) std::fprintf(stderr, "litedbd: SQLite hatasi: %s\n", ex.what());
      throw HttpError{c.first, "op[" + std::to_string(i) + "]: " + c.second, {}};
    }
  });
  return jsonResp(200, "{\"ok\":true,\"applied\":" + std::to_string(list.size()) + "}");
}

// ---------------------------------------------------------------- istatistik

Response Api::stats(const Request& r) {
  if (r.method != "GET") return methodNotAllowed();
  auto w = eng_.stats();
  auto c = eng_.cache().stats();
  std::string o = "{\"writer\":{\"batches\":" + std::to_string(w.batches) +
                  ",\"ops\":" + std::to_string(w.ops) +
                  ",\"failed\":" + std::to_string(w.failed) +
                  ",\"avgBatch\":" + json::number(w.avgBatch()) +
                  ",\"maxBatch\":" + std::to_string(w.maxBatch) +
                  ",\"queued\":" + std::to_string(w.queued) +
                  "},\"readers\":{\"total\":" + std::to_string(w.readers) +
                  ",\"busy\":" + std::to_string(w.readersBusy) +
                  "},\"cache\":{\"entries\":" + std::to_string(c.entries) +
                  ",\"bytes\":" + std::to_string(c.bytes) +
                  ",\"hits\":" + std::to_string(c.hits) +
                  ",\"misses\":" + std::to_string(c.misses) +
                  ",\"evictions\":" + std::to_string(c.evictions) +
                  ",\"expired\":" + std::to_string(c.expired) + "}";
  if (qget(r, "counts") == "1") {
    o += eng_.read([&](Engine& e) {
      std::string d = ",\"counts\":{";
      Statement docs(e.db(), "SELECT COUNT(*) FROM docs");
      d += "\"docs\":" + std::to_string(docs.step() ? docs.int64(0) : 0);
      Statement pts(e.db(), "SELECT COUNT(*) FROM points");
      d += ",\"points\":" + std::to_string(pts.step() ? pts.int64(0) : 0);
      d += ",\"nodes\":" + std::to_string(e.graph.countNodes());
      d += ",\"edges\":" + std::to_string(e.graph.countEdges()) + "}";
      return d;
    });
  }
  return jsonResp(200, o + "}");
}

}  // namespace litedb
