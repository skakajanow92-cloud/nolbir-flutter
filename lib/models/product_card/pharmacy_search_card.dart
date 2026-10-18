import '../feed_card/base.dart';

class PharmacySearchCard extends FeedCard {
  final String platformName;
  final String platformLogoUrl;
  final String description;

  const PharmacySearchCard({
    required String id,
    required this.platformName,
    required this.platformLogoUrl,
    required this.description,
  }) : super(id);
}
