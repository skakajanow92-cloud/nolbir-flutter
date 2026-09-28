import 'cart.dart';

/// `CartItem.metadata` üzerinden otel rezervasyon sepetine özel alanları
/// okuyan yardımcı extension.
///
/// KONVANSİYON: `CartItem.price` = konaklamanın TOPLAM bedeli (tüm geceler,
/// tek oda), `CartItem.quantity` = oda sayısı. Gece sayısı ve gecelik fiyat
/// SAKLANMIYOR, giriş/çıkış tarihinden türetiliyor (bkz. market_cart.dart /
/// ticket_cart.dart'taki aynı "saklamak yerine türet" yaklaşımı).
extension HotelCartItemExtras on CartItem {
  String get hotelName => (metadata['hotelName'] as String?) ?? title;
  String get location => (metadata['location'] as String?) ?? "";
  String get roomType => (metadata['roomType'] as String?) ?? "";
  int get guestCount => (metadata['guestCount'] as int?) ?? 1;
  DateTime? get checkIn => metadata['checkIn'] as DateTime?;
  DateTime? get checkOut => metadata['checkOut'] as DateTime?;
  String? get boardType => metadata['boardType'] as String?; // örn. "Kahvaltı Dahil"
  bool get freeCancellation => (metadata['freeCancellation'] as bool?) ?? false;

  /// Rezervasyonun ödeme yapılmazsa ne zamana kadar tutulduğu. Sepetteki
  /// her kalem henüz ÖDENMEMİŞ olduğu için bu alan "ödeme için son an"ı
  /// temsil eder.
  DateTime? get holdExpiresAt => metadata['holdExpiresAt'] as DateTime?;

  int? get nights {
    final start = checkIn;
    final end = checkOut;
    if (start == null || end == null) return null;
    return end.difference(start).inDays;
  }

  double? get pricePerNight {
    final n = nights;
    if (n == null || n <= 0) return null;
    return price / n;
  }
}

/// Bir önerinin gösterilme gerekçesi.
enum HotelRecommendationReason { similarHotel, nearbyAlternative, sameChain }

extension HotelRecommendationReasonLabel on HotelRecommendationReason {
  String get label => switch (this) {
        HotelRecommendationReason.similarHotel => "Benzer Otel",
        HotelRecommendationReason.nearbyAlternative => "Yakın Alternatif",
        HotelRecommendationReason.sameChain => "Aynı Zincirden",
      };
}

/// Kullanıcıya önerilen tek bir otel.
class RecommendedHotel {
  final String id;
  final String hotelName;
  final String location;
  final double pricePerNight;
  final String currency;
  final double? rating; // 0-10 ya da 0-5 — kaynağa göre, sadece gösterim
  final HotelRecommendationReason reason;

  const RecommendedHotel({
    required this.id,
    required this.hotelName,
    required this.location,
    required this.pricePerNight,
    this.currency = "TRY",
    this.rating,
    required this.reason,
  });
}

/// Aynı otelin aynı tarihler için tek bir rezervasyon platformundaki
/// teklifi.
class PlatformOffer {
  final String id;
  final String platformName; // örn. "Booking.com", "Otel Web Sitesi"
  final double totalPrice; // konaklamanın toplam bedeli
  final String currency;
  final bool freeCancellation;
  final bool breakfastIncluded;
  final bool isAvailable;

  const PlatformOffer({
    required this.id,
    required this.platformName,
    required this.totalPrice,
    this.currency = "TRY",
    this.freeCancellation = false,
    this.breakfastIncluded = false,
    this.isAvailable = true,
  });
}

/// Aynı otel/oda/tarih için farklı platformlardaki tekliflerin grubu.
///
/// NOT: En ucuz teklif SAKLANMIYOR, `offers` listesinden CANLI
/// hesaplanıyor. Otelde en ucuz seçenek çoğu zaman iptal edilemeyen
/// olduğu için ayrıca `cheapestFreeCancellationOffer` de türetiliyor —
/// kullanıcı fiyat ile esneklik arasındaki farkı görebilsin diye.
class HotelComparisonGroup {
  final String id;
  final String hotelName;
  final String location;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final List<PlatformOffer> offers;

  const HotelComparisonGroup({
    required this.id,
    required this.hotelName,
    required this.location,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    this.offers = const [],
  });

  int get nights => checkOut.difference(checkIn).inDays;

  List<PlatformOffer> get sortedByPrice {
    final available = offers.where((o) => o.isAvailable).toList()
      ..sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
    final unavailable = offers.where((o) => !o.isAvailable).toList();
    return [...available, ...unavailable];
  }

  PlatformOffer? get cheapestOffer {
    final available = offers.where((o) => o.isAvailable);
    if (available.isEmpty) return null;
    return available.reduce((a, b) => a.totalPrice <= b.totalPrice ? a : b);
  }

  PlatformOffer? get cheapestFreeCancellationOffer {
    final flexible = offers.where((o) => o.isAvailable && o.freeCancellation);
    if (flexible.isEmpty) return null;
    return flexible.reduce((a, b) => a.totalPrice <= b.totalPrice ? a : b);
  }

  /// En pahalı MÜSAİT teklife göre en ucuzda ne kadar tasarruf edildiği (%).
  double? get savingsPercentVsHighest {
    final available = offers.where((o) => o.isAvailable).toList();
    if (available.length < 2) return null;
    final cheapest = cheapestOffer!;
    final highest = available.reduce((a, b) => a.totalPrice >= b.totalPrice ? a : b);
    if (highest.totalPrice == 0) return null;
    return ((highest.totalPrice - cheapest.totalPrice) / highest.totalPrice) * 100;
  }
}
