/// Farklı otellerden/platformlardan alınmış tek bir konaklama rezervasyonu
/// (geçmiş ya da yaklaşan).
class AccommodationReservation {
  final String id;
  final String hotelName;
  final String location; // şehir, ülke
  final String roomType;
  final int guestCount;
  final DateTime checkIn;
  final DateTime checkOut;
  final String confirmationNumber;
  final double price;
  final String currency;

  const AccommodationReservation({
    required this.id,
    required this.hotelName,
    required this.location,
    required this.roomType,
    required this.guestCount,
    required this.checkIn,
    required this.checkOut,
    required this.confirmationNumber,
    required this.price,
    this.currency = "TRY",
  });

  bool get isUpcoming => checkIn.isAfter(DateTime.now());
  int get nights => checkOut.difference(checkIn).inDays;
}
