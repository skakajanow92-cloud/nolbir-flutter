#include "server/HttpServer.hpp"

#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <poll.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>

#include <algorithm>
#include <cerrno>
#include <charconv>
#include <chrono>
#include <cstring>
#include <stdexcept>

namespace litedb {

namespace {

using Clock = std::chrono::steady_clock;

const char* reason(int code) {
  switch (code) {
    case 100: return "Continue";
    case 200: return "OK";
    case 201: return "Created";
    case 204: return "No Content";
    case 400: return "Bad Request";
    case 401: return "Unauthorized";
    case 403: return "Forbidden";
    case 404: return "Not Found";
    case 405: return "Method Not Allowed";
    case 408: return "Request Timeout";
    case 409: return "Conflict";
    case 411: return "Length Required";
    case 413: return "Payload Too Large";
    case 429: return "Too Many Requests";
    case 431: return "Request Header Fields Too Large";
    case 500: return "Internal Server Error";
    case 501: return "Not Implemented";
    case 503: return "Service Unavailable";
    default: return "Unknown";
  }
}

bool sendAll(int fd, const char* p, size_t n) {
  while (n > 0) {
    ssize_t k = ::send(fd, p, n, MSG_NOSIGNAL);
    if (k < 0) {
      if (errno == EINTR) continue;
      return false;  // SO_SNDTIMEO dolunca EAGAIN: baglanti kopuk sayilir
    }
    p += k;
    n -= static_cast<size_t>(k);
  }
  return true;
}

std::string lower(std::string s) {
  for (char& c : s)
    if (c >= 'A' && c <= 'Z') c = static_cast<char>(c - 'A' + 'a');
  return s;
}

std::string trim(const std::string& s) {
  size_t a = 0, b = s.size();
  while (a < b && (s[a] == ' ' || s[a] == '\t')) ++a;
  while (b > a && (s[b - 1] == ' ' || s[b - 1] == '\t')) --b;
  return s.substr(a, b - a);
}

enum class ReadResult { Ok, Closed, Timeout, TooBig, Bad, NotImplemented, NeedLength };

struct Conn {
  int fd;
  std::string buf;  // henuz islenmemis baytlar (pipeline icin)
};

// Bekler (en fazla ms) ve bir kez okur. >0: okunan, 0: karsi taraf kapatti,
// -1: zaman asimi, -2: hata.
ssize_t recvSome(Conn& c, int ms) {
  pollfd p{c.fd, POLLIN, 0};
  for (;;) {
    int r = ::poll(&p, 1, ms);
    if (r < 0) {
      if (errno == EINTR) continue;
      return -2;
    }
    if (r == 0) return -1;
    break;
  }
  char tmp[16384];
  ssize_t k = ::recv(c.fd, tmp, sizeof tmp, 0);
  if (k < 0) return (errno == EINTR || errno == EAGAIN) ? -1 : -2;
  if (k > 0) c.buf.append(tmp, static_cast<size_t>(k));
  return k;
}

int remainingMs(Clock::time_point deadline, int capMs) {
  auto left = std::chrono::duration_cast<std::chrono::milliseconds>(
                  deadline - Clock::now())
                  .count();
  if (left <= 0) return 0;
  return static_cast<int>(std::min<long long>(left, capMs));
}

bool parseTarget(const std::string& target, Request& req) {
  if (target.empty() || target[0] != '/') return false;
  size_t q = target.find('?');
  req.path = target.substr(0, q);
  if (q == std::string::npos) return true;
  std::string qs = target.substr(q + 1);
  size_t pos = 0;
  while (pos <= qs.size()) {
    size_t amp = qs.find('&', pos);
    std::string pair = qs.substr(pos, amp == std::string::npos ? amp : amp - pos);
    if (!pair.empty()) {
      size_t eq = pair.find('=');
      std::string k, v;
      if (!urlDecode(pair.substr(0, eq), true, k)) return false;
      if (eq != std::string::npos && !urlDecode(pair.substr(eq + 1), true, v))
        return false;
      req.query[std::move(k)] = std::move(v);
    }
    if (amp == std::string::npos) break;
    pos = amp + 1;
  }
  return true;
}

}  // namespace

bool urlDecode(const std::string& in, bool plusAsSpace, std::string& out) {
  out.clear();
  out.reserve(in.size());
  for (size_t i = 0; i < in.size(); ++i) {
    char c = in[i];
    if (c == '%') {
      if (i + 2 >= in.size()) return false;  // eksik %XX
      auto hex = [](char h) -> int {
        if (h >= '0' && h <= '9') return h - '0';
        if (h >= 'a' && h <= 'f') return h - 'a' + 10;
        if (h >= 'A' && h <= 'F') return h - 'A' + 10;
        return -1;
      };
      int a = hex(in[i + 1]), b = hex(in[i + 2]);
      if (a < 0 || b < 0) return false;
      out.push_back(static_cast<char>(a * 16 + b));
      i += 2;
    } else if (c == '+' && plusAsSpace) {
      out.push_back(' ');
    } else {
      out.push_back(c);
    }
  }
  return true;
}

HttpServer::HttpServer(HttpServerOptions opt, Handler handler)
    : opt_(std::move(opt)), handler_(std::move(handler)) {
  addrinfo hints{};
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;
  addrinfo* res = nullptr;
  std::string portStr = std::to_string(opt_.port);
  int rc = ::getaddrinfo(opt_.host.c_str(), portStr.c_str(), &hints, &res);
  if (rc != 0)
    throw std::runtime_error("adres cozumlenemedi: " + opt_.host + ": " +
                             gai_strerror(rc));
  std::string lastErr = "bind basarisiz";
  for (addrinfo* ai = res; ai; ai = ai->ai_next) {
    int fd = ::socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
    if (fd < 0) continue;
    int one = 1;
    ::setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one);
    if (::bind(fd, ai->ai_addr, ai->ai_addrlen) == 0 && ::listen(fd, 256) == 0) {
      listenFd_ = fd;
      break;
    }
    lastErr = std::strerror(errno);
    ::close(fd);
  }
  ::freeaddrinfo(res);
  if (listenFd_ < 0)
    throw std::runtime_error("dinlenemedi (" + opt_.host + ":" + portStr +
                             "): " + lastErr);

  sockaddr_storage ss{};
  socklen_t sl = sizeof ss;
  ::getsockname(listenFd_, reinterpret_cast<sockaddr*>(&ss), &sl);
  if (ss.ss_family == AF_INET)
    port_ = ntohs(reinterpret_cast<sockaddr_in*>(&ss)->sin_port);
  else if (ss.ss_family == AF_INET6)
    port_ = ntohs(reinterpret_cast<sockaddr_in6*>(&ss)->sin6_port);
}

HttpServer::~HttpServer() {
  if (listenFd_ >= 0) ::close(listenFd_);
}

void HttpServer::run() {
  std::vector<std::thread> pool;
  for (size_t i = 0; i < std::max<size_t>(1, opt_.threads); ++i)
    pool.emplace_back([this] { worker(); });

  while (!stopping_.load()) {
    pollfd p{listenFd_, POLLIN, 0};
    int r = ::poll(&p, 1, 200);
    if (r <= 0) continue;
    int fd = ::accept(listenFd_, nullptr, nullptr);
    if (fd < 0) continue;
    int one = 1;
    ::setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof one);
    timeval tv{opt_.requestSec, 0};
    ::setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof tv);

    bool full = false;
    {
      std::lock_guard<std::mutex> lk(mu_);
      if (pending_.size() >= opt_.maxPending) {
        full = true;
      } else {
        pending_.push_back(fd);
      }
    }
    if (full) {
      static const char k503[] =
          "HTTP/1.1 503 Service Unavailable\r\nContent-Length: 0\r\n"
          "Connection: close\r\n\r\n";
      sendAll(fd, k503, sizeof k503 - 1);
      ::close(fd);
    } else {
      cv_.notify_one();
    }
  }

  {
    std::lock_guard<std::mutex> lk(mu_);
    closing_ = true;
  }
  cv_.notify_all();
  for (auto& t : pool) t.join();
  std::lock_guard<std::mutex> lk(mu_);
  for (int fd : pending_) ::close(fd);
  pending_.clear();
}

void HttpServer::worker() {
  for (;;) {
    int fd;
    {
      std::unique_lock<std::mutex> lk(mu_);
      cv_.wait(lk, [&] { return closing_ || !pending_.empty(); });
      if (pending_.empty()) return;  // closing_
      fd = pending_.front();
      pending_.pop_front();
    }
    serve(fd);
    ::close(fd);
  }
}

void HttpServer::serve(int fd) {
  Conn c{fd, {}};
  auto sendError = [&](int code, const std::string& msg) {
    std::string body = "{\"error\":\"" + msg + "\"}";
    std::string h = "HTTP/1.1 " + std::to_string(code) + " " + reason(code) +
                    "\r\nContent-Type: application/json\r\nContent-Length: " +
                    std::to_string(body.size()) + "\r\nConnection: close\r\n\r\n";
    sendAll(fd, h.data(), h.size());
    sendAll(fd, body.data(), body.size());
  };

  for (int served = 0; served < 200 && !stopping_.load(); ++served) {
    // ---- Baslik ----
    size_t hdrEnd = std::string::npos;
    Clock::time_point deadline = Clock::now() + std::chrono::seconds(opt_.idleSec);
    bool started = !c.buf.empty();
    if (started) deadline = Clock::now() + std::chrono::seconds(opt_.requestSec);
    for (;;) {
      hdrEnd = c.buf.find("\r\n\r\n");
      if (hdrEnd != std::string::npos) break;
      if (c.buf.size() > opt_.maxHeader) return sendError(431, "baslik cok buyuk");
      int ms = remainingMs(deadline, 1000);
      if (ms == 0) {
        if (started) sendError(408, "istek zaman asimi");
        return;
      }
      ssize_t k = recvSome(c, ms);
      if (k == 0 || k == -2) return;
      if (k > 0 && !started) {
        started = true;
        deadline = Clock::now() + std::chrono::seconds(opt_.requestSec);
      }
    }
    if (hdrEnd > opt_.maxHeader) return sendError(431, "baslik cok buyuk");

    // ---- Istek satiri ve basliklar ----
    Request req;
    std::string head = c.buf.substr(0, hdrEnd);
    size_t lineEnd = head.find("\r\n");
    std::string reqLine = head.substr(0, lineEnd);
    size_t s1 = reqLine.find(' ');
    size_t s2 = s1 == std::string::npos ? s1 : reqLine.find(' ', s1 + 1);
    if (s2 == std::string::npos) return sendError(400, "gecersiz istek satiri");
    req.method = reqLine.substr(0, s1);
    std::string target = reqLine.substr(s1 + 1, s2 - s1 - 1);
    std::string version = reqLine.substr(s2 + 1);
    if (version != "HTTP/1.1" && version != "HTTP/1.0")
      return sendError(400, "desteklenmeyen HTTP surumu");
    if (!parseTarget(target, req)) return sendError(400, "gecersiz adres");

    size_t pos = lineEnd == std::string::npos ? head.size() : lineEnd + 2;
    int nHeaders = 0;
    while (pos < head.size()) {
      size_t e = head.find("\r\n", pos);
      std::string line = head.substr(pos, e == std::string::npos ? e : e - pos);
      pos = e == std::string::npos ? head.size() : e + 2;
      size_t colon = line.find(':');
      if (colon == std::string::npos || colon == 0 || line[0] == ' ' ||
          line[0] == '\t')
        return sendError(400, "gecersiz baslik");
      if (++nHeaders > 100) return sendError(431, "cok fazla baslik");
      req.headers[lower(line.substr(0, colon))] = trim(line.substr(colon + 1));
    }

    if (req.headers.count("transfer-encoding"))
      return sendError(501, "chunked govde desteklenmiyor; Content-Length kullanin");

    size_t contentLength = 0;
    auto cl = req.headers.find("content-length");
    if (cl != req.headers.end()) {
      const std::string& v = cl->second;
      auto r = std::from_chars(v.data(), v.data() + v.size(), contentLength);
      if (v.empty() || r.ec != std::errc{} || r.ptr != v.data() + v.size())
        return sendError(400, "gecersiz Content-Length");
      if (contentLength > opt_.maxBody) return sendError(413, "govde cok buyuk");
    }

    // ---- Govde ----
    size_t bodyStart = hdrEnd + 4;
    if (req.header("expect") == "100-continue" &&
        c.buf.size() < bodyStart + contentLength) {
      static const char k100[] = "HTTP/1.1 100 Continue\r\n\r\n";
      sendAll(fd, k100, sizeof k100 - 1);
    }
    while (c.buf.size() < bodyStart + contentLength) {
      int ms = remainingMs(deadline, 1000);
      if (ms == 0) return sendError(408, "istek zaman asimi");
      ssize_t k = recvSome(c, ms);
      if (k == 0 || k == -2) return;
    }
    req.body = c.buf.substr(bodyStart, contentLength);
    c.buf.erase(0, bodyStart + contentLength);

    // ---- Isle ----
    bool head_only = req.method == "HEAD";
    if (head_only) req.method = "GET";
    Response resp;
    try {
      resp = handler_(req);
    } catch (const std::exception&) {
      resp = Response{};
      resp.status = 500;
      resp.body = "{\"error\":\"ic hata\"}";
    } catch (...) {
      resp = Response{};
      resp.status = 500;
      resp.body = "{\"error\":\"ic hata\"}";
    }

    bool keep = version == "HTTP/1.1";
    std::string conn = lower(req.header("connection"));
    if (conn == "close") keep = false;
    if (conn == "keep-alive") keep = true;
    if (stopping_.load() || served + 1 >= 200) keep = false;

    std::string out;
    out.reserve(256 + resp.body.size());
    out += "HTTP/1.1 " + std::to_string(resp.status) + " " + reason(resp.status) + "\r\n";
    if (resp.status != 204) {
      out += "Content-Type: " + resp.contentType + "\r\n";
      out += "Content-Length: " + std::to_string(resp.body.size()) + "\r\n";
    }
    out += "X-Content-Type-Options: nosniff\r\n";
    for (const auto& h : resp.headers) out += h.first + ": " + h.second + "\r\n";
    out += keep ? "Connection: keep-alive\r\n\r\n" : "Connection: close\r\n\r\n";
    if (!head_only && resp.status != 204) out += resp.body;
    if (!sendAll(fd, out.data(), out.size())) return;
    if (!keep) return;
  }
}

}  // namespace litedb
