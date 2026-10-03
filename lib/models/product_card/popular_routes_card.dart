import '../feed_card/base.dart';

class PopularRouteItem {
  final String destinationName;
  final String imageUrl;
  final String fromCity;
  final String toCity;
  final double startingPrice;
  final String currency;
  final String? tag; // "Trend", "Kampanyalı" gibi

  const PopularRouteItem({
    required this.destinationName,
    required this.imageUrl,
    required this.fromCity,
    required this.toCity,
    required this.startingPrice,
    this.currency = "TRY",
    this.tag,
  });
}

/// Orta tab için: popüler rotaları/gezilecek yerleri tanıtan reklam
/// niteliğinde kart. Şimdilik dokunma, bir arama formuna geçiş
/// yapmıyor — sadece görsel keşif. (bkz. aşağıdaki not)
class PopularRoutesCard extends FeedCard {
  final String title;
  final String subtitle;
  final List<PopularRouteItem> routes;

  const PopularRoutesCard({
    required String id,
    required this.title,
    required this.subtitle,
    required this.routes,
  }) : super(id);
}
