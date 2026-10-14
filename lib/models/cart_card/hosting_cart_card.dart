import '../feed_card/base.dart';
import '../hosting_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin dokuzuncu üyesi: Hosting Sepeti. Kullanıcının
/// farklı hosting şirketlerinden kiralamak istediği paketler (paylaşımlı,
/// VPS, VDS, dedicated).
///
/// NOT: `cart` alanı `CartType.hosting` kullanıyor; pakete özel alanlar
/// `CartItem.metadata` üzerinden `HostingCartItemExtras` ile okunuyor
/// (bkz. hosting_cart.dart). Tüm kalemlerin TRY olduğu varsayılıyor.
class HostingCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<HostingPlanComparisonGroup> priceComparisons;
  final List<RecommendedHostingAddOn> addOns;

  const HostingCartCard({
    required String id,
    required this.cart,
    this.priceComparisons = const [],
    this.addOns = const [],
  }) : super(id);

  /// Kalemleri hosting firmasına göre gruplar — her firma ayrı
  /// faturalandırır.
  Map<String, List<CartItem>> get itemsByProvider {
    final map = <String, List<CartItem>>{};
    for (final item in cart.items) {
      map.putIfAbsent(item.hostingProvider, () => []).add(item);
    }
    return map;
  }

  /// Tüm kalemlerin ilk ödeme toplamı (dönem fiyatı + kurulum ücretleri).
  double get totalFirstPayment =>
      cart.items.fold(0.0, (sum, i) => sum + i.hostingFirstPayment);

  /// Farklı fatura dönemleri aylık karşılığa çevrilerek toplanır (bkz.
  /// hosting.dart'taki BillingCycle.monthDivisor).
  double get totalMonthlyEquivalent =>
      cart.items.fold(0.0, (sum, i) => sum + i.hostingLineMonthlyEquivalent);

  @override
  (String, String) toCollectionPreview() => ("Hosting Sepeti", "");
}
