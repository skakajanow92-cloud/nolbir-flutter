#pragma once
// Kucuk, bagimliligi olmayan JSON yardimcilari: ayristirici, yazici, kacis.
// Sunucu gelen istek govdelerini, CLI ise yanitlari guzel basmak icin kullanir.
#include <cerrno>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

namespace litedb::json {

struct ParseError : std::runtime_error {
  using std::runtime_error::runtime_error;
};

struct Value {
  enum class Type { Null, Bool, Number, String, Array, Object };
  Type type = Type::Null;
  bool b = false;
  bool isInt = false;  // Number: tam sayi mi (i gecerli), degilse num
  long long i = 0;
  double num = 0;
  std::string str;
  std::vector<Value> arr;
  std::vector<std::pair<std::string, Value>> obj;  // ekleme sirasi korunur

  bool isNull() const { return type == Type::Null; }
  bool isBool() const { return type == Type::Bool; }
  bool isNumber() const { return type == Type::Number; }
  bool isString() const { return type == Type::String; }
  bool isArray() const { return type == Type::Array; }
  bool isObject() const { return type == Type::Object; }

  double asDouble() const { return isInt ? static_cast<double>(i) : num; }

  const Value* find(const std::string& key) const {
    if (type != Type::Object) return nullptr;
    for (const auto& kv : obj)
      if (kv.first == key) return &kv.second;
    return nullptr;
  }
};

// ---------- Yazma ----------

// s[i] ile baslayan gecerli UTF-8 dizisinin uzunlugu (1..4); gecersizse 0.
inline size_t utf8SeqLen(std::string_view s, size_t i) {
  unsigned char c = static_cast<unsigned char>(s[i]);
  if (c < 0x80) return 1;
  size_t n = (c >= 0xC2 && c <= 0xDF)   ? 2
             : (c >= 0xE0 && c <= 0xEF) ? 3
             : (c >= 0xF0 && c <= 0xF4) ? 4
                                        : 0;
  if (n == 0 || i + n > s.size()) return 0;
  for (size_t k = 1; k < n; ++k)
    if ((static_cast<unsigned char>(s[i + k]) & 0xC0) != 0x80) return 0;
  unsigned char c1 = static_cast<unsigned char>(s[i + 1]);
  if (n == 3 && ((c == 0xE0 && c1 < 0xA0) || (c == 0xED && c1 >= 0xA0))) return 0;
  if (n == 4 && ((c == 0xF0 && c1 < 0x90) || (c == 0xF4 && c1 >= 0x90))) return 0;
  return n;
}

inline bool validUtf8(std::string_view s) {
  for (size_t i = 0; i < s.size();) {
    size_t n = utf8SeqLen(s, i);
    if (n == 0) return false;
    i += n;
  }
  return true;
}

// Gecerli UTF-8 olmayan baytlar U+FFFD ile degistirilir; cikti her zaman
// gecerli JSON'dur.
inline std::string quote(std::string_view s) {
  std::string o;
  o.reserve(s.size() + 2);
  o.push_back('"');
  for (size_t i = 0; i < s.size();) {
    unsigned char c = static_cast<unsigned char>(s[i]);
    if (c < 0x80) {
      switch (c) {
        case '"': o += "\\\""; break;
        case '\\': o += "\\\\"; break;
        case '\n': o += "\\n"; break;
        case '\r': o += "\\r"; break;
        case '\t': o += "\\t"; break;
        case '\b': o += "\\b"; break;
        case '\f': o += "\\f"; break;
        default:
          if (c < 0x20) {
            char buf[8];
            std::snprintf(buf, sizeof buf, "\\u%04x", c);
            o += buf;
          } else {
            o.push_back(static_cast<char>(c));
          }
      }
      ++i;
      continue;
    }
    size_t n = utf8SeqLen(s, i);
    if (n == 0) {
      o += "\xEF\xBF\xBD";
      ++i;
      continue;
    }
    o.append(s.substr(i, n));
    i += n;
  }
  o.push_back('"');
  return o;
}

// En kisa gidis-donus (round-trip) gosterimi; sonsuz/NaN -> null.
inline std::string number(double d) {
  if (!std::isfinite(d)) return "null";
  char buf[40];
  for (int prec = 15; prec <= 17; ++prec) {
    std::snprintf(buf, sizeof buf, "%.*g", prec, d);
    if (std::strtod(buf, nullptr) == d) break;
  }
  return buf;
}

inline void dumpTo(const Value& v, std::string& out, int indent, int depth) {
  auto nl = [&](int d) {
    if (indent < 0) return;
    out.push_back('\n');
    out.append(static_cast<size_t>(d * indent), ' ');
  };
  switch (v.type) {
    case Value::Type::Null: out += "null"; break;
    case Value::Type::Bool: out += v.b ? "true" : "false"; break;
    case Value::Type::Number:
      out += v.isInt ? std::to_string(v.i) : number(v.num);
      break;
    case Value::Type::String: out += quote(v.str); break;
    case Value::Type::Array:
      if (v.arr.empty()) {
        out += "[]";
        break;
      }
      out.push_back('[');
      for (size_t k = 0; k < v.arr.size(); ++k) {
        if (k) out.push_back(',');
        nl(depth + 1);
        dumpTo(v.arr[k], out, indent, depth + 1);
      }
      nl(depth);
      out.push_back(']');
      break;
    case Value::Type::Object:
      if (v.obj.empty()) {
        out += "{}";
        break;
      }
      out.push_back('{');
      for (size_t k = 0; k < v.obj.size(); ++k) {
        if (k) out.push_back(',');
        nl(depth + 1);
        out += quote(v.obj[k].first);
        out += indent < 0 ? ":" : ": ";
        dumpTo(v.obj[k].second, out, indent, depth + 1);
      }
      nl(depth);
      out.push_back('}');
      break;
  }
}

// indent < 0: tek satir; aksi halde girintili.
inline std::string dump(const Value& v, int indent = -1) {
  std::string out;
  dumpTo(v, out, indent, 0);
  return out;
}

// ---------- Okuma ----------

class Parser {
 public:
  explicit Parser(std::string_view s) : s_(s) {}

  Value parseDocument() {
    Value v = parseValue(0);
    skipWs();
    if (p_ != s_.size()) fail("beklenmeyen fazladan veri");
    return v;
  }

 private:
  static constexpr int kMaxDepth = 64;

  [[noreturn]] void fail(const std::string& m) const {
    throw ParseError("JSON hatasi (konum " + std::to_string(p_) + "): " + m);
  }
  void skipWs() {
    while (p_ < s_.size() &&
           (s_[p_] == ' ' || s_[p_] == '\t' || s_[p_] == '\n' || s_[p_] == '\r'))
      ++p_;
  }
  bool eat(char c) {
    if (p_ < s_.size() && s_[p_] == c) {
      ++p_;
      return true;
    }
    return false;
  }
  void expectWord(std::string_view w) {
    if (s_.substr(p_, w.size()) != w) fail("gecersiz deger");
    p_ += w.size();
  }

  Value parseValue(int depth) {
    if (depth > kMaxDepth) fail("cok derin ic ice yapi");
    skipWs();
    if (p_ >= s_.size()) fail("beklenmeyen son");
    Value v;
    char c = s_[p_];
    if (c == '{') {
      ++p_;
      v.type = Value::Type::Object;
      skipWs();
      if (eat('}')) return v;
      for (;;) {
        skipWs();
        if (p_ >= s_.size() || s_[p_] != '"') fail("anahtar metin olmali");
        std::string key = parseString();
        skipWs();
        if (!eat(':')) fail("':' bekleniyordu");
        Value child = parseValue(depth + 1);
        v.obj.emplace_back(std::move(key), std::move(child));
        skipWs();
        if (eat(',')) continue;
        if (eat('}')) break;
        fail("',' veya '}' bekleniyordu");
      }
      return v;
    }
    if (c == '[') {
      ++p_;
      v.type = Value::Type::Array;
      skipWs();
      if (eat(']')) return v;
      for (;;) {
        v.arr.push_back(parseValue(depth + 1));
        skipWs();
        if (eat(',')) continue;
        if (eat(']')) break;
        fail("',' veya ']' bekleniyordu");
      }
      return v;
    }
    if (c == '"') {
      v.type = Value::Type::String;
      v.str = parseString();
      return v;
    }
    if (c == 't') {
      expectWord("true");
      v.type = Value::Type::Bool;
      v.b = true;
      return v;
    }
    if (c == 'f') {
      expectWord("false");
      v.type = Value::Type::Bool;
      return v;
    }
    if (c == 'n') {
      expectWord("null");
      return v;
    }
    if (c == '-' || (c >= '0' && c <= '9')) return parseNumber();
    fail("beklenmeyen karakter");
  }

  Value parseNumber() {
    size_t start = p_;
    bool integral = true;
    eat('-');
    if (p_ >= s_.size()) fail("gecersiz sayi");
    if (s_[p_] == '0') {
      ++p_;
    } else if (s_[p_] >= '1' && s_[p_] <= '9') {
      while (p_ < s_.size() && s_[p_] >= '0' && s_[p_] <= '9') ++p_;
    } else {
      fail("gecersiz sayi");
    }
    if (p_ < s_.size() && s_[p_] == '.') {
      integral = false;
      ++p_;
      size_t d = p_;
      while (p_ < s_.size() && s_[p_] >= '0' && s_[p_] <= '9') ++p_;
      if (p_ == d) fail("gecersiz sayi");
    }
    if (p_ < s_.size() && (s_[p_] == 'e' || s_[p_] == 'E')) {
      integral = false;
      ++p_;
      if (p_ < s_.size() && (s_[p_] == '+' || s_[p_] == '-')) ++p_;
      size_t d = p_;
      while (p_ < s_.size() && s_[p_] >= '0' && s_[p_] <= '9') ++p_;
      if (p_ == d) fail("gecersiz sayi");
    }
    std::string tok(s_.substr(start, p_ - start));
    Value v;
    v.type = Value::Type::Number;
    if (integral) {
      errno = 0;
      long long ll = std::strtoll(tok.c_str(), nullptr, 10);
      if (errno == 0) {
        v.isInt = true;
        v.i = ll;
        return v;
      }
    }
    errno = 0;
    double d = std::strtod(tok.c_str(), nullptr);
    if (!std::isfinite(d)) fail("sayi aralik disi");
    v.num = d;
    return v;
  }

  unsigned hex4() {
    if (p_ + 4 > s_.size()) fail("gecersiz \\u kacisi");
    unsigned u = 0;
    for (int k = 0; k < 4; ++k) {
      char h = s_[p_++];
      u <<= 4;
      if (h >= '0' && h <= '9') u |= static_cast<unsigned>(h - '0');
      else if (h >= 'a' && h <= 'f') u |= static_cast<unsigned>(h - 'a' + 10);
      else if (h >= 'A' && h <= 'F') u |= static_cast<unsigned>(h - 'A' + 10);
      else fail("gecersiz \\u kacisi");
    }
    return u;
  }

  static void appendUtf8(std::string& o, unsigned cp) {
    if (cp < 0x80) {
      o.push_back(static_cast<char>(cp));
    } else if (cp < 0x800) {
      o.push_back(static_cast<char>(0xC0 | (cp >> 6)));
      o.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
    } else if (cp < 0x10000) {
      o.push_back(static_cast<char>(0xE0 | (cp >> 12)));
      o.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F)));
      o.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
    } else {
      o.push_back(static_cast<char>(0xF0 | (cp >> 18)));
      o.push_back(static_cast<char>(0x80 | ((cp >> 12) & 0x3F)));
      o.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F)));
      o.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
    }
  }

  std::string parseString() {
    ++p_;  // acilis tirnagi
    std::string o;
    for (;;) {
      if (p_ >= s_.size()) fail("metin kapatilmadi");
      unsigned char c = static_cast<unsigned char>(s_[p_++]);
      if (c == '"') break;
      if (c < 0x20) fail("metinde kontrol karakteri");
      if (c != '\\') {
        o.push_back(static_cast<char>(c));
        continue;
      }
      if (p_ >= s_.size()) fail("gecersiz kacis");
      char e = s_[p_++];
      switch (e) {
        case '"': o.push_back('"'); break;
        case '\\': o.push_back('\\'); break;
        case '/': o.push_back('/'); break;
        case 'b': o.push_back('\b'); break;
        case 'f': o.push_back('\f'); break;
        case 'n': o.push_back('\n'); break;
        case 'r': o.push_back('\r'); break;
        case 't': o.push_back('\t'); break;
        case 'u': {
          unsigned cp = hex4();
          if (cp >= 0xD800 && cp <= 0xDBFF) {
            if (!(p_ + 1 < s_.size() && s_[p_] == '\\' && s_[p_ + 1] == 'u'))
              fail("eslesmeyen vekil (surrogate) cifti");
            p_ += 2;
            unsigned lo = hex4();
            if (lo < 0xDC00 || lo > 0xDFFF) fail("eslesmeyen vekil cifti");
            cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
          } else if (cp >= 0xDC00 && cp <= 0xDFFF) {
            fail("eslesmeyen vekil cifti");
          }
          appendUtf8(o, cp);
          break;
        }
        default: fail("gecersiz kacis");
      }
    }
    return o;
  }

  std::string_view s_;
  size_t p_ = 0;
};

inline Value parse(std::string_view s) { return Parser(s).parseDocument(); }

}  // namespace litedb::json
