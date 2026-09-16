import '../../../models/feed_card/feed_card.dart';
import '../../../models/event.dart';

EventProfileCard buildEventMock() {
  return EventProfileCard(
    id: "event1",
    favorites: const [
      FavoriteEvent(
        id: "fe1",
        category: EventCategory.concert,
        name: "Duman",
        note: "Her turnesini kaçırmam",
      ),
      FavoriteEvent(
        id: "fe2",
        category: EventCategory.sports,
        name: "Fenerbahçe",
      ),
      FavoriteEvent(
        id: "fe3",
        category: EventCategory.theater,
        name: "Şehir Tiyatroları",
      ),
      FavoriteEvent(
        id: "fe4",
        category: EventCategory.festival,
        name: "Zeytinli Rock Festivali",
      ),
    ],
    tickets: [
      // Geçmiş biletler — sabit tarihler.
      EventTicket(
        id: "et1",
        eventName: "Duman - Yaz Turnesi",
        category: EventCategory.concert,
        venue: "Harbiye Açıkhava",
        city: "İstanbul",
        eventDateTime: DateTime(2025, 7, 19, 21, 0),
        purchaseDate: DateTime(2025, 4, 2),
        ticketCode: "BLT-2025-77120",
        seat: "B Blok · 9. sıra · 14",
        quantity: 2,
        price: 1800,
      ),
      EventTicket(
        id: "et2",
        eventName: "Hamlet",
        category: EventCategory.theater,
        venue: "Muhsin Ertuğrul Sahnesi",
        city: "İstanbul",
        eventDateTime: DateTime(2026, 2, 8, 20, 0),
        purchaseDate: DateTime(2026, 1, 20),
        ticketCode: "SHT-2026-00418",
        seat: "Orta · 6. sıra · 22",
        price: 450,
      ),
      // Gelecek biletler — bilerek DateTime.now() bazlı. Biri alarm
      // eşiğinin içinde (7 günden az), diğerleri aylar sonrası;
      // purchaseDate ise çok daha erken — "önceden alınmış bilet"
      // senaryosunu göstermek için.
      EventTicket(
        id: "et3",
        eventName: "Fenerbahçe - Galatasaray",
        category: EventCategory.sports,
        venue: "Ülker Stadyumu",
        city: "İstanbul",
        eventDateTime: DateTime.now().add(const Duration(days: 4, hours: 5)),
        purchaseDate: DateTime.now().subtract(const Duration(days: 40)),
        ticketCode: "FBG-2026-55031",
        seat: "Maraton Alt · 12. sıra · 8",
        price: 2400,
      ),
      EventTicket(
        id: "et4",
        eventName: "Zeytinli Rock Festivali",
        category: EventCategory.festival,
        venue: "Zeytinli Festival Alanı",
        city: "Balıkesir",
        eventDateTime: DateTime.now().add(const Duration(days: 95)),
        purchaseDate: DateTime.now().subtract(const Duration(days: 25)),
        ticketCode: "ZRF-2026-10244",
        quantity: 2,
        price: 5600,
      ),
      EventTicket(
        id: "et5",
        eventName: "Cem Yılmaz - Yeni Gösteri",
        category: EventCategory.standup,
        venue: "Volkswagen Arena",
        city: "İstanbul",
        eventDateTime: DateTime.now().add(const Duration(days: 62)),
        purchaseDate: DateTime.now().subtract(const Duration(days: 110)),
        ticketCode: "CYL-2026-88901",
        seat: "A Blok · 3. sıra · 11",
        price: 1950,
      ),
    ],
  );
}
