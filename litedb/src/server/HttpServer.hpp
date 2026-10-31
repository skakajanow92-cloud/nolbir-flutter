#pragma once
// Bagimliligi olmayan, kucuk bir HTTP/1.1 sunucusu (POSIX soketleri).
// Sabit boyutlu thread havuzu, keep-alive, govde/baslik siniri, zaman asimlari.
// Genel internete dogrudan acmak yerine TLS sonlandiran bir ters vekil
// (Caddy/nginx) arkasinda calistirin.
#include <atomic>
#include <condition_variable>
#include <deque>
#include <functional>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>

namespace litedb {

struct Request {
  std::string method;
  std::string path;  // ham (yuzde-cozulmemis), sorgu metni haric
  std::unordered_map<std::string, std::string> query;    // cozulmus
  std::unordered_map<std::string, std::string> headers;  // anahtarlar kucuk harf
  std::string body;

  std::string header(const std::string& lowerName) const {
    auto it = headers.find(lowerName);
    return it == headers.end() ? std::string() : it->second;
  }
};

struct Response {
  int status = 200;
  std::string contentType = "application/json; charset=utf-8";
  std::string body;
  std::vector<std::pair<std::string, std::string>> headers;
};

using Handler = std::function<Response(const Request&)>;

struct HttpServerOptions {
  std::string host = "127.0.0.1";
  int port = 7070;               // 0 -> sistem bos bir port secer (port() ile ogren)
  size_t threads = 32;           // ayni anda islenen baglanti sayisi
  size_t maxPending = 256;       // kabul edilmis ama bekleyen baglanti siniri
  size_t maxBody = 4u << 20;     // bayt
  size_t maxHeader = 16u << 10;  // bayt
  int idleSec = 5;               // keep-alive bosta bekleme
  int requestSec = 30;           // bir istegin tamamlanma suresi
};

class HttpServer {
 public:
  // Dinlemeye baslar (bind/listen); basarisizsa std::runtime_error.
  HttpServer(HttpServerOptions opt, Handler handler);
  ~HttpServer();
  HttpServer(const HttpServer&) = delete;
  HttpServer& operator=(const HttpServer&) = delete;

  int port() const { return port_; }

  // stop() cagrilana kadar baglantilari kabul eder (bloklar).
  void run();
  // Sinyal isleyicisinden de cagrilabilir (yalniz atomik bayrak koyar).
  void stop() { stopping_.store(true); }

 private:
  void worker();
  void serve(int fd);

  HttpServerOptions opt_;
  Handler handler_;
  int listenFd_ = -1;
  int port_ = 0;
  std::atomic<bool> stopping_{false};

  std::mutex mu_;
  std::condition_variable cv_;
  std::deque<int> pending_;
  bool closing_ = false;
};

// "a%20b" -> "a b". plusAsSpace: sorgu metni icin '+' -> ' '. Gecersizse false.
bool urlDecode(const std::string& in, bool plusAsSpace, std::string& out);

}  // namespace litedb
