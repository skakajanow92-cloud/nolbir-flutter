/// Kullanıcının favori bir yemeği.
class FavoriteFood {
  final String id;
  final String name;
  final String? cuisine; // örn. "Türk Mutfağı", "İtalyan"

  const FavoriteFood({required this.id, required this.name, this.cuisine});
}

/// Favori bir restoran ya da kafe.
class FavoriteRestaurant {
  final String id;
  final String name;
  final String cuisine;
  final String location;

  const FavoriteRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.location,
  });
}

/// Düzenli tekrar eden bir sipariş alışkanlığı.
class RecurringOrder {
  final String id;
  final String restaurantName;
  final String orderDescription; // örn. "Büyük Boy Karışık Pizza"
  final String frequency; // örn. "Her Cuma akşamı"

  const RecurringOrder({
    required this.id,
    required this.restaurantName,
    required this.orderDescription,
    required this.frequency,
  });
}

/// Bir kafenin abonelik/sadakat/indirim kartı. Ya damga bazlı (stamps) ya
/// da sabit indirim yüzdesi (discountPercent) olabilir, ikisi de olabilir.
class CafeLoyaltyCard {
  final String id;
  final String cafeName;
  final int? stampsCollected;
  final int? stampsRequired;
  final String? rewardDescription;
  final double? discountPercent;

  const CafeLoyaltyCard({
    required this.id,
    required this.cafeName,
    this.stampsCollected,
    this.stampsRequired,
    this.rewardDescription,
    this.discountPercent,
  });

  bool get hasStampProgress =>
      stampsCollected != null && stampsRequired != null && stampsRequired! > 0;

  double get progress =>
      hasStampProgress ? (stampsCollected! / stampsRequired!).clamp(0, 1) : 0;
}
