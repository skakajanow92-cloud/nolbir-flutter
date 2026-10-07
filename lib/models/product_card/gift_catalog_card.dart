import '../feed_card/base.dart';
import 'gift_common.dart';

class GiftCatalogItem {
  final String id;
  final String name;
  final String imageUrl;
  final GiftCategory category;
  final double price;
  final double? discountedPrice;
  final bool sameDayDelivery;

  const GiftCatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imageUrl = "",
    this.discountedPrice,
    this.sameDayDelivery = false,
  });
}

/// `JewelryCatalogCard` ile aynı karar: tek işletme, hafif ürün tipi,
/// grid sunum — hediye/çiçekçi de görsel ağırlıklı bir sektör.
class GiftCatalogCard extends FeedCard {
  final String businessName;
  final String businessLogoUrl;
  final double rating;
  final int reviewCount;
  final String currency;
  final List<GiftCatalogItem> items;

  const GiftCatalogCard({
    required String id,
    required this.businessName,
    required this.businessLogoUrl,
    required this.items,
    this.rating = 0,
    this.reviewCount = 0,
    this.currency = "TRY",
  }) : super(id);
}
