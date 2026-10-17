import '../feed_card/base.dart';
import '../subscription_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin onuncu üyesi: Abonelik Sepeti. Farklı
/// koleksiyon sahiplerinden, yayıncılardan ve yapımcı şirketlerden
/// alınmış, henüz ödenmemiş aboneliklerin sepet hali.
///
/// NOT: `cart` alanı `CartType.subscription` kullanıyor; aboneliğe özel
/// alanlar `CartItem.metadata` üzerinden `SubscriptionCartItemExtras`
/// ile okunuyor (bkz. subscription_cart.dart). Tüm kalemlerin TRY
/// olduğu varsayılıyor.
class SubscriptionCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<SubscriptionTierGroup> tierComparisons;
  final List<RecommendedSubscriptionPlan> recommendations;

  const SubscriptionCartCard({
    required String id,
    required this.cart,
    this.tierComparisons = const [],
    this.recommendations = const [],
  }) : super(id);

  /// Kalemleri sahip türüne göre gruplar; enum sırası korunur, boş
  /// türler dahil edilmez.
  Map<SubscriptionOwnerKind, List<CartItem>> get itemsByOwnerKind {
    final map = <SubscriptionOwnerKind, List<CartItem>>{};
    for (final kind in SubscriptionOwnerKind.values) {
      final items = cart.items.where((i) => i.subOwnerKind == kind).toList();
      if (items.isNotEmpty) map[kind] = items;
    }
    return map;
  }

  /// Bugün tahsil edilecek toplam — ücretsiz denemedeki kalemler 0 sayılır.
  double get totalDueToday =>
      cart.items.fold(0.0, (sum, i) => sum + i.subChargedToday);

  /// Farklı fatura dönemleri aylık karşılığa çevrilerek toplanır.
  double get totalMonthlyEquivalent =>
      cart.items.fold(0.0, (sum, i) => sum + i.subLineMonthlyEquivalent);

  /// Ücretsiz denemesi olan kalemler, denemesi en önce bitenden başlayarak.
  List<CartItem> get itemsWithTrial =>
      cart.items.where((i) => i.subHasTrial).toList()
        ..sort((a, b) => a.subTrialDays.compareTo(b.subTrialDays));

  @override
  (String, String) toCollectionPreview() => ("Abonelik Sepeti", "");
}
