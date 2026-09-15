import '../../../models/feed_card/feed_card.dart';
import '../../../models/travel.dart';

/// Seyahat modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
TravelProfileCard buildTravelMock() {
  return TravelProfileCard(
    id: "travel1",
    tickets: [
      // Geçmiş biletler — sabit tarihler yeterli, "geçmiş" olduklarını
      // garanti etmek için bilinçli olarak uzak geçmişte seçildi.
      TravelTicket(
        id: "t1",
        company: "Turkish Airlines",
        transportType: TransportType.flight,
        ticketNumber: "TK-2025-88213",
        origin: "İstanbul",
        destination: "Londra",
        departureDateTime: DateTime(2025, 11, 2, 9, 30),
        arrivalDateTime: DateTime(2025, 11, 2, 12, 15),
        seatNumber: "14C",
        price: 4200,
      ),
      TravelTicket(
        id: "t2",
        company: "Metro Turizm",
        transportType: TransportType.bus,
        ticketNumber: "MT-2026-04471",
        origin: "Ankara",
        destination: "İzmir",
        departureDateTime: DateTime(2026, 2, 14, 22, 0),
        price: 650,
      ),
      TravelTicket(
        id: "t3",
        company: "TCDD Taşımacılık",
        transportType: TransportType.train,
        ticketNumber: "YHT-2026-11829",
        origin: "Ankara",
        destination: "İstanbul",
        departureDateTime: DateTime(2026, 5, 20, 7, 45),
        seatNumber: "5A",
        price: 380,
      ),
      // Yaklaşan biletler — bilerek "şu an"a göre DİNAMİK (DateTime.now()
      // tabanlı) tarihler kullanılıyor. Böylece bu mock veri hangi
      // tarihte test edilirse edilsin "yaklaşan yolculuk alarmı" anlamlı
      // kalır (sabit bir tarih yazsaydık, birkaç ay sonra o da geçmişe
      // düşerdi ve demo bozulurdu).
      TravelTicket(
        id: "t4",
        company: "Pegasus",
        transportType: TransportType.flight,
        ticketNumber: "PC-2026-90344",
        origin: "İstanbul",
        destination: "Antalya",
        departureDateTime: DateTime.now().add(
          const Duration(days: 3, hours: 6),
        ),
        seatNumber: "22F",
        price: 1450,
      ),
      TravelTicket(
        id: "t5",
        company: "Turkish Airlines",
        transportType: TransportType.flight,
        ticketNumber: "TK-2026-77410",
        origin: "İstanbul",
        destination: "Paris",
        departureDateTime: DateTime.now().add(const Duration(days: 45)),
        seatNumber: "9A",
        price: 5200,
      ),
    ],
  );
}
