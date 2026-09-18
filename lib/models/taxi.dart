import 'dart:math' as math;

/// Kayıtlı bir konumun kategorisi.
enum PlaceCategory { home, work, entertainment, custom }

extension PlaceCategoryLabel on PlaceCategory {
  String get label => switch (this) {
        PlaceCategory.home => "Ev",
        PlaceCategory.work => "İş Yeri",
        PlaceCategory.entertainment => "Eğlence Mekanı",
        PlaceCategory.custom => "Diğer",
      };
}

/// Kullanıcının kaydettiği sabit bir konum (ev, iş, sık gidilen mekan...).
class SavedPlace {
  final String id;
  final PlaceCategory category;
  final String label; // özel isim, örn. "Ofis" ya da "Ahmet'in Evi"
  final String address;
  final double latitude;
  final double longitude;

  const SavedPlace({
    required this.id,
    required this.category,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

/// Kullanıcının şu anki konumu.
///
/// BİLİNÇLİ TASARIM KARARI: Kayıtlı yerlere olan mesafe burada SABİT bir
/// sayı olarak TUTULMUYOR — `distanceKmTo` ile haversine formülüyle
/// CANLI hesaplanıyor. Konum her değiştiğinde mesafe otomatik güncel
/// kalır; ayrıca bu, `FrequentRoute`daki (geçmiş/alışkanlık) mesafeden
/// kavramsal olarak bilerek ayrı tutuluyor.
class CurrentLocation {
  final String label; // örn. "Kadıköy, İstanbul"
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const CurrentLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  /// Dünya üzerinde iki koordinat arası kuş uçuşu mesafe (km).
  double distanceKmTo(SavedPlace place) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(place.latitude - latitude);
    final dLon = _toRadians(place.longitude - longitude);
    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(place.latitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);
}

/// Kullanıcının sürekli/alışkanlık haline gelmiş bir gidiş-geliş rotası
/// (geçmiş sefer verisine dayanır — CurrentLocation'daki anlık mesafeden
/// FARKLI olarak burada `tripCount` ile "ne kadar sık" bilgisi taşınır).
class FrequentRoute {
  final String id;
  final String fromLabel;
  final String toLabel;
  final double avgDistanceKm;
  final int avgDurationMinutes;
  final int tripCount;

  const FrequentRoute({
    required this.id,
    required this.fromLabel,
    required this.toLabel,
    required this.avgDistanceKm,
    required this.avgDurationMinutes,
    required this.tripCount,
  });
}

/// Belirli bir saat diliminde kullanıcının kendi geçmiş taksi kullanım
/// yoğunluğu — "bu saatte taksi bulmak ne kadar sürüyor/ne kadar sık
/// kullanıyorum" analizini besler.
class HourlyRideActivity {
  final int hour; // 0-23
  final int rideCount;
  final int avgWaitMinutes;

  const HourlyRideActivity({
    required this.hour,
    required this.rideCount,
    required this.avgWaitMinutes,
  });

  String get hourLabel => "${hour.toString().padLeft(2, '0')}:00";
}

/// Kullanıcının düzenli/zamanlı olarak kullandığı bir taksi planı
/// (örn. her sabah işe gidiş).
class ScheduledRide {
  final String id;
  final String label; // örn. "İşe Gidiş"
  final List<int> daysOfWeek; // 1 = Pazartesi ... 7 = Pazar
  final int hour;
  final int minute;
  final String fromLabel;
  final String toLabel;

  const ScheduledRide({
    required this.id,
    required this.label,
    required this.daysOfWeek,
    required this.hour,
    required this.minute,
    required this.fromLabel,
    required this.toLabel,
  });

  String get timeLabel =>
      "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
}

/// Kullanıcının favori taksi sürücüsü ya da hizmeti.
class FavoriteTaxiDriver {
  final String id;
  final String name; // sürücü adı ya da firma/filo adı
  final String? phone;
  final String? vehiclePlate;
  final double rating; // 0-5
  final int timesUsed;
  final String? note;

  const FavoriteTaxiDriver({
    required this.id,
    required this.name,
    this.phone,
    this.vehiclePlate,
    this.rating = 0,
    this.timesUsed = 0,
    this.note,
  });
}
