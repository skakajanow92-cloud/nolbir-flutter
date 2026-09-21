import 'base.dart';
import '../market_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin ilk üyesi: Market Sepeti. Profil
/// modüllerinden farklı bir kart ailesi — kullanıcının SAHİP OLDUĞU
/// değil, SATIN ALMAYA HAZIRLANDIĞI şeyleri gösteriyor.
///
/// NOT: `cart` alanı mevcut `Cart`/`CartItem`/`CartType` modelini
/// (bkz. cart.dart) yeniden kullanıyor — market/satıcı adı gibi bilgi
/// `CartItem.metadata` üzerinden `MarketCartItemExtras` extension'ıyla
/// okunuyor (bkz. market_cart.dart).
class MarketCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<RecommendedProduct> recommendations;
  final List<PriceComparisonGroup> priceComparisons;

  const MarketCartCard({
    required String id,
    required this.cart,
    this.recommendations = const [],
    this.priceComparisons = const [],
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => ("Market Sepeti", "");
}