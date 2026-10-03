import '../feed_card/base.dart';

enum FoodCategory { starter, mainCourse, dessert, beverage, snack }

extension FoodCategoryLabel on FoodCategory {
  String get label {
    switch (this) {
      case FoodCategory.starter:
        return "Başlangıç";
      case FoodCategory.mainCourse:
        return "Ana Yemek";
      case FoodCategory.dessert:
        return "Tatlı";
      case FoodCategory.beverage:
        return "İçecek";
      case FoodCategory.snack:
        return "Atıştırmalık";
    }
  }
}

enum DietaryTag { vegetarian, vegan, glutenFree, spicy, lactoseFree }

extension DietaryTagLabel on DietaryTag {
  String get label {
    switch (this) {
      case DietaryTag.vegetarian:
        return "Vejetaryen";
      case DietaryTag.vegan:
        return "Vegan";
      case DietaryTag.glutenFree:
        return "Glutensiz";
      case DietaryTag.spicy:
        return "Acılı";
      case DietaryTag.lactoseFree:
        return "Laktozsuz";
    }
  }
}

/// Orta tab için: tek bir yemek/içecek ürününü, işletme logosu altında
/// tanıtan tam sayfa kart. Diğer "tek ürün" ilan kartlarıyla (banka,
/// sigorta, e-ticaret) aynı iskeleti paylaşır; aradaki fark sadece alan
/// kümesi. Sektör genellemesi geldiğinde (kuyumcu/çiçekçi) muhtemelen bu
/// sınıf `BusinessItemCard` gibi daha genel bir isme taşınacak.
class FoodItemCard extends FeedCard implements Collectible {
  final String businessName;
  final String businessLogoUrl;
  final String businessType; // "Kafe", "Lokanta", "Fırın" vb. — serbest metin
  final String itemName;
  final String description;
  final List<String> imageUrls;
  final double price;
  final double? discountedPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final FoodCategory category;
  final List<DietaryTag> dietaryTags;
  final int prepTimeMinutes;
  final String? detailUrl;

  const FoodItemCard({
    required String id,
    required this.businessName,
    required this.businessLogoUrl,
    required this.businessType,
    required this.itemName,
    required this.description,
    required this.price,
    this.imageUrls = const [],
    this.discountedPrice,
    this.currency = "TRY",
    this.rating = 0,
    this.reviewCount = 0,
    this.category = FoodCategory.mainCourse,
    this.dietaryTags = const [],
    this.prepTimeMinutes = 20,
    this.detailUrl,
  }) : super(id);

  double get effectivePrice => discountedPrice ?? price;

  int? get discountPercent {
    if (discountedPrice == null || discountedPrice! >= price || price == 0)
      return null;
    return (((price - discountedPrice!) / price) * 100).round();
  }

  @override
  (String, String) toCollectionPreview() => (
    "$businessName · $itemName",
    imageUrls.isNotEmpty ? imageUrls.first : businessLogoUrl,
  );
}
