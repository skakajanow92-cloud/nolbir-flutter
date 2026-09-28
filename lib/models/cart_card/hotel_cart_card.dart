import '../feed_card/base.dart';
import '../hotel_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin dördüncü üyesi: Otel Rezervasyon Sepeti.
/// Henüz ödenmemiş, otel tarafından belirli bir süre tutulan
/// rezervasyonlar; farklı platformlardaki fiyat karşılaştırması ve otel
/// önerileri.
///
/// NOT: `cart` alanı `Cart`/`CartItem`/`CartType` modelini
/// (`CartType.accommodation`) kullanıyor; otele özel alanlar
/// `CartItem.metadata` üzerinden `HotelCartItemExtras` extension'ıyla
/// okunuyor (bkz. hotel_cart.dart).
class HotelCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<HotelComparisonGroup> priceComparisons;
  final List<RecommendedHotel> recommendations;

  const HotelCartCard({
    required String id,
    required this.cart,
    this.priceComparisons = const [],
    this.recommendations = const [],
  }) : super(id);

  /// Tutma süresi 48 saat içinde dolacak (ya da dolmuş) rezervasyonlar,
  /// en yakın önce — alarm banner'ı için (bkz. Seyahat/Sağlık/Bilet
  /// modüllerindeki aynı alarm mantığı).
  List<CartItem> get itemsHoldExpiringSoon {
    final now = DateTime.now();
    return cart.items.where((i) {
      final hold = i.holdExpiresAt;
      return hold != null && hold.difference(now).inHours <= 48;
    }).toList()..sort((a, b) => a.holdExpiresAt!.compareTo(b.holdExpiresAt!));
  }

  @override
  (String, String) toCollectionPreview() => ("Otel Rezervasyon Sepeti", "");
}
