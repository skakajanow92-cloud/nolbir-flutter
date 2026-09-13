import '../../models/feed_card.dart';
import '../../models/cart.dart';

/// Orta tab (Genel Akış) veri kaynağı sözleşmesi.
/// Gerçek API'ye geçerken burayı implement eden yeni bir sınıf yazman
/// yeterli — provider katmanı değişmez, sadece hangi repository'nin
/// enjekte edildiği değişir (bkz. discovery_providers.dart).
abstract class DiscoveryRepository {
  Future<List<FeedCard>> fetchFeed({required int page, int pageSize = 10});
}

class MockDiscoveryRepository implements DiscoveryRepository {
  // Demo amaçlı: ürün kartları farklı sepet türlerine dağılsın diye
  static const _demoCartTypes = [
    CartType.market,
    CartType.secondHand,
    CartType.sportsGear,
    CartType.wholesale,
  ];

  @override
  Future<List<FeedCard>> fetchFeed({required int page, int pageSize = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Demo amaçlı: 5. sayfadan sonra veri bitsin (pagination testi için)
    if (page >= 5) return [];

    return List.generate(pageSize, (i) {
      final n = page * pageSize + i;
      final type = n % 3;
      switch (type) {
        case 0:
          return VideoCard(
            id: "v$n",
            videoUrl: "",
            username: "kullanici$n",
            description: "Örnek video açıklaması #$n",
            likeCount: (n * 37) % 5000,
          );
        case 1:
          return ProductCard(
            id: "pr$n",
            title: "Ürün #$n",
            imageUrl: "",
            price: 99.9 + n * 10,
            cartType: _demoCartTypes[n % _demoCartTypes.length],
          );
        default:
          return SubscriptionCard(
            id: "sub$n",
            serviceName: "Premium Paket #$n",
            description: "Özel içerik ve avantajlar",
            monthlyPrice: 29.9 + n,
          );
      }
    });
  }
}
