import '../feed_card/base.dart';
import 'jewelry_common.dart';

/// Orta tab için: bir kuyumcu markasının tek, hazır (stoklu) ürününü
/// tanıtan tam sayfa kart. `FoodItemCard` ile aynı rol — marka logosu
/// altında tek ürün reklamı — alan kümesi farklı.
class JewelryItemCard extends FeedCard implements Collectible {
  final String brandName;
  final String brandLogoUrl;
  final String itemName;
  final String description;
  final List<String> imageUrls;
  final JewelryCategory category;
  final MetalType metalType;
  final int karat; // 8, 14, 18, 21, 22, 24
  final double weightGrams;
  final List<String> gemstones;
  final double price;
  final double? discountedPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final String? detailUrl;

  const JewelryItemCard({
    required String id,
    required this.brandName,
    required this.brandLogoUrl,
    required this.itemName,
    required this.description,
    required this.category,
    required this.metalType,
    required this.karat,
    required this.weightGrams,
    required this.price,
    this.imageUrls = const [],
    this.gemstones = const [],
    this.discountedPrice,
    this.currency = "TRY",
    this.rating = 0,
    this.reviewCount = 0,
    this.detailUrl,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (
    "$brandName · $itemName",
    imageUrls.isNotEmpty ? imageUrls.first : brandLogoUrl,
  );
}
