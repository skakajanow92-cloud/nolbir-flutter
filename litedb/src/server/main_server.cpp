// litedbd: litedb HTTP sunucusu (REST API + web arayuzu).
#include <signal.h>

#include <atomic>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>

#include "server/Api.hpp"
#include "server/HttpServer.hpp"
#include "server/SafeEngine.hpp"
#include "ui_html.hpp"

using namespace litedb;

namespace {

HttpServer* g_server = nullptr;

void onSignal(int) {
  if (g_server) g_server->stop();  // yalniz atomik bayrak
}

void usage() {
  std::puts(
      "litedbd - litedb HTTP sunucusu\n"
      "\n"
      "Kullanim: litedbd [secenekler]\n"
      "  --db YOL            veritabani dosyasi (varsayilan: litedb.db)\n"
      "  --host ADRES        dinleme adresi (varsayilan: 127.0.0.1)\n"
      "  --port N            port (varsayilan: 7070)\n"
      "  --token T           API belirteci (veya LITEDB_TOKEN ortam degiskeni)\n"
      "  --token-file YOL    belirteci dosyadan oku (ps'te gorunmez)\n"
      "  --allow-host AD     Host basligi olarak kabul edilecek ek ad (tekrarlanabilir)\n"
      "  --insecure-no-auth  loopback disinda belirtecsiz calismaya izin ver\n"
      "\n"
      "Yazma performansi:\n"
      "  --max-batch N       tek commit'te en fazla yazma gorevi (varsayilan 512)\n"
      "  --linger-us N       toplu yazma icin ek bekleme, mikrosaniye (varsayilan 0)\n"
      "  --durable           her commit'te fsync (synchronous=FULL); grup commit\n"
      "                      maliyeti yazmalar arasinda paylastirir\n"
      "  --max-queue N       bekleyen yazma siniri; asilinca 503 (varsayilan 20000)\n"
      "\n"
      "Kaynaklar:\n"
      "  --readers N         okuma baglantisi sayisi (varsayilan 4)\n"
      "  --threads N         eszamanli HTTP baglantisi (varsayilan 32)\n"
      "  --max-body-mb N     istek govdesi siniri (varsayilan 4)\n"
      "  --cache-mb N        onbellek bayt siniri (varsayilan 256)\n"
      "  --cache-entries N   onbellek girdi siniri (varsayilan 100000)\n"
      "  --verbose           her istegi stderr'e yaz\n");
}

bool isLoopback(const std::string& h) {
  return h == "127.0.0.1" || h == "localhost" || h == "::1" || h == "[::1]";
}

}  // namespace

int main(int argc, char** argv) {
  std::string dbPath = "litedb.db", host = "127.0.0.1", token, tokenFile;
  int port = 7070;
  SafeEngineOptions so;
  HttpServerOptions ho;
  ApiOptions ao;
  bool insecure = false, verbose = false;
  size_t cacheMb = 256;
  std::vector<std::string> extraHosts;

  auto need = [&](int& i, const char* flag) -> std::string {
    if (i + 1 >= argc) {
      std::fprintf(stderr, "%s icin deger gerekli\n", flag);
      std::exit(2);
    }
    return argv[++i];
  };
  auto num = [&](const std::string& s, const char* flag) -> long long {
    char* end = nullptr;
    long long v = std::strtoll(s.c_str(), &end, 10);
    if (s.empty() || *end != '\0' || v < 0) {
      std::fprintf(stderr, "%s icin gecersiz sayi: %s\n", flag, s.c_str());
      std::exit(2);
    }
    return v;
  };

  for (int i = 1; i < argc; ++i) {
    std::string a = argv[i];
    if (a == "-h" || a == "--help") { usage(); return 0; }
    else if (a == "--db") dbPath = need(i, "--db");
    else if (a == "--host") host = need(i, "--host");
    else if (a == "--port") port = static_cast<int>(num(need(i, "--port"), "--port"));
    else if (a == "--token") token = need(i, "--token");
    else if (a == "--token-file") tokenFile = need(i, "--token-file");
    else if (a == "--allow-host") extraHosts.push_back(need(i, "--allow-host"));
    else if (a == "--insecure-no-auth") insecure = true;
    else if (a == "--max-batch") so.maxBatch = static_cast<size_t>(num(need(i, "--max-batch"), "--max-batch"));
    else if (a == "--linger-us") so.lingerMicros = static_cast<int>(num(need(i, "--linger-us"), "--linger-us"));
    else if (a == "--durable") so.durable = true;
    else if (a == "--max-queue") so.maxQueue = static_cast<size_t>(num(need(i, "--max-queue"), "--max-queue"));
    else if (a == "--readers") so.readers = static_cast<size_t>(num(need(i, "--readers"), "--readers"));
    else if (a == "--threads") ho.threads = static_cast<size_t>(num(need(i, "--threads"), "--threads"));
    else if (a == "--max-body-mb") ho.maxBody = static_cast<size_t>(num(need(i, "--max-body-mb"), "--max-body-mb")) << 20;
    else if (a == "--cache-mb") cacheMb = static_cast<size_t>(num(need(i, "--cache-mb"), "--cache-mb"));
    else if (a == "--cache-entries") so.cache.maxEntries = static_cast<size_t>(num(need(i, "--cache-entries"), "--cache-entries"));
    else if (a == "--verbose") verbose = true;
    else {
      std::fprintf(stderr, "bilinmeyen secenek: %s (yardim: --help)\n", a.c_str());
      return 2;
    }
  }

  if (token.empty() && !tokenFile.empty()) {
    std::ifstream f(tokenFile);
    if (!f || !std::getline(f, token)) {
      std::fprintf(stderr, "belirtec dosyasi okunamadi: %s\n", tokenFile.c_str());
      return 2;
    }
    while (!token.empty() && (token.back() == '\r' || token.back() == ' ')) token.pop_back();
  }
  if (token.empty()) {
    if (const char* env = std::getenv("LITEDB_TOKEN")) token = env;
  }

  const bool loopback = isLoopback(host);
  if (!loopback && token.empty() && !insecure) {
    std::fprintf(stderr,
                 "Reddedildi: %s adresinde belirtec olmadan dinlemek guvenli degil.\n"
                 "  --token-file / LITEDB_TOKEN kullanin ya da (bilerek) --insecure-no-auth verin.\n",
                 host.c_str());
    return 2;
  }
  if (!token.empty() && token.size() < 16)
    std::fprintf(stderr, "uyari: belirtec kisa (<16 karakter); uzun rastgele bir deger kullanin\n");

  so.path = dbPath;
  so.cache.maxBytes = cacheMb << 20;
  ho.host = host;
  ho.port = port;
  ao.token = token;
  ao.hostCheck = loopback;
  for (auto& h : extraHosts) ao.allowedHosts.push_back(h);
  ao.uiHtml = kUiHtml;

  try {
    SafeEngine engine(so);
    Api api(engine, ao);
    Handler handler = [&](const Request& req) {
      if (!verbose) return api.handle(req);
      auto t0 = std::chrono::steady_clock::now();
      Response r = api.handle(req);
      auto ms = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count();
      std::fprintf(stderr, "%s %s -> %d (%.2f ms)\n", req.method.c_str(), req.path.c_str(), r.status, ms);
      return r;
    };
    HttpServer server(ho, handler);
    g_server = &server;

    struct sigaction sa;
    std::memset(&sa, 0, sizeof sa);
    sa.sa_handler = onSignal;
    sigemptyset(&sa.sa_mask);
    sigaction(SIGINT, &sa, nullptr);
    sigaction(SIGTERM, &sa, nullptr);
    signal(SIGPIPE, SIG_IGN);

    // Suresi dolan ama hic okunmayan onbellek girdilerini periyodik temizle.
    std::atomic<bool> done{false};
    std::thread janitor([&] {
      for (int tick = 0; !done.load(); ++tick) {
        std::this_thread::sleep_for(std::chrono::milliseconds(500));
        if (tick % 60 == 59) engine.cache().purgeExpired();
      }
    });

    std::printf("litedbd dinliyor: http://%s:%d  (db=%s, okuyucu=%zu, max-batch=%zu%s%s)\n",
                host.c_str(), server.port(), dbPath.c_str(), so.readers, so.maxBatch,
                so.durable ? ", durable" : "", token.empty() ? ", belirtecsiz" : ", belirtec acik");
    std::fflush(stdout);

    server.run();

    done = true;
    janitor.join();
    g_server = nullptr;
    std::puts("litedbd kapatildi.");
  } catch (const std::exception& e) {
    std::fprintf(stderr, "litedbd baslatilamadi: %s\n", e.what());
    return 1;
  }
  return 0;
}
