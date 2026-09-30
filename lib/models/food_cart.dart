import 'cart.dart';

/// `CartItem.metadata` üzerinden yemek sepetine özel alanları okuyan
/// yardımcı extension.
///
/// KONVANSİYON: market_cart.dart/hotel_cart.dart ile AYNI yaklaşım —
/// işletmeye özel bilgi `metadata` üzerinden okunuyor. Sepet, market
/// sepetindeki gibi BİRDEN FAZLA işletmeden oluşabilir; bu yüzden her
/// kalem kendi `restaurantName`ini taşıyor.
extension FoodCartItemExtras on CartItem {
  String get restaurantName => (metadata['restaurantName'] as String?) ?? "Bilinmeyen İşletme";
  String? get category => metadata['category'] as String?; // örn. "Ana Yemek", "İçecek", "Tatlı"
  String? get specialInstructions => metadata['specialInstructions'] as String?; // örn. "Acısız olsun"
  int? get estimatedPrepMinutes => metadata['estimatedPrepMinutes'] as int?;
}

/// Kullanıcının konumuna yakın, yemek hazırlayan bir işletme (restoran/kafe).
class NearbyBusiness {
  final String id;
  final String name;
  final String cuisineType; // örn. "Türk Mutfağı", "Fast Food", "Kahve"
  final double distanceKm;
  final double rating; // 0-5
  final int estimatedDeliveryMinutes;
  final double? minOrderAmount;

  const NearbyBusiness({
    required this.id,
    required this.name,
    required this.cuisineType,
    required this.distanceKm,
    this.rating = 0,
    required this.estimatedDeliveryMinutes,
    this.minOrderAmount,
  });
}

/// Bir işletmenin yüksek puanlı, öne çıkan ürünü — sepeti zenginleştirmek
/// için önerilen tek bir ürün.
class HighRatedDish {
  final String id;
  final String dishName;
  final String businessName;
  final double price;
  final String currency;
  final double rating; // 0-5
  final int? ratingCount;

  const HighRatedDish({
    required this.id,
    required this.dishName,
    required this.businessName,
    required this.price,
    this.currency = "TRY",
    this.rating = 0,
    this.ratingCount,
  });
}
