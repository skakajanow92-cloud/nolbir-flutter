import '../../../models/cart_card/cart_card.dart';
import '../../../models/event_ticket_cart.dart';
import '../../../models/event.dart';
import '../../../models/cart.dart';

EventTicketCartCard buildEventTicketCartMock() {
  // Tarihler bilerek DateTime.now() bazlı — diğer gelecek-olay mock'larıyla
  // aynı yaklaşım. Konser ve açık hava sineması aynı akşam 2 saat arayla
  // seçildi: çakışma uyarı banner'ını demoda göstermek için.
  final concertTime = DateTime.now().add(const Duration(days: 6, hours: 3));

  return EventTicketCartCard(
    id: "eventticketcart1",
    cart: Cart(
      cartType: CartType.eventTicket,
      items: [
        CartItem(
          id: "etci1",
          cartType: CartType.eventTicket,
          title: "Duman - Yaz Turnesi",
          price: 1800,
          quantity: 2,
          metadata: {
            "eventName": "Duman - Yaz Turnesi",
            "eventCategory": EventCategory.concert,
            "organizerName": "Pozitif Live",
            "eventVenue": "Harbiye Açıkhava",
            "eventCity": "İstanbul",
            "eventDateTime": concertTime,
            "seatSection": "B Blok",
            "seatRow": 9,
            "seatNumber": "14-15",
            "entranceGate": "Kapı 3",
            // Alarm banner'ını göstermek için kısa tutma süresi.
            "reservationHoldExpiresAt": DateTime.now().add(
              const Duration(hours: 30),
            ),
          },
        ),
        CartItem(
          id: "etci2",
          cartType: CartType.eventTicket,
          title: "Açık Hava Sineması: Cinema Paradiso",
          price: 220,
          metadata: {
            "eventName": "Açık Hava Sineması: Cinema Paradiso",
            "eventCategory": EventCategory.cinema,
            "organizerName": "Kadıköy Kültür",
            "eventVenue": "Yoğurtçu Parkı",
            "eventCity": "İstanbul",
            "eventDateTime": concertTime.add(const Duration(hours: 2)),
            // Numarasız giriş: blok/sıra/koltuk yok.
            "entranceGate": "Giriş A",
          },
        ),
        CartItem(
          id: "etci3",
          cartType: CartType.eventTicket,
          title: "Hamlet",
          price: 450,
          metadata: {
            "eventName": "Hamlet",
            "eventCategory": EventCategory.theater,
            "organizerName": "Şehir Tiyatroları",
            "eventVenue": "Muhsin Ertuğrul Sahnesi",
            "eventCity": "İstanbul",
            "eventDateTime": DateTime.now().add(
              const Duration(days: 21, hours: 1),
            ),
            "seatSection": "Orta",
            "seatRow": 6,
            "seatNumber": "22",
            "entranceGate": "Ana Giriş",
            "reservationHoldExpiresAt": DateTime.now().add(
              const Duration(days: 4),
            ),
          },
        ),
        CartItem(
          id: "etci4",
          cartType: CartType.eventTicket,
          title: "Zeytinli Rock Festivali",
          price: 2800,
          quantity: 2,
          metadata: {
            "eventName": "Zeytinli Rock Festivali",
            "eventCategory": EventCategory.festival,
            "organizerName": "Zeytinli Prodüksiyon",
            "eventVenue": "Zeytinli Festival Alanı",
            "eventCity": "Balıkesir",
            "eventDateTime": DateTime.now().add(const Duration(days: 95)),
            "entranceGate": "Giriş B",
          },
        ),
      ],
    ),
    recommendations: [
      RecommendedEventTicket(
        id: "ret1",
        eventName: "Mor ve Ötesi",
        category: EventCategory.concert,
        venue: "Harbiye Açıkhava",
        city: "İstanbul",
        eventDateTime: DateTime.now().add(const Duration(days: 14, hours: 3)),
        fromPrice: 1500,
        isSellingFast: true,
        reason: EventRecommendationReason.sameVenue,
      ),
      RecommendedEventTicket(
        id: "ret2",
        eventName: "Cem Yılmaz - Yeni Gösteri",
        category: EventCategory.standup,
        venue: "Volkswagen Arena",
        city: "İstanbul",
        eventDateTime: DateTime.now().add(const Duration(days: 62)),
        fromPrice: 1950,
        reason: EventRecommendationReason.popularThisSeason,
      ),
      RecommendedEventTicket(
        id: "ret3",
        eventName: "Romeo ve Juliet",
        category: EventCategory.theater,
        venue: "Muhsin Ertuğrul Sahnesi",
        city: "İstanbul",
        eventDateTime: DateTime.now().add(const Duration(days: 35)),
        fromPrice: 400,
        reason: EventRecommendationReason.sameOrganizer,
      ),
      RecommendedEventTicket(
        id: "ret4",
        eventName: "Caz Festivali Açılış Gecesi",
        category: EventCategory.festival,
        venue: "Cemal Reşit Rey",
        city: "İstanbul",
        eventDateTime: DateTime.now().add(const Duration(days: 48)),
        fromPrice: 900,
        isSellingFast: true,
        reason: EventRecommendationReason.popularThisSeason,
      ),
    ],
  );
}
