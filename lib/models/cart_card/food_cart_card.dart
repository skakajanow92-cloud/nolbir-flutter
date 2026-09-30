import '../feed_card/base.dart';
import '../food_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin beşinci üyesi: Yemek Sepeti. Restoran/kafe
/// gibi yemek hazırlayan işletmelerden verilmiş sipariş — sepeti
/// zenginleştirmek için yakındaki işletmeler ve onların yüksek puanlı
/// ürünleri.
///
/// NOT: `cart` alanı `Cart`/`CartItem`/`CartType` modelini (`CartType.
/// food`) kullanıyor; işletmeye özel alanlar `CartItem.metadata`
/// üzerinden `FoodCartItemExtras` extension'ıyla okunuyor (bkz.
/// food_cart.dart). Market Sepeti'nden farklı olarak fiyat
/// karşılaştırması YOK — aynı yemek farklı restoranlarda "aynı ürün"
/// sayılmaz.
class FoodCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<NearbyBusiness> nearbyBusinesses;
  final List<HighRatedDish> highRatedDishes;

  const FoodCartCard({
    required String id,
    required this.cart,
    this.nearbyBusinesses = const [],
    this.highRatedDishes = const [],
  }) : super(id);

  /// Sepet kalemlerini işletme adına göre gruplar — sepet market
  /// sepetindeki gibi birden fazla işletmeden oluşabilir.
  Map<String, List<CartItem>> get itemsByRestaurant {
    final map = <String, List<CartItem>>{};
    for (final item in cart.items) {
      map.putIfAbsent(item.restaurantName, () => []).add(item);
    }
    return map;
  }

  @override
  (String, String) toCollectionPreview() => ("Yemek Sepeti", "");
}