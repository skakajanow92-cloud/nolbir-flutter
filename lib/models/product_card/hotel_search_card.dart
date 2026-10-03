import '../feed_card/base.dart';

enum StayType { nightly, hourly }

enum MealPlan { none, breakfast, halfBoard, fullBoard, allInclusive }

extension MealPlanLabel on MealPlan {
  String get label {
    switch (this) {
      case MealPlan.none:
        return "Yemeksiz";
      case MealPlan.breakfast:
        return "Kahvaltı Dahil";
      case MealPlan.halfBoard:
        return "Yarım Pansiyon";
      case MealPlan.fullBoard:
        return "Tam Pansiyon";
      case MealPlan.allInclusive:
        return "Her Şey Dahil";
    }
  }
}

/// Orta tab için: otel/konaklama arama formunu sunan kart. Lokasyon
/// ülke/kent/mahalle kademeli serbest metin olarak girilir (backend'den
/// otomatik tamamlama gelince bu alanlar bir autocomplete'e dönüşecek —
/// şimdilik öneri çipleriyle desteklenen düz metin alanları).
class HotelSearchCard extends FeedCard {
  final String platformName;
  final String platformLogoUrl;
  final String description;
  final List<String> popularDestinations;

  const HotelSearchCard({
    required String id,
    required this.platformName,
    required this.platformLogoUrl,
    required this.description,
    this.popularDestinations = const [],
  }) : super(id);
}
