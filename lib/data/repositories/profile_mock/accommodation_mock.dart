import '../../../models/feed_card/feed_card.dart';
import '../../../models/accommodation.dart';

/// Konaklama modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
AccommodationProfileCard buildAccommodationMock() {
  return AccommodationProfileCard(
    id: "accommodation1",
    reservations: [
      // Geçmiş rezervasyonlar — sabit tarihler.
      AccommodationReservation(
        id: "res1",
        hotelName: "Hilton Bodrum",
        location: "Bodrum, Türkiye",
        roomType: "Standart Oda",
        guestCount: 2,
        checkIn: DateTime(2025, 8, 10),
        checkOut: DateTime(2025, 8, 14),
        confirmationNumber: "HLT-2025-55210",
        price: 18000,
      ),
      AccommodationReservation(
        id: "res2",
        hotelName: "Ibis Ankara",
        location: "Ankara, Türkiye",
        roomType: "Standart Oda",
        guestCount: 1,
        checkIn: DateTime(2026, 3, 5),
        checkOut: DateTime(2026, 3, 7),
        confirmationNumber: "IBS-2026-11987",
        price: 3200,
      ),
      // Yaklaşan rezervasyonlar — travel modülündeki gibi bilerek
      // DateTime.now() bazlı, sabit tarih değil.
      AccommodationReservation(
        id: "res3",
        hotelName: "Rixos Premium Belek",
        location: "Antalya, Türkiye",
        roomType: "Suit",
        guestCount: 2,
        checkIn: DateTime.now().add(const Duration(days: 5)),
        checkOut: DateTime.now().add(const Duration(days: 8)),
        confirmationNumber: "RXS-2026-90021",
        price: 42000,
      ),
      AccommodationReservation(
        id: "res4",
        hotelName: "Conrad Paris",
        location: "Paris, Fransa",
        roomType: "Executive Oda",
        guestCount: 1,
        checkIn: DateTime.now().add(const Duration(days: 50)),
        checkOut: DateTime.now().add(const Duration(days: 53)),
        confirmationNumber: "CND-2026-33456",
        price: 65000,
      ),
    ],
  );
}
