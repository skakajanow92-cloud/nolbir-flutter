import '../feed_card/base.dart';
import 'gift_common.dart';

/// `CustomJewelryOrderCard` ile aynı rol: talep bir seçenek listesine
/// değil, bir özet dialog'una gider.
class CustomGiftOrderCard extends FeedCard {
  final String businessName;
  final String businessLogoUrl;
  final String description;
  final List<GiftCategory> availableCategories;
  final List<Occasion> availableOccasions;
  final double minBudget;
  final double maxBudget;
  final String currency;

  const CustomGiftOrderCard({
    required String id,
    required this.businessName,
    required this.businessLogoUrl,
    required this.description,
    this.availableCategories = const [],
    this.availableOccasions = const [],
    this.minBudget = 0,
    this.maxBudget = 0,
    this.currency = "TRY",
  }) : super(id);
}
