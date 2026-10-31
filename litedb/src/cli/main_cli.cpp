// litedb-cli: litedbd sunucusu icin komut satiri istemcisi (HTTP uzerinden).
// Argumansiz calistirilirsa etkilesimli kabuk (REPL) acilir.
#include <arpa/inet.h>
#include <fcntl.h>
#include <netdb.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>

#include <cctype>
#include <cerrno>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>

#include "server/Json.hpp"

namespace json = litedb::json;

namespace {

struct Cfg {
  std::string host = "127.0.0.1", port = "7070", token;
  bool compact = false;
};

struct Resp {
  int status = 0;
  std::string body;
};

struct NetError : std::runtime_error {
  using std::runtime_error::runtime_error;
};

[[noreturn]] void die(int code, const std::string& m) {
  std::fprintf(stderr, "%s\n", m.c_str());
  std::exit(code);
}

// ---------------------------------------------------------------- HTTP istemcisi

bool parseUrl(const std::string& url, Cfg& cfg, std::string& err) {
  std::string u = url;
  if (u.rfind("https://", 0) == 0) {
    err = "https desteklenmiyor: TLS icin ssh tuneli (ssh -L 7070:127.0.0.1:7070 sunucu) kullanin "
          "veya ters vekilin dahili bir http adresine baglanin";
    return false;
  }
  if (u.rfind("http://", 0) == 0) u = u.substr(7);
  while (!u.empty() && u.back() == '/') u.pop_back();
  if (u.empty()) {
    err = "bos adres";
    return false;
  }
  if (u[0] == '[') {
    size_t e = u.find(']');
    if (e == std::string::npos) {
      err = "gecersiz IPv6 adresi";
      return false;
    }
    cfg.host = u.substr(1, e - 1);
    cfg.port = (e + 1 < u.size() && u[e + 1] == ':') ? u.substr(e + 2) : "7070";
  } else {
    size_t c = u.rfind(':');
    cfg.host = c == std::string::npos ? u : u.substr(0, c);
    cfg.port = c == std::string::npos ? "7070" : u.substr(c + 1);
  }
  return true;
}

int connectTo(const Cfg& cfg, std::string& err) {
  addrinfo hints{};
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  addrinfo* res = nullptr;
  int rc = ::getaddrinfo(cfg.host.c_str(), cfg.port.c_str(), &hints, &res);
  if (rc != 0) {
    err = std::string("adres cozumlenemedi: ") + gai_strerror(rc);
    return -1;
  }
  int fd = -1;
  err = "baglanilamadi";
  for (addrinfo* ai = res; ai; ai = ai->ai_next) {
    fd = ::socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
    if (fd < 0) continue;
    int fl = ::fcntl(fd, F_GETFL, 0);
    ::fcntl(fd, F_SETFL, fl | O_NONBLOCK);
    int r = ::connect(fd, ai->ai_addr, ai->ai_addrlen);
    if (r != 0 && errno == EINPROGRESS) {
      pollfd p{fd, POLLOUT, 0};
      if (::poll(&p, 1, 5000) == 1) {
        int soerr = 0;
        socklen_t sl = sizeof soerr;
        ::getsockopt(fd, SOL_SOCKET, SO_ERROR, &soerr, &sl);
        r = soerr == 0 ? 0 : -1;
        if (soerr) err = std::strerror(soerr);
      } else {
        r = -1;
        err = "baglanti zaman asimi";
      }
    } else if (r != 0) {
      err = std::strerror(errno);
    }
    if (r == 0) {
      ::fcntl(fd, F_SETFL, fl);
      break;
    }
    ::close(fd);
    fd = -1;
  }
  ::freeaddrinfo(res);
  return fd;
}

Resp request(const Cfg& cfg, const std::string& method, const std::string& path,
             const std::string* body = nullptr) {
  std::string err;
  int fd = connectTo(cfg, err);
  if (fd < 0)
    throw NetError("sunucuya baglanilamadi (" + cfg.host + ":" + cfg.port + "): " + err);
  timeval tv{60, 0};
  ::setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof tv);
  ::setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof tv);

  std::string hostHdr = cfg.host.find(':') != std::string::npos ? "[" + cfg.host + "]" : cfg.host;
  std::string req = method + " " + path + " HTTP/1.1\r\nHost: " + hostHdr + ":" + cfg.port +
                    "\r\nConnection: close\r\nAccept: application/json\r\n";
  if (!cfg.token.empty()) req += "Authorization: Bearer " + cfg.token + "\r\n";
  if (body) {
    req += "Content-Type: application/json\r\nContent-Length: " + std::to_string(body->size()) + "\r\n";
  }
  req += "\r\n";
  if (body) req += *body;

  const char* p = req.data();
  size_t n = req.size();
  while (n > 0) {
    ssize_t k = ::send(fd, p, n, MSG_NOSIGNAL);
    if (k < 0) {
      if (errno == EINTR) continue;
      ::close(fd);
      throw NetError("istek gonderilemedi");
    }
    p += k;
    n -= static_cast<size_t>(k);
  }
  std::string raw;
  char buf[65536];
  for (;;) {
    ssize_t k = ::recv(fd, buf, sizeof buf, 0);
    if (k < 0) {
      if (errno == EINTR) continue;
      break;
    }
    if (k == 0) break;
    raw.append(buf, static_cast<size_t>(k));
  }
  ::close(fd);

  size_t he = raw.find("\r\n\r\n");
  if (he == std::string::npos || raw.compare(0, 5, "HTTP/") != 0)
    throw NetError("sunucudan gecersiz yanit alindi");
  Resp r;
  size_t sp = raw.find(' ');
  r.status = std::atoi(raw.c_str() + sp + 1);
  r.body = raw.substr(he + 4);
  return r;
}

// ---------------------------------------------------------------- yardimcilar

std::string enc(const std::string& s) {
  static const char* hex = "0123456789ABCDEF";
  std::string o;
  for (unsigned char c : s) {
    if (std::isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
      o.push_back(static_cast<char>(c));
    } else {
      o.push_back('%');
      o.push_back(hex[c >> 4]);
      o.push_back(hex[c & 15]);
    }
  }
  return o;
}

std::string readAll(std::istream& in) {
  return std::string(std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>());
}

// "-" -> stdin, "@dosya" -> dosya icerigi, aksi halde metnin kendisi.
std::string readArg(const std::string& s) {
  if (s == "-") return readAll(std::cin);
  if (!s.empty() && s[0] == '@') {
    std::ifstream f(s.substr(1), std::ios::binary);
    if (!f) throw std::runtime_error("dosya okunamadi: " + s.substr(1));
    return readAll(f);
  }
  return s;
}

long long nowMs() {
  using namespace std::chrono;
  return duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
}

// Sure: "500" (ms), "30s", "5m", "2h", "1d".
long long parseDur(const std::string& s) {
  if (s.empty()) throw std::runtime_error("bos sure");
  size_t i = 0;
  while (i < s.size() && std::isdigit(static_cast<unsigned char>(s[i]))) ++i;
  if (i == 0) throw std::runtime_error("gecersiz sure: " + s);
  long long n = std::stoll(s.substr(0, i));
  std::string u = s.substr(i);
  if (u.empty() || u == "ms") return n;
  if (u == "s") return n * 1000;
  if (u == "m") return n * 60000;
  if (u == "h") return n * 3600000;
  if (u == "d") return n * 86400000;
  throw std::runtime_error("gecersiz sure birimi: " + s);
}

// Zaman: "now", "-5m", "-2h", "-1d" ya da epoch milisaniye.
long long parseTime(const std::string& s) {
  if (s == "now") return nowMs();
  if (s.size() > 1 && s[0] == '-') return nowMs() - parseDur(s.substr(1));
  return parseDur(s);
}

struct Parsed {
  std::vector<std::string> pos;
  std::map<std::string, std::string> flags;
  std::set<std::string> bools;
};

Parsed splitArgs(const std::vector<std::string>& toks) {
  static const std::set<std::string> boolFlags = {"compact", "counts", "help", "json"};
  Parsed p;
  for (size_t i = 0; i < toks.size(); ++i) {
    const std::string& t = toks[i];
    if (t == "-c") { p.bools.insert("compact"); continue; }
    if (t == "-h") { p.bools.insert("help"); continue; }
    if (t.size() > 2 && t.rfind("--", 0) == 0) {
      std::string name = t.substr(2), val;
      size_t eq = name.find('=');
      if (eq != std::string::npos) {
        val = name.substr(eq + 1);
        name = name.substr(0, eq);
        p.flags[name] = val;
      } else if (boolFlags.count(name)) {
        p.bools.insert(name);
      } else {
        if (i + 1 >= toks.size()) throw std::runtime_error("--" + name + " icin deger gerekli");
        p.flags[name] = toks[++i];
      }
      continue;
    }
    p.pos.push_back(t);
  }
  return p;
}

std::vector<std::string> tokenize(const std::string& line) {
  std::vector<std::string> out;
  std::string cur;
  bool inTok = false;
  char q = 0;
  for (size_t i = 0; i < line.size(); ++i) {
    char c = line[i];
    if (q) {
      if (c == q) q = 0;
      else if (c == '\\' && q == '"' && i + 1 < line.size() &&
               (line[i + 1] == '"' || line[i + 1] == '\\')) cur.push_back(line[++i]);
      else cur.push_back(c);
    } else if (c == '"' || c == '\'') {
      q = c;
      inTok = true;
    } else if (c == ' ' || c == '\t') {
      if (inTok) { out.push_back(cur); cur.clear(); inTok = false; }
    } else {
      cur.push_back(c);
      inTok = true;
    }
  }
  if (q) throw std::runtime_error("kapanmamis tirnak");
  if (inTok) out.push_back(cur);
  return out;
}

void printJson(const Cfg& cfg, const std::string& body) {
  try {
    json::Value v = json::parse(body);
    std::puts(json::dump(v, cfg.compact ? -1 : 2).c_str());
  } catch (const std::exception&) {
    std::fwrite(body.data(), 1, body.size(), stdout);
    std::puts("");
  }
}

// ---------------------------------------------------------------- komutlar

const char* kHelp =
    "litedb-cli - litedbd istemcisi\n"
    "\n"
    "Kullanim: litedb-cli [--url http://host:7070] [--token T] [-c] <komut> ...\n"
    "          litedb-cli                (etkilesimli kabuk)\n"
    "Ortam: LITEDB_URL, LITEDB_TOKEN.  -c: tek satir JSON.\n"
    "JSON argumanlari: dogrudan metin, @dosya veya - (stdin).\n"
    "\n"
    "genel\n"
    "  health | stats [--counts]\n"
    "belgeler\n"
    "  doc ls                              koleksiyonlari listele\n"
    "  doc put <koleksiyon> <id> <json>    ekle/guncelle\n"
    "  doc get <koleksiyon> <id>\n"
    "  doc del <koleksiyon> <id>\n"
    "  doc all <koleksiyon> [--limit N]\n"
    "  doc find <koleksiyon> <alan> <deger> [--type auto|string|int|real] [--limit N]\n"
    "  doc index <alan>                    alan indeksi olustur\n"
    "graf\n"
    "  graph node put <id> [etiket] [props-json] | get <id> | del <id> | ls <etiket>\n"
    "  graph edge put <src> <rel> <dst> [props-json] | del <src> <rel> <dst> |\n"
    "             has <src> <rel> <dst> | ls <id> [--rel R] [--dir out|in|both]\n"
    "  graph neighbors <id> [--rel R] [--dir D]\n"
    "  graph traverse <baslangic> [--depth N] [--rel R] [--dir D]\n"
    "  graph path <kimden> <kime> [--depth N] [--rel R] [--dir D]\n"
    "zaman serisi\n"
    "  ts ls\n"
    "  ts write <seri> <deger> [--ts ZAMAN] [--tags JSON]\n"
    "  ts range <seri> [--from ZAMAN] [--to ZAMAN] [--limit N] [--tag k=v]\n"
    "  ts latest <seri> | stats <seri> [--from Z] [--to Z]\n"
    "  ts down <seri> --bucket 1m [--agg avg|min|max|sum|count|first|last] [--from Z] [--to Z]\n"
    "  ts prune <seri> --before ZAMAN      | ts rm <seri>   (tum seri)\n"
    "    ZAMAN: now, -5m, -2h, -1d veya epoch milisaniye\n"
    "onbellek (bellekte, kalici degil)\n"
    "  cache set <anahtar> <deger> [--ttl 60s] | get <anahtar> [--json] | del <anahtar>\n"
    "  cache incr <anahtar> [delta] | ttl <anahtar> | expire <anahtar> <sure> | clear | stats\n"
    "atomik islem\n"
    "  tx <dosya.json|->     {\"ops\":[{\"op\":\"doc.put\",...}, ...]} hepsi ya da hic\n"
    "kabuk: help, exit\n";

struct Ctx {
  Cfg cfg;
};

int report(const Cfg&, const Resp& r) {
  if (r.status >= 200 && r.status < 300) return 0;
  std::string msg = r.body;
  try {
    json::Value v = json::parse(r.body);
    if (const json::Value* e = v.find("error")) msg = e->str;
  } catch (const std::exception&) {
  }
  std::fprintf(stderr, "hata (HTTP %d): %s\n", r.status, msg.c_str());
  return 1;
}

int callPrint(const Cfg& cfg, const std::string& method, const std::string& path,
              const std::string* body = nullptr) {
  Resp r = request(cfg, method, path, body);
  int rc = report(cfg, r);
  if (rc == 0 && r.status != 204) printJson(cfg, r.body);
  return rc;
}

std::string F(const Parsed& p, const char* name, const std::string& def = "") {
  auto it = p.flags.find(name);
  return it == p.flags.end() ? def : it->second;
}

std::string dirRelQuery(const Parsed& p) {
  return "rel=" + enc(F(p, "rel")) + "&dir=" + enc(F(p, "dir", "out"));
}

int run(Cfg cfg, const Parsed& p) {
  const auto& a = p.pos;
  auto need = [&](size_t n, const char* usage) {
    if (a.size() < n) throw std::runtime_error(std::string("kullanim: ") + usage);
  };
  if (a.empty()) throw std::runtime_error("komut gerekli (yardim icin: help)");
  const std::string& c = a[0];

  if (c == "help") { std::fputs(kHelp, stdout); return 0; }
  if (c == "health") return callPrint(cfg, "GET", "/healthz");
  if (c == "stats") return callPrint(cfg, "GET", p.bools.count("counts") ? "/api/stats?counts=1" : "/api/stats");

  if (c == "doc") {
    need(2, "doc ls|put|get|del|all|find|index");
    const std::string& s = a[1];
    if (s == "ls") return callPrint(cfg, "GET", "/api/docs");
    if (s == "put") {
      need(5, "doc put <koleksiyon> <id> <json|@dosya|->");
      std::string body = readArg(a[4]);
      return callPrint(cfg, "PUT", "/api/docs/" + enc(a[2]) + "/" + enc(a[3]), &body);
    }
    if (s == "get") { need(4, "doc get <koleksiyon> <id>"); return callPrint(cfg, "GET", "/api/docs/" + enc(a[2]) + "/" + enc(a[3])); }
    if (s == "del") { need(4, "doc del <koleksiyon> <id>"); return callPrint(cfg, "DELETE", "/api/docs/" + enc(a[2]) + "/" + enc(a[3])); }
    if (s == "all") { need(3, "doc all <koleksiyon>"); return callPrint(cfg, "GET", "/api/docs/" + enc(a[2]) + "?limit=" + enc(F(p, "limit", a.size() > 3 ? a[3] : "100"))); }
    if (s == "find") {
      need(5, "doc find <koleksiyon> <alan> <deger>");
      return callPrint(cfg, "GET", "/api/docs/" + enc(a[2]) + "?field=" + enc(a[3]) + "&value=" + enc(a[4]) +
                                       "&type=" + enc(F(p, "type", "auto")) + "&limit=" + enc(F(p, "limit", "100")));
    }
    if (s == "index") { need(3, "doc index <alan>"); return callPrint(cfg, "POST", "/api/indexes/docs?field=" + enc(a[2])); }
  }

  if (c == "graph") {
    need(2, "graph node|edge|neighbors|traverse|path");
    const std::string& s = a[1];
    if (s == "node") {
      need(3, "graph node put|get|del|ls");
      const std::string& op = a[2];
      if (op == "put") {
        need(4, "graph node put <id> [etiket] [props-json]");
        json::Value b;
        b.type = json::Value::Type::Object;
        json::Value lab; lab.type = json::Value::Type::String; lab.str = a.size() > 4 ? a[4] : "";
        b.obj.emplace_back("label", lab);
        if (a.size() > 5) b.obj.emplace_back("props", json::parse(readArg(a[5])));
        std::string body = json::dump(b);
        return callPrint(cfg, "PUT", "/api/graph/nodes/" + enc(a[3]), &body);
      }
      if (op == "get") { need(4, "graph node get <id>"); return callPrint(cfg, "GET", "/api/graph/nodes/" + enc(a[3])); }
      if (op == "del") { need(4, "graph node del <id>"); return callPrint(cfg, "DELETE", "/api/graph/nodes/" + enc(a[3])); }
      if (op == "ls") { need(4, "graph node ls <etiket>"); return callPrint(cfg, "GET", "/api/graph/nodes?label=" + enc(a[3])); }
    }
    if (s == "edge") {
      need(3, "graph edge put|del|has|ls");
      const std::string& op = a[2];
      if (op == "put") {
        need(6, "graph edge put <src> <rel> <dst> [props-json]");
        json::Value b;
        b.type = json::Value::Type::Object;
        auto str = [](const std::string& v) { json::Value x; x.type = json::Value::Type::String; x.str = v; return x; };
        b.obj.emplace_back("src", str(a[3]));
        b.obj.emplace_back("rel", str(a[4]));
        b.obj.emplace_back("dst", str(a[5]));
        if (a.size() > 6) b.obj.emplace_back("props", json::parse(readArg(a[6])));
        std::string body = json::dump(b);
        return callPrint(cfg, "PUT", "/api/graph/edges", &body);
      }
      if (op == "del" || op == "has") {
        need(6, "graph edge del|has <src> <rel> <dst>");
        return callPrint(cfg, op == "del" ? "DELETE" : "GET",
                         "/api/graph/edges?src=" + enc(a[3]) + "&rel=" + enc(a[4]) + "&dst=" + enc(a[5]));
      }
      if (op == "ls") { need(4, "graph edge ls <id>"); return callPrint(cfg, "GET", "/api/graph/nodes/" + enc(a[3]) + "/edges?" + dirRelQuery(p)); }
    }
    if (s == "neighbors") { need(3, "graph neighbors <id>"); return callPrint(cfg, "GET", "/api/graph/nodes/" + enc(a[2]) + "/neighbors?" + dirRelQuery(p)); }
    if (s == "traverse") { need(3, "graph traverse <baslangic>"); return callPrint(cfg, "GET", "/api/graph/traverse?start=" + enc(a[2]) + "&depth=" + enc(F(p, "depth", "3")) + "&" + dirRelQuery(p)); }
    if (s == "path") { need(4, "graph path <kimden> <kime>"); return callPrint(cfg, "GET", "/api/graph/path?from=" + enc(a[2]) + "&to=" + enc(a[3]) + "&depth=" + enc(F(p, "depth", "10")) + "&" + dirRelQuery(p)); }
  }

  if (c == "ts") {
    need(2, "ts ls|write|range|latest|stats|down|prune|rm");
    const std::string& s = a[1];
    if (s == "ls") return callPrint(cfg, "GET", "/api/ts");
    need(3, "ts <komut> <seri>");
    std::string base = "/api/ts/" + enc(a[2]);
    auto range = [&]() {
      return "from=" + std::to_string(p.flags.count("from") ? parseTime(F(p, "from")) : 0LL) +
             "&to=" + (p.flags.count("to") ? std::to_string(parseTime(F(p, "to")) + 1) : std::string("9223372036854775807"));
    };
    if (s == "write") {
      need(4, "ts write <seri> <deger> [--ts Z] [--tags JSON]");
      json::Value b;
      b.type = json::Value::Type::Object;
      json::Value v = json::parse(a[3]);
      if (!v.isNumber()) throw std::runtime_error("deger sayi olmali");
      b.obj.emplace_back("value", v);
      if (p.flags.count("ts")) {
        json::Value t; t.type = json::Value::Type::Number; t.isInt = true; t.i = parseTime(F(p, "ts"));
        b.obj.emplace_back("ts", t);
      }
      if (p.flags.count("tags")) b.obj.emplace_back("tags", json::parse(readArg(F(p, "tags"))));
      std::string body = json::dump(b);
      return callPrint(cfg, "POST", base, &body);
    }
    if (s == "range") {
      std::string q = base + "?" + range() + "&limit=" + enc(F(p, "limit", "1000"));
      if (p.flags.count("tag")) {
        std::string kv = F(p, "tag");
        size_t eq = kv.find('=');
        if (eq == std::string::npos) throw std::runtime_error("--tag k=v bicimi bekleniyor");
        q += "&tag=" + enc(kv.substr(0, eq)) + "&tagValue=" + enc(kv.substr(eq + 1));
      }
      return callPrint(cfg, "GET", q);
    }
    if (s == "latest") return callPrint(cfg, "GET", base + "/latest");
    if (s == "stats") return callPrint(cfg, "GET", base + "/stats?" + range());
    if (s == "down") {
      if (!p.flags.count("bucket")) throw std::runtime_error("--bucket gerekli (ornek: 1m)");
      return callPrint(cfg, "GET", base + "/downsample?" + range() + "&bucket=" + std::to_string(parseDur(F(p, "bucket"))) +
                                       "&agg=" + enc(F(p, "agg", "avg")));
    }
    if (s == "prune") {
      if (!p.flags.count("before")) throw std::runtime_error("--before gerekli");
      return callPrint(cfg, "DELETE", base + "?before=" + std::to_string(parseTime(F(p, "before"))));
    }
    if (s == "rm") return callPrint(cfg, "DELETE", base);
  }

  if (c == "cache") {
    need(2, "cache set|get|del|incr|ttl|expire|clear|stats");
    const std::string& s = a[1];
    if (s == "clear") return callPrint(cfg, "DELETE", "/api/cache");
    if (s == "stats") return callPrint(cfg, "GET", "/api/cache");
    need(3, "cache <komut> <anahtar>");
    std::string k = "/api/cache/" + enc(a[2]);
    if (s == "set") {
      need(4, "cache set <anahtar> <deger> [--ttl 60s]");
      std::string body = readArg(a[3]);
      return callPrint(cfg, "PUT", k + "?ttl=" + std::to_string(p.flags.count("ttl") ? parseDur(F(p, "ttl")) : 0LL), &body);
    }
    if (s == "get") {
      Resp r = request(cfg, "GET", k);
      int rc = report(cfg, r);
      if (rc) return rc;
      if (p.bools.count("json")) { printJson(cfg, r.body); return 0; }
      json::Value v = json::parse(r.body);
      const json::Value* val = v.find("value");
      std::fwrite(val->str.data(), 1, val->str.size(), stdout);
      std::puts("");
      return 0;
    }
    if (s == "del") return callPrint(cfg, "DELETE", k);
    if (s == "incr") return callPrint(cfg, "POST", k + "/incr?delta=" + enc(a.size() > 3 ? a[3] : "1"));
    if (s == "ttl") return callPrint(cfg, "GET", k + "/ttl");
    if (s == "expire") { need(4, "cache expire <anahtar> <sure>"); return callPrint(cfg, "POST", k + "/expire?ttl=" + std::to_string(parseDur(a[3]))); }
  }

  if (c == "tx") {
    need(2, "tx <dosya.json|->");
    std::string body = readArg(a[1].size() && a[1] != "-" && a[1][0] != '@' ? "@" + a[1] : a[1]);
    return callPrint(cfg, "POST", "/api/tx", &body);
  }

  throw std::runtime_error("bilinmeyen komut: " + c + " (yardim icin: help)");
}

// --url / --token / -c genel seceneklerini cfg'ye uygular.
void applyGlobals(Cfg& cfg, const Parsed& p) {
  if (p.flags.count("url")) {
    std::string err;
    if (!parseUrl(p.flags.at("url"), cfg, err)) throw std::runtime_error(err);
  }
  if (p.flags.count("token")) cfg.token = p.flags.at("token");
  if (p.bools.count("compact")) cfg.compact = true;
}

int execLine(Cfg cfg, const std::vector<std::string>& toks) {
  try {
    Parsed p = splitArgs(toks);
    applyGlobals(cfg, p);
    if (p.pos.empty() && p.bools.count("help")) { std::fputs(kHelp, stdout); return 0; }
    if (!p.pos.empty() && p.bools.count("help")) { std::fputs(kHelp, stdout); return 0; }
    return run(cfg, p);
  } catch (const NetError& e) {
    std::fprintf(stderr, "%s\n", e.what());
    return 1;
  } catch (const json::ParseError& e) {
    std::fprintf(stderr, "%s\n", e.what());
    return 2;
  } catch (const std::exception& e) {
    std::fprintf(stderr, "%s\n", e.what());
    return 2;
  }
}

}  // namespace

int main(int argc, char** argv) {
  Cfg cfg;
  if (const char* u = std::getenv("LITEDB_URL")) {
    std::string err;
    if (!parseUrl(u, cfg, err)) die(2, "LITEDB_URL: " + err);
  }
  if (const char* t = std::getenv("LITEDB_TOKEN")) cfg.token = t;

  std::vector<std::string> toks(argv + 1, argv + argc);

  // Genel secenekleri (--url, --token, -c) bir kez ayikla; REPL'de kalici olsun.
  // Komut varsa (veya -h/--help ya da gecersiz arguman) tek seferlik calistir;
  // yalniz genel secenek verildiyse onlari uygulayip REPL'e gec.
  if (!toks.empty()) {
    Parsed p0;
    bool globalsOnly = false;
    try {
      p0 = splitArgs(toks);
      globalsOnly = p0.pos.empty() && !p0.bools.count("help");
      if (globalsOnly) applyGlobals(cfg, p0);
    } catch (const std::exception&) {
      globalsOnly = false;  // hatayi execLine kendi bicimiyle bildirir
    }
    if (!globalsOnly) return execLine(cfg, toks);
  }

  bool tty = ::isatty(0);
  if (tty) std::puts("litedb-cli: komutlar icin 'help', cikis icin 'exit' (ipucu: rlwrap ile ok tuslari)");
  std::string line;
  for (;;) {
    if (tty) {
      std::fputs("litedb> ", stdout);
      std::fflush(stdout);
    }
    if (!std::getline(std::cin, line)) break;
    std::vector<std::string> t;
    try {
      t = tokenize(line);
    } catch (const std::exception& e) {
      std::fprintf(stderr, "%s\n", e.what());
      continue;
    }
    if (t.empty() || t[0][0] == '#') continue;
    if (t[0] == "exit" || t[0] == "quit") break;
    execLine(cfg, t);
  }
  return 0;
}
