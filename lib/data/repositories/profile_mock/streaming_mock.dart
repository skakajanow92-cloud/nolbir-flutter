import '../../../models/feed_card/feed_card.dart';
import '../../../models/streaming.dart';

/// Yayın Abonelikleri modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
StreamingProfileCard buildStreamingMock() {
  return StreamingProfileCard(
    id: "streaming1",
    providers: [
      // Aynı şirketten İKİ paket — modülün asıl ayırt edici durumu.
      StreamingProvider(
        id: "prov1",
        name: "Digiturk",
        packages: [
          StreamingPackage(
            id: "pkg1",
            name: "Sinema Eko",
            price: 349.90,
            // Yenilemeye 4 gün — uyarı banner'ını tetiklesin diye bilerek
            // DateTime.now() bazlı (sabit tarih yazsaydık demo zamanla
            // bozulurdu; travel/accommodation modüllerindeki aynı yaklaşım).
            renewalDate: DateTime.now().add(const Duration(days: 4)),
            maxScreens: 2,
            quality: StreamQuality.fullHd,
            channels: const [
              StreamingChannel(id: "ch1", name: "Sinema TV", category: "Film"),
              StreamingChannel(id: "ch2", name: "Dizi Max", category: "Dizi"),
              StreamingChannel(
                  id: "ch3", name: "Belgesel Kuşağı", category: "Belgesel"),
            ],
          ),
          StreamingPackage(
            id: "pkg2",
            name: "Spor Paketi",
            price: 529.00,
            renewalDate: DateTime.now().add(const Duration(days: 22)),
            maxScreens: 2,
            quality: StreamQuality.uhd4k,
            channels: const [
              StreamingChannel(
                  id: "ch4", name: "beIN Sports 1", category: "Spor"),
              StreamingChannel(
                  id: "ch5", name: "beIN Sports 2", category: "Spor"),
            ],
          ),
        ],
      ),
      StreamingProvider(
        id: "prov2",
        name: "BluTV",
        packages: [
          StreamingPackage(
            id: "pkg3",
            name: "Yıllık Premium",
            price: 1899.00,
            billingPeriod: BillingPeriod.yearly,
            renewalDate: DateTime.now().add(const Duration(days: 140)),
            maxScreens: 4,
            quality: StreamQuality.uhd4k,
            channels: const [
              StreamingChannel(
                  id: "ch6", name: "Yerli Yapımlar", category: "Dizi"),
              StreamingChannel(
                  id: "ch7", name: "Çocuk Kanalları", category: "Çocuk"),
            ],
          ),
        ],
      ),
      StreamingProvider(
        id: "prov3",
        name: "Exxen",
        packages: [
          StreamingPackage(
            id: "pkg4",
            name: "Reklamsız",
            price: 199.90,
            renewalDate: DateTime.now().add(const Duration(days: 11)),
            maxScreens: 1,
            quality: StreamQuality.hd,
            channels: const [
              StreamingChannel(
                  id: "ch8", name: "Stand-up Arşivi", category: "Eğlence"),
            ],
          ),
          // Aktif olmayan (iptal edilmiş) paket — toplamlara ve listeye
          // dahil EDİLMEMELİ; isActive filtresinin çalıştığını doğrular.
          StreamingPackage(
            id: "pkg5",
            name: "Eski Temel Paket",
            price: 129.90,
            renewalDate: DateTime(2025, 10, 1),
            isActive: false,
          ),
        ],
      ),
    ],
  );
}
