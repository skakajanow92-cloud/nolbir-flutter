#pragma once
#include <mutex>
#include <string>
#include <utility>
#include <vector>

#include "server/HttpServer.hpp"
#include "server/SafeEngine.hpp"

namespace litedb {

struct ApiOptions {
  std::string token;  // bos degilse tum /api/* istekleri "Authorization: Bearer" ister
  // Dinleme adresi loopback ise DNS-rebinding'e karsi Host basligi
  // allowedHosts listesinden biri olmak zorundadir.
  bool hostCheck = true;
  std::vector<std::string> allowedHosts = {"localhost", "127.0.0.1", "[::1]"};
  const char* uiHtml = nullptr;  // "/" adresinde sunulan arayuz
};

// REST API: HTTP istegini SafeEngine uzerinde bir islemine cevirir.
// Thread-safe: ayni Api nesnesi tum calisan thread'lerden cagrilabilir.
class Api {
 public:
  Api(SafeEngine& engine, ApiOptions opt);
  Response handle(const Request& req);

 private:
  SafeEngine& eng_;
  ApiOptions opt_;

  Response route(const Request& req, const std::vector<std::string>& seg);
  Response docs(const Request&, const std::vector<std::string>&);
  Response graph(const Request&, const std::vector<std::string>&);
  Response ts(const Request&, const std::vector<std::string>&);
  Response cache(const Request&, const std::vector<std::string>&);
  Response tx(const Request&);
  Response stats(const Request&);
  void guard(const Request&);

  // Benzersiz alan yolu / etiket anahtari sayisini sinirlar (her biri icin
  // kalici bir hazir ifade olusur).
  bool admitPath(const std::string& kind, const std::string& key);
  void notePath(const std::string& kind, const std::string& key);

  std::mutex pathMu_;
  std::vector<std::pair<std::string, std::string>> seenPaths_;
};

}  // namespace litedb
