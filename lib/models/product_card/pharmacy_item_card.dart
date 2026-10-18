import '../feed_card/base.dart';

class PharmacyItemCard extends FeedCard implements Collectible {
  final String pharmacyName;
  final String pharmacyLogoUrl;
  final String itemName;
  final String description;
  final List<String> imageUrls;
  final bool requiresPrescription;
  final double price;
  final double? discountedPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final String? activeIngredient;
  final String?
  packageInfo; // "20 tablet" gibi ambalaj bilgisi — kullanım talimatı değil
  final String? detailUrl;

  const PharmacyItemCard({
    required String id,
    required this.pharmacyName,
    required this.pharmacyLogoUrl,
    required this.itemName,
    required this.description,
    required this.price,
    this.requiresPrescription = false,
    this.imageUrls = const [],
    this.discountedPrice,
    this.currency = "TRY",
    this.rating = 0,
    this.reviewCount = 0,
    this.activeIngredient,
    this.packageInfo,
    this.detailUrl,
  }) : super(id);

  double get effectivePrice => discountedPrice ?? price;

  @override
  (String, String) toCollectionPreview() => (
    "$pharmacyName · $itemName",
    imageUrls.isNotEmpty ? imageUrls.first : pharmacyLogoUrl,
  );
}
