/// Ulaşım aracı türü.
enum TransportType { flight, bus, train, ferry }

extension TransportTypeLabel on TransportType {
  String get label => switch (this) {
        TransportType.flight => "Uçak",
        TransportType.bus => "Otobüs",
        TransportType.train => "Tren",
        TransportType.ferry => "Feribot",
      };
}

/// Farklı şirketlerden alınmış tek bir yolculuk bileti (geçmiş ya da
/// yaklaşan). Konaklama bu modelin KAPSAMI DIŞINDA — ayrı bir profil
/// modülü olacak (bkz. AccommodationProfileCard, ileride eklenecek).
class TravelTicket {
  final String id;
  final String company;
  final TransportType transportType;
  final String ticketNumber;
  final String origin;
  final String destination;
  final DateTime departureDateTime;
  final DateTime? arrivalDateTime;
  final String? seatNumber;
  final double price;
  final String currency;

  const TravelTicket({
    required this.id,
    required this.company,
    required this.transportType,
    required this.ticketNumber,
    required this.origin,
    required this.destination,
    required this.departureDateTime,
    this.arrivalDateTime,
    this.seatNumber,
    required this.price,
    this.currency = "TRY",
  });

  bool get isUpcoming => departureDateTime.isAfter(DateTime.now());
}
