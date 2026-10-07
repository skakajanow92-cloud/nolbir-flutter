import '../feed_card/base.dart';
import 'gift_common.dart';

/// `JewelryItemCard` ile aynı rol: işletme logosu altında tek, hazır
/// ürün reklamı. Çiçek, hediye sepeti, oyuncak vb. hepsi aynı kart —
/// ayrım sadece `category`.
class GiftItemCard extends FeedCard implements Collectible {
  final String businessName;
  final String businessLogoUrl;
  final String itemName;
  final String description;
  final List<String> imageUrls;
  final GiftCategory category;
  final List<Occasion> occasions;
  final double price;
  final double? discountedPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final bool sameDayDelivery;
  final bool includesMessageCard;
  final String? detailUrl;

  const GiftItemCard({
    required String id,
    required this.businessName,
    required this.businessLogoUrl,
    required this.itemName,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrls = const [],
    this.occasions = const [],
    this.discountedPrice,
    this.currency = "TRY",
    this.rating = 0,
    this.reviewCount = 0,
    this.sameDayDelivery = false,
    this.includesMessageCard = false,
    this.detailUrl,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (
    "$businessName · $itemName",
    imageUrls.isNotEmpty ? imageUrls.first : businessLogoUrl,
  );
}
