import '../feed_card/base.dart';

class PopularHotelItem {
  final String name;
  final String imageUrl;
  final String location;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final List<String> tags;
  final String? smartBadge;

  const PopularHotelItem({
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    this.tags = const [],
    this.smartBadge,
  });
}

/// Orta tab için: backend'in konum/rota bazlı akıllı analizle hazırladığı
/// öne çıkan otelleri tanıtan kart. Şimdilik salt görsel/keşif amaçlı —
/// bir otele dokunma davranışı (detay/rezervasyon akışı) bu adımda yok.
class PopularHotelsCard extends FeedCard {
  final String title;
  final String subtitle;
  final List<PopularHotelItem> hotels;

  const PopularHotelsCard({
    required String id,
    required this.title,
    required this.subtitle,
    required this.hotels,
  }) : super(id);
}
