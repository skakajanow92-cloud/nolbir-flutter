import '../feed_card/base.dart';
import '../second_hand_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin ikinci üyesi: İkinci El Sepeti. Market
/// Sepeti Kartı ile aynı mimariyi izliyor ama satıcı bireysel bir kişi
/// (kurumsal market değil) ve ürünlerin bir "durum"u var (sıfır/az
/// kullanılmış/ikinci el).
///
/// NOT: `cart` alanı yine mevcut `Cart`/`CartItem`/`CartType` modelini
/// (bkz. cart.dart, `CartType.secondHand`) kullanıyor — bireysel satıcı
/// bilgisi ve ürün durumu `CartItem.metadata` üzerinden
/// `SecondHandCartItemExtras` extension'ıyla okunuyor (bkz.
/// second_hand_cart.dart).
class SecondHandCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<SimilarListingGroup> similarListings;
  final List<RecommendedListing> recommendations;

  const SecondHandCartCard({
    required String id,
    required this.cart,
    this.similarListings = const [],
    this.recommendations = const [],
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => ("İkinci El Sepeti", "");
}