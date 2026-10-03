import '../feed_card/base.dart';

enum DiningOption { delivery, pickup, dineIn }

extension DiningOptionLabel on DiningOption {
  String get label {
    switch (this) {
      case DiningOption.delivery:
        return "Paket Servis";
      case DiningOption.pickup:
        return "Gel Al";
      case DiningOption.dineIn:
        return "Masada";
    }
  }
}

/// Orta tab için: lokanta/kafe arama formunu sunan kart. Konum şimdilik
/// serbest metin (bkz. otel kartındaki aynı karar) — gerçek autocomplete
/// backend bağlanınca eklenecek.
class FoodPlaceSearchCard extends FeedCard {
  final String platformName;
  final String platformLogoUrl;
  final String description;
  final List<String> cuisineTypes;
  final List<String> popularLocations;

  const FoodPlaceSearchCard({
    required String id,
    required this.platformName,
    required this.platformLogoUrl,
    required this.description,
    this.cuisineTypes = const [],
    this.popularLocations = const [],
  }) : super(id);
}
