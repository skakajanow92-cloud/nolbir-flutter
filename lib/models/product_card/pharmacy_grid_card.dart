import '../feed_card/base.dart';
import 'pharmacy_item_card.dart';

class PharmacyGridCard extends FeedCard {
  final String title;
  final String? subtitle;
  final List<PharmacyItemCard> items;

  const PharmacyGridCard({
    required String id,
    required this.title,
    required this.items,
    this.subtitle,
  }) : super(id);
}
