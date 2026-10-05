import '../feed_card/base.dart';
import 'jewelry_common.dart';

class JewelryCatalogItem {
  final String id;
  final String name;
  final String imageUrl;
  final JewelryCategory category;
  final MetalType metalType;
  final int karat;
  final double weightGrams;
  final double price;
  final double? discountedPrice;

  const JewelryCatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.metalType,
    required this.karat,
    required this.weightGrams,
    required this.price,
    this.imageUrl = "",
    this.discountedPrice,
  });
}

/// Orta tab için: bir kuyumcu markasının herkese açık, hazır satın
/// alınabilir ürünlerini grid halinde sunan kart. `BusinessMenuCard`'ın
/// aksine burada GRID seçildi — kuyumculuk görsel ağırlıklı bir sektör,
/// kısa ürün adları (yemekteki gibi uzun açıklama değil) grid'e daha
/// uygun. Aynı aile içinde sektöre göre liste/grid kararının farklı
/// olabileceğinin bir örneği.
class JewelryCatalogCard extends FeedCard {
  final String brandName;
  final String brandLogoUrl;
  final double rating;
  final int reviewCount;
  final String currency;
  final List<JewelryCatalogItem> items;

  const JewelryCatalogCard({
    required String id,
    required this.brandName,
    required this.brandLogoUrl,
    required this.items,
    this.rating = 0,
    this.reviewCount = 0,
    this.currency = "TRY",
  }) : super(id);
}
