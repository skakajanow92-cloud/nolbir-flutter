import 'base.dart';
import '../taxi.dart';

/// On yedinci profil modülü: kullanıcının taksi kullanım alışkanlıkları
/// — bulunduğu konum, kayıtlı yerlere (ev/iş/eğlence) mesafe, sık
/// kullanılan rotalar, saatlik yoğunluk analizi, planlı/düzenli
/// yolculuklar ve favori sürücüler.
///
/// NOT: Kayıtlı yerlere mesafe SAKLANMIYOR, `CurrentLocation.distanceKmTo`
/// ile canlı hesaplanıyor (bkz. taxi.dart'taki gerekçe) — bu yüzden bu
/// kartta statik bir "mesafe" alanı yok, konum + kayıtlı yerler listesi
/// yeterli.
class TaxiProfileCard extends FeedCard implements Collectible {
  final CurrentLocation? currentLocation;
  final List<SavedPlace> savedPlaces;
  final List<FrequentRoute> frequentRoutes;
  final List<HourlyRideActivity> hourlyActivity;
  final List<ScheduledRide> scheduledRides;
  final List<FavoriteTaxiDriver> favoriteDrivers;

  const TaxiProfileCard({
    required String id,
    this.currentLocation,
    this.savedPlaces = const [],
    this.frequentRoutes = const [],
    this.hourlyActivity = const [],
    this.scheduledRides = const [],
    this.favoriteDrivers = const [],
  }) : super(id);

  int get maxHourlyRideCount => hourlyActivity.isEmpty
      ? 0
      : hourlyActivity.map((h) => h.rideCount).reduce((a, b) => a > b ? a : b);

  /// En çok yolculuk yapılan saat dilimi — varsa özet banner'ı için.
  HourlyRideActivity? get busiestHour {
    if (hourlyActivity.isEmpty) return null;
    return hourlyActivity.reduce((a, b) => a.rideCount >= b.rideCount ? a : b);
  }

  @override
  (String, String) toCollectionPreview() => ("Taksi Profili", "");
}
