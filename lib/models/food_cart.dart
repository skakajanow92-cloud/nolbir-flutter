import 'cart.dart';

/// `CartItem.metadata` üzerinden yemek sepetine özel alanları okuyan
/// yardımcı extension (bkz. market_cart.dart/hotel_cart.dart'taki aynı
/// yaklaşım).
extension FoodCartItemExtras on CartItem {
  String get restaurantName =>
      (metadata['restaurantName'] as String?) ?? "Bilinmeyen İşletme";
  String? get optionsLabel => metadata['options'] as String?; // örn. "Büyük Boy · Ekstra Peynir"
  String? get orderNote => metadata['note'] as String?; // örn. "Acısız olsun"
}

/// İşletme türü.
enum VenueType { restaurant, cafe, fastFood, bakery, dessert }

extension VenueTypeLabel on VenueType {
  String get label => switch (this) {
        VenueType.restaurant => "Restoran",
        VenueType.cafe => "Kafe",
        VenueType.fastFood => "Fast Food",
        VenueType.bakery => "Fırın",
        VenueType.dessert => "Tatlıcı",
      };
}

/// Bir işletmenin sipariş kuralları.
///
/// Yemek sepetinin asıl özelliği: her işletmenin kendi minimum sepet
/// tutarı, teslimat ücreti ve ücretsiz teslimat eşiği var — bu yüzden
/// sepet kalemleri işletmeye göre gruplanıp her biri kendi kurallarıyla
/// değerlendiriliyor (bkz. RestaurantOrderSummary).
class RestaurantTerms {
  final String id;
  final String restaurantName;
  final VenueType venueType;
  final double deliveryFee;
  final double minOrderAmount;
  final double? freeDeliveryThreshold;
  final int? estimatedDeliveryMinutes;
  final double? rating; // 0-5

  const RestaurantTerms({
    required this.id,
    required this.restaurantName,
    this.venueType = VenueType.restaurant,
    this.deliveryFee = 0,
    this.minOrderAmount = 0,
    this.freeDeliveryThreshold,
    this.estimatedDeliveryMinutes,
    this.rating,
  });
}

/// Tek bir işletmeden verilen siparişin özeti: kalemler + o işletmenin
/// kurallarına göre hesaplanan tutarlar.
///
/// BİLİNÇLİ TASARIM KARARI: Teslimat ücreti, toplam ve "minimuma ne
/// kadar kaldı" bilgileri SAKLANMIYOR — kalemlerden ve işletme
/// kurallarından CANLI hesaplanıyor (bkz. taxi.dart/cargo.dart/
/// hotel_cart.dart'taki "saklamak yerine türet" yaklaşımı). Kalem
/// eklenip çıkarıldıkça tutarlar tek kaynaktan güncel kalır.
class RestaurantOrderSummary {
  final RestaurantTerms terms;
  final List<CartItem> items;

  const RestaurantOrderSummary({required this.terms, required this.items});

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  bool get hasFreeDelivery {
    final threshold = terms.freeDeliveryThreshold;
    return threshold != null && subtotal >= threshold;
  }

  double get deliveryFee => hasFreeDelivery ? 0 : terms.deliveryFee;
  double get total => subtotal + deliveryFee;

  bool get meetsMinimum => subtotal >= terms.minOrderAmount;
  double get remainingToMinimum => meetsMinimum ? 0 : terms.minOrderAmount - subtotal;

  /// Ücretsiz teslimata ne kadar kaldığı — eşik yoksa ya da zaten
  /// aşıldıysa `null`.
  double? get remainingToFreeDelivery {
    final threshold = terms.freeDeliveryThreshold;
    if (threshold == null || subtotal >= threshold) return null;
    return threshold - subtotal;
  }

  /// Sepet kalemlerini işletme adına göre gruplar (ilk görünme sırası
  /// korunur) ve her grubu o işletmenin kurallarıyla eşleştirir. Kuralı
  /// tanımlı olmayan bir işletme için ücretsiz/limitsiz varsayılan
  /// kurallar kullanılır.
  static List<RestaurantOrderSummary> build(
    List<CartItem> items,
    List<RestaurantTerms> termsList,
  ) {
    final grouped = <String, List<CartItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.restaurantName, () => []).add(item);
    }
    return grouped.entries.map((entry) {
      final terms = termsList.where((t) => t.restaurantName == entry.key).firstOrNull ??
          RestaurantTerms(id: "fallback_${entry.key}", restaurantName: entry.key);
      return RestaurantOrderSummary(terms: terms, items: entry.value);
    }).toList();
  }
}

/// Kullanıcıya yakın bir işletme önerisi.
class NearbyVenue {
  final String id;
  final String name;
  final VenueType venueType;
  final String cuisine; // örn. "Burger", "Suşi", "Kahve"
  final double distanceKm;
  final int estimatedDeliveryMinutes;
  final double? rating; // 0-5
  final bool isOpen;

  const NearbyVenue({
    required this.id,
    required this.name,
    required this.venueType,
    required this.cuisine,
    required this.distanceKm,
    required this.estimatedDeliveryMinutes,
    this.rating,
    this.isOpen = true,
  });
}

/// Bir ürün önerisinin gerekçesi.
enum FoodSuggestionReason { topRatedNearby, pairsWithCart, fromCartVenue }

extension FoodSuggestionReasonLabel on FoodSuggestionReason {
  String get label => switch (this) {
        FoodSuggestionReason.topRatedNearby => "Yüksek Puanlı",
        FoodSuggestionReason.pairsWithCart => "Yanına İyi Gider",
        FoodSuggestionReason.fromCartVenue => "Sepetindeki İşletmeden",
      };
}

/// Yakındaki işletmelerden yüksek puanlı, sepeti zenginleştirmek için
/// önerilen tek bir ürün.
class TopRatedProduct {
  final String id;
  final String title;
  final String venueName;
  final double price;
  final String currency;
  final double rating; // 0-5
  final int? ratingCount;
  final FoodSuggestionReason reason;

  const TopRatedProduct({
    required this.id,
    required this.title,
    required this.venueName,
    required this.price,
    this.currency = "TRY",
    required this.rating,
    this.ratingCount,
    required this.reason,
  });
}
