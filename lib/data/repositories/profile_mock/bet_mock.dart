import '../../../models/feed_card/feed_card.dart';
import '../../../models/bet.dart';

BetProfileCard buildBetMock() {
  return BetProfileCard(
    id: "bet1",
    totalBudget: 5000,
    coupons: [
      // Geçmiş kuponlar — sabit tarihler, sonuçlanmış.
      BetCoupon(
        id: "bc1",
        bookmaker: "Nesine",
        couponCode: "NS-88213",
        placedDate: DateTime(2026, 2, 1),
        eventDateTime: DateTime(2026, 2, 2, 20, 0),
        stake: 200,
        totalOdds: 2.35,
        status: BetStatus.won,
        selections: const [
          BetSelection(
            id: "sel1",
            eventName: "Beşiktaş - Trabzonspor",
            market: "Maç Sonucu",
            pick: "MS1",
            odds: 2.35,
          ),
        ],
      ),
      BetCoupon(
        id: "bc2",
        bookmaker: "Bilyoner",
        couponCode: "BY-44192",
        placedDate: DateTime(2026, 1, 20),
        eventDateTime: DateTime(2026, 1, 21, 21, 45),
        stake: 150,
        totalOdds: 5.8,
        status: BetStatus.lost,
        selections: const [
          BetSelection(
            id: "sel2",
            eventName: "Galatasaray - Fenerbahçe",
            market: "Maç Sonucu",
            pick: "MS2",
            odds: 3.1,
          ),
          BetSelection(
            id: "sel3",
            eventName: "Real Madrid - Barcelona",
            market: "Alt/Üst 2.5",
            pick: "Üst",
            odds: 1.87,
          ),
        ],
      ),
      // Gelecekte oynanacak kuponlar — bilerek DateTime.now() bazlı.
      BetCoupon(
        id: "bc3",
        bookmaker: "Nesine",
        couponCode: "NS-90344",
        placedDate: DateTime.now().subtract(const Duration(hours: 3)),
        eventDateTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
        stake: 100,
        totalOdds: 3.4,
        selections: const [
          BetSelection(
            id: "sel4",
            eventName: "Fenerbahçe - Antalyaspor",
            market: "Maç Sonucu",
            pick: "MS1",
            odds: 1.65,
          ),
          BetSelection(
            id: "sel5",
            eventName: "Karşıyaka - Bursaspor",
            market: "Çifte Şans",
            pick: "1X",
            odds: 2.06,
          ),
        ],
      ),
    ],
  );
}
