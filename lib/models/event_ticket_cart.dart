import 'cart.dart';
import 'event.dart';

/// `CartItem.metadata` üzerinden etkinlik bileti sepetine özel alanları
/// okuyan yardımcı extension.
///
/// KONVANSİYON: `CartItem.price` = tek biletin fiyatı, `quantity` = bilet
/// adedi. `EventCategory` event.dart'tan (Eğlence profil modülü) YENİDEN
/// KULLANILIYOR, tekrar tanımlanmadı.
///
/// ÖNEMLİ: Tüm getter'lar bilerek önekli/benzersiz adlandırıldı
/// (`eventName`, `seatRow`, `reservationHoldExpiresAt`...). feed_card.dart
/// birden fazla sepet modelini (otel, yemek, ilaç...) AYNI dosyada import
/// ettiği için, `CartItem` üzerindeki extension'larda aynı isimli bir
/// getter (örn. `holdExpiresAt`, `category`, `location`) derleme zamanında
/// "ambiguous extension member" hatasına yol açardı.
extension EventTicketCartItemExtras on CartItem {
  String get eventName => (metadata['eventName'] as String?) ?? title;
  EventCategory get eventCategory =>
      (metadata['eventCategory'] as EventCategory?) ?? EventCategory.concert;
  String get organizerName => (metadata['organizerName'] as String?) ?? "Bilinmeyen Organizatör";
  String get eventVenue => (metadata['eventVenue'] as String?) ?? "";
  String get eventCity => (metadata['eventCity'] as String?) ?? "";
  DateTime? get eventDateTime => metadata['eventDateTime'] as DateTime?;

  // Giriş bilgileri — hepsi opsiyonel; hiçbiri yoksa numarasız giriştir.
  String? get seatSection => metadata['seatSection'] as String?; // örn. "B Blok"
  int? get seatRow => metadata['seatRow'] as int?;
  String? get seatNumber => metadata['seatNumber'] as String?;
  String? get entranceGate => metadata['entranceGate'] as String?; // örn. "Kapı 3"

  /// Rezervasyonun ödeme yapılmazsa ne zamana kadar tutulduğu.
  DateTime? get reservationHoldExpiresAt =>
      metadata['reservationHoldExpiresAt'] as DateTime?;

  bool get isGeneralAdmission =>
      seatSection == null && seatRow == null && seatNumber == null;

  /// "B Blok · 9. sıra · Koltuk 14" gibi kısa gösterim; numarasız
  /// girişte "Numarasız giriş".
  String get seatSummary {
    if (isGeneralAdmission) return "Numarasız giriş";
    final parts = <String>[
      ?seatSection,
      if (seatRow != null) "$seatRow. sıra",
      if (seatNumber != null) "Koltuk $seatNumber",
    ];
    return parts.join(" · ");
  }
}

/// Bir önerinin gösterilme gerekçesi.
enum EventRecommendationReason {
  sameCategory,
  sameVenue,
  sameOrganizer,
  popularThisSeason,
}

extension EventRecommendationReasonLabel on EventRecommendationReason {
  String get label => switch (this) {
        EventRecommendationReason.sameCategory => "Benzer Etkinlik",
        EventRecommendationReason.sameVenue => "Aynı Mekanda",
        EventRecommendationReason.sameOrganizer => "Aynı Organizatör",
        EventRecommendationReason.popularThisSeason => "Sezonun Popüleri",
      };
}

/// Kullanıcıya önerilen tek bir etkinlik.
class RecommendedEventTicket {
  final String id;
  final String eventName;
  final EventCategory category;
  final String venue;
  final String city;
  final DateTime eventDateTime;
  final double fromPrice; // en ucuz bilet fiyatı
  final String currency;
  final bool isSellingFast;
  final EventRecommendationReason reason;

  const RecommendedEventTicket({
    required this.id,
    required this.eventName,
    required this.category,
    required this.venue,
    required this.city,
    required this.eventDateTime,
    required this.fromPrice,
    this.currency = "TRY",
    this.isSellingFast = false,
    required this.reason,
  });
}
