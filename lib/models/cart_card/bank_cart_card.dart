import '../feed_card/base.dart';
import '../bank_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin altıncı üyesi: Banka Ürünleri Sepeti. Diğer
/// sepetlerden farklı olarak "ödeme" burada bir SONUÇ değil bir
/// BAŞLANGIÇ — her ürün, para transferiyle açılan (vadeli mevduat,
/// kıymetli maden) ya da forma yönlendirip belge onayı bekleyen (kredi,
/// kiralık kasa, kripto) bir başvuru sürecinin içinde.
///
/// NOT: `cart` alanı `Cart`/`CartItem`/`CartType` modelini (`CartType.
/// banking`) kullanıyor; ürüne özel alanlar ve süreç adımları
/// `CartItem.metadata` üzerinden `BankCartItemExtras` extension'ıyla
/// okunuyor (bkz. bank_cart.dart). Aktif/tamamlanmış ayrımı — Kargo
/// modülündeki gibi — tarihe değil `isFullyProcessed` durumuna dayanır.
class BankCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<InterestRateComparisonGroup> comparisons;
  final List<RecommendedBankProduct> recommendations;

  const BankCartCard({
    required String id,
    required this.cart,
    this.comparisons = const [],
    this.recommendations = const [],
  }) : super(id);

  List<CartItem> get activeItems =>
      cart.items.where((i) => !i.isFullyProcessed).toList();

  List<CartItem> get completedItems =>
      cart.items.where((i) => i.isFullyProcessed).toList();

  @override
  (String, String) toCollectionPreview() => ("Banka Ürünleri Sepeti", "");
}
