import 'cart.dart';
import 'travel.dart';

/// Koltuk sınıfı.
enum SeatClass { economy, business, premium }

extension SeatClassLabel on SeatClass {
  String get label => switch (this) {
        SeatClass.economy => "Ekonomi",
        SeatClass.business => "Business",
        SeatClass.premium => "Premium",
      };
}

/// Bir bilet için seçilebilecek tek bir koltuk seçeneği.
class SeatOption {
  final String seatNumber; // örn. "14A"
  final SeatClass seatClass;
  final bool isWindowSeat;
  final double extraPrice; // 0 ise ek ücretsiz
  final bool isAvailable;

  const SeatOption({
    required this.seatNumber,
    this.seatClass = SeatClass.economy,
    this.isWindowSeat = false,
    this.extraPrice = 0,
    this.isAvailable = true,
  });
}

/// `CartItem.metadata` üzerinden bilet sepetine özel alanları okuyan
/// yardımcı extension.
///
/// BİLİNÇLİ TASARIM KARARI: market_cart.dart/second_hand_cart.dart ile
/// AYNI yaklaşım — domain'e özel alanlar `metadata` üzerinden okunuyor.
/// `TransportType` ise travel.dart'tan YENİDEN KULLANILIYOR, tekrar
/// tanımlanmadı (bkz. travel.dart'taki aynı enum, satın alınmış biletler
/// için kullanılıyordu; burada henüz satın ALINMAMIŞ, sepetteki biletler
/// için aynı sınıflandırma geçerli).
extension TicketCartItemExtras on CartItem {
  TransportType get transportType =>
      (metadata['transportType'] as TransportType?) ?? TransportType.bus;
  String get company => (metadata['company'] as String?) ?? "Bilinmeyen Firma";
  String get origin => (metadata['origin'] as String?) ?? "";
  String get destination => (metadata['destination'] as String?) ?? "";
  DateTime? get departureDateTime => metadata['departureDateTime'] as DateTime?;
  String? get selectedSeat => metadata['selectedSeat'] as String?;
  List<SeatOption> get availableSeats =>
      (metadata['availableSeats'] as List<SeatOption>?) ?? const [];
}

/// Aynı güzergâh için tek bir alternatif bilet seçeneği (farklı firma
/// ve/ya farklı saat).
class AlternativeTicketOption {
  final String id;
  final String company;
  final TransportType transportType;
  final DateTime departureDateTime;
  final double price;
  final String currency;
  final int? durationMinutes;
  final int? seatsAvailable;

  const AlternativeTicketOption({
    required this.id,
    required this.company,
    required this.transportType,
    required this.departureDateTime,
    required this.price,
    this.currency = "TRY",
    this.durationMinutes,
    this.seatsAvailable,
  });
}

/// Aynı güzergâh (kalkış → varış) için farklı firma/saatlerin toplandığı
/// alternatif seçenek grubu.
///
/// NOT: market_cart.dart/second_hand_cart.dart'taki aynı "saklamak
/// yerine türet" yaklaşımı — en ucuz ve en erken seçenek SAKLANMIYOR,
/// `options` listesinden CANLI hesaplanıyor.
class AlternativeRouteGroup {
  final String id;
  final String origin;
  final String destination;
  final List<AlternativeTicketOption> options;

  const AlternativeRouteGroup({
    required this.id,
    required this.origin,
    required this.destination,
    this.options = const [],
  });

  List<AlternativeTicketOption> get sortedByPrice =>
      options.toList()..sort((a, b) => a.price.compareTo(b.price));

  List<AlternativeTicketOption> get sortedByDeparture =>
      options.toList()..sort((a, b) => a.departureDateTime.compareTo(b.departureDateTime));

  AlternativeTicketOption? get cheapestOption {
    if (options.isEmpty) return null;
    return options.reduce((a, b) => a.price <= b.price ? a : b);
  }

  AlternativeTicketOption? get earliestOption {
    if (options.isEmpty) return null;
    return options.reduce(
        (a, b) => a.departureDateTime.isBefore(b.departureDateTime) ? a : b);
  }
}
