import '../feed_card/base.dart';
import 'food_item_card.dart' show FoodCategory, DietaryTag;

/// Bir işletme menüsündeki tek ürün. `FoodItemCard`'ın aksine kendi
/// işletme bilgisini TAŞIMAZ — işletme bağlamı zaten `BusinessMenuCard`
/// seviyesinde tek ve ortak. (Ürün grid kartındaki `EcommerceProductCard`
/// kullanımıyla kıyasla: orada ürünler FARKLI mağazalardan geldiği için
/// her birinin kendi mağaza bilgisini taşıması gerekiyordu — burada tek
/// işletme olduğu için bu tekrar gereksiz.)
class MenuItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double? discountedPrice;
  final FoodCategory category;
  final List<DietaryTag> dietaryTags;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl = "",
    this.discountedPrice,
    this.category = FoodCategory.mainCourse,
    this.dietaryTags = const [],
  });

  double get effectivePrice => discountedPrice ?? price;
}

/// Orta tab için: bir kafe/lokanta/işletmenin birkaç ürününü liste
/// halinde sunan kart. Hızlı göz atma ve karşılaştırma için tasarlandı —
/// her satırda doğrudan "sepete ekle" var, ürüne dokunmak detay sheet'i
/// açar (galeri, açıklama, diyet etiketleri).
class BusinessMenuCard extends FeedCard {
  final String businessName;
  final String businessLogoUrl;
  final String businessType;
  final double rating;
  final int reviewCount;
  final int deliveryTimeMinutes;
  final double deliveryFee;
  final double minOrderAmount;
  final double? distanceKm;
  final String currency;
  final List<MenuItem> items;

  const BusinessMenuCard({
    required String id,
    required this.businessName,
    required this.businessLogoUrl,
    required this.businessType,
    required this.items,
    this.rating = 0,
    this.reviewCount = 0,
    this.deliveryTimeMinutes = 30,
    this.deliveryFee = 0,
    this.minOrderAmount = 0,
    this.distanceKm,
    this.currency = "TRY",
  }) : super(id);
}
