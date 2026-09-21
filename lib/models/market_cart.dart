import 'cart.dart';

/// `CartItem.metadata` üzerinden market sepetine özel alanları okuyan
/// yardımcı extension.
///
/// BİLİNÇLİ TASARIM KARARI: `CartItem`e market adı gibi sabit bir alan
/// EKLENMEDİ — cart.dart'ın kendi tasarım notunda belirttiği gibi
/// domain'e özel alanlar için `metadata` kullanılıyor. Bu extension o
/// sözleşmeyi tip güvenli hale getiriyor.
extension MarketCartItemExtras on CartItem {
  String get marketName => (metadata['marketName'] as String?) ?? "Bilinmeyen Market";
  String? get unitLabel => metadata['unit'] as String?; // örn. "1 kg", "500 ml"
}

/// Bir önerinin gösterilme gerekçesi.
enum RecommendationReason { similarProduct, moreFromMarket }

extension RecommendationReasonLabel on RecommendationReason {
  String get label => switch (this) {
        RecommendationReason.similarProduct => "Benzer Ürün",
        RecommendationReason.moreFromMarket => "Bu Marketten",
      };
}

/// Kullanıcıya önerilen tek bir ürün (sepetteki bir ürüne benzer ya da
/// sepetteki bir ürünün satıcısından başka bir ürün).
class RecommendedProduct {
  final String id;
  final String title;
  final String? imageUrl;
  final double price;
  final String currency;
  final String marketName;
  final RecommendationReason reason;

  const RecommendedProduct({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.price,
    this.currency = "TRY",
    required this.marketName,
    required this.reason,
  });
}

/// Bir ürünün tek bir marketteki fiyat teklifi.
class MarketOffer {
  final String id;
  final String marketName;
  final double price;
  final String currency;
  final bool inStock;

  const MarketOffer({
    required this.id,
    required this.marketName,
    required this.price,
    this.currency = "TRY",
    this.inStock = true,
  });
}

/// Aynı ürünün farklı marketlerdeki fiyat tekliflerinin toplandığı grup.
///
/// BİLİNÇLİ TASARIM KARARI: En ucuz teklif SAKLANMIYOR — `cheapestOffer`
/// ile `offers` listesinden CANLI hesaplanıyor (bkz. taxi.dart/cargo.dart/
/// bet.dart'taki aynı "saklamak yerine türet" yaklaşımı). Fiyatlar
/// değiştikçe tek kaynaktan (teklif listesinden) güncel kalır.
class PriceComparisonGroup {
  final String id;
  final String productName;
  final String? imageUrl;
  final String? unitLabel;
  final List<MarketOffer> offers;

  const PriceComparisonGroup({
    required this.id,
    required this.productName,
    this.imageUrl,
    this.unitLabel,
    this.offers = const [],
  });

  List<MarketOffer> get sortedByPrice {
    final inStockOffers = offers.where((o) => o.inStock).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    final outOfStock = offers.where((o) => !o.inStock).toList();
    return [...inStockOffers, ...outOfStock];
  }

  MarketOffer? get cheapestOffer {
    final inStockOffers = offers.where((o) => o.inStock);
    if (inStockOffers.isEmpty) return null;
    return inStockOffers.reduce((a, b) => a.price <= b.price ? a : b);
  }

  /// En pahalı teklife göre en ucuzda ne kadar tasarruf edildiği (%).
  double? get savingsPercentVsHighest {
    final cheapest = cheapestOffer;
    if (cheapest == null || offers.length < 2) return null;
    final highest = offers.reduce((a, b) => a.price >= b.price ? a : b);
    if (highest.price == 0) return null;
    return ((highest.price - cheapest.price) / highest.price) * 100;
  }
}
