import 'base.dart';

class SubscriptionCard extends FeedCard implements Collectible {
  final String serviceName;
  final String description;
  final double monthlyPrice;

  const SubscriptionCard({
    required String id,
    required this.serviceName,
    required this.description,
    required this.monthlyPrice,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (serviceName, "");
}
