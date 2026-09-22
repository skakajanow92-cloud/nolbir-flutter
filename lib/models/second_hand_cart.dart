import 'cart.dart';

/// Bir ürünün durumu — sıfır/az kullanılmış/ikinci el ayrımı.
///
/// NOT: Kullanıcının istediği ikili ayrımın (sıfır/ikinci el) üzerine,
/// ikinci el pazaryerlerinde standart olan ara durum (az kullanılmış)
/// bilerek eklendi.
enum ItemCondition { brandNew, likeNew, used }

extension ItemConditionLabel on ItemCondition {
  String get label => switch (this) {
        ItemCondition.brandNew => "Sıfır",
        ItemCondition.likeNew => "Az Kullanılmış (Sıfır Gibi)",
        ItemCondition.used => "İkinci El",
      };
}

/// `CartItem.metadata` üzerinden ikinci el sepetine özel alanları okuyan
/// yardımcı extension.
///
/// BİLİNÇLİ TASARIM KARARI: market_cart.dart'taki `MarketCartItemExtras`
/// ile AYNI yaklaşım — `CartItem`e sabit alan eklemek yerine `metadata`
/// kullanılıyor. Buradaki satıcı kurumsal bir market DEĞİL, bireysel bir
/// kişi; bu yüzden alan adları (`sellerName`, `sellerRating`) market
/// sepetindeki `marketName`den kasıtlı olarak ayrı tutuldu.
extension SecondHandCartItemExtras on CartItem {
  String get sellerName => (metadata['sellerName'] as String?) ?? "Bilinmeyen Satıcı";
  double? get sellerRating => metadata['sellerRating'] as double?;
  String? get sellerLocation => metadata['sellerLocation'] as String?;
  ItemCondition get condition =>
      (metadata['condition'] as ItemCondition?) ?? ItemCondition.used;
}

/// Bir ilanın gösterilme gerekçesi.
enum ListingRecommendationReason { similarListing, moreFromSeller }

extension ListingRecommendationReasonLabel on ListingRecommendationReason {
  String get label => switch (this) {
        ListingRecommendationReason.similarListing => "Benzer İlan",
        ListingRecommendationReason.moreFromSeller => "Bu Satıcıdan",
      };
}

/// Kullanıcıya önerilen tek bir ikinci el ilanı.
class RecommendedListing {
  final String id;
  final String title;
  final double price;
  final String currency;
  final String sellerName;
  final ItemCondition condition;
  final ListingRecommendationReason reason;

  const RecommendedListing({
    required this.id,
    required this.title,
    required this.price,
    this.currency = "TRY",
    required this.sellerName,
    required this.condition,
    required this.reason,
  });
}

/// Aynı ürünü satan bireysel bir satıcının tekil ilanı.
class IndividualSellerOffer {
  final String id;
  final String sellerName;
  final double? sellerRating; // 0-5
  final ItemCondition condition;
  final double price;
  final String currency;
  final String? location;

  const IndividualSellerOffer({
    required this.id,
    required this.sellerName,
    this.sellerRating,
    required this.condition,
    required this.price,
    this.currency = "TRY",
    this.location,
  });
}

/// Benzer/aynı ürünü satan farklı bireysel satıcıların ilanlarının
/// toplandığı grup.
///
/// NOT: market_cart.dart'taki `PriceComparisonGroup` ile AYNI "saklamak
/// yerine türet" yaklaşımı — en ucuz/en yüksek puanlı teklif SAKLANMIYOR,
/// `offers` listesinden CANLI hesaplanıyor.
class SimilarListingGroup {
  final String id;
  final String listingTitle;
  final String? imageUrl;
  final List<IndividualSellerOffer> offers;

  const SimilarListingGroup({
    required this.id,
    required this.listingTitle,
    this.imageUrl,
    this.offers = const [],
  });

  List<IndividualSellerOffer> get sortedByPrice =>
      offers.toList()..sort((a, b) => a.price.compareTo(b.price));

  IndividualSellerOffer? get cheapestOffer {
    if (offers.isEmpty) return null;
    return offers.reduce((a, b) => a.price <= b.price ? a : b);
  }

  /// En yüksek puanlı satıcının teklifi — fiyat dışında da bir sinyal
  /// vermek için (en ucuz her zaman en güvenilir olmayabilir).
  IndividualSellerOffer? get highestRatedOffer {
    final rated = offers.where((o) => o.sellerRating != null);
    if (rated.isEmpty) return null;
    return rated.reduce((a, b) => a.sellerRating! >= b.sellerRating! ? a : b);
  }
}
