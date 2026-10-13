import '../feed_card/base.dart';
import '../event_ticket_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin sekizinci üyesi: Etkinlik Bileti Sepeti.
/// Farklı organizatörlerin farklı etkinlikleri için önceden alınmış
/// rezervasyon biletleri; blok/sıra/koltuk/giriş kapısı bilgileriyle.
/// Seyahat Bileti Sepeti'nden (ulaşım) ayrı bir kart.
///
/// NOT: `cart` alanı `CartType.eventTicket` kullanıyor; etkinliğe özel
/// alanlar `CartItem.metadata` üzerinden `EventTicketCartItemExtras`
/// ile okunuyor (bkz. event_ticket_cart.dart).
class EventTicketCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<RecommendedEventTicket> recommendations;

  const EventTicketCartCard({
    required String id,
    required this.cart,
    this.recommendations = const [],
  }) : super(id);

  /// Kalemler etkinlik tarihine göre, en yakın önce. Tarihi olmayanlar sona.
  List<CartItem> get itemsByDate => cart.items.toList()
    ..sort((a, b) {
      final da = a.eventDateTime;
      final db = b.eventDateTime;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

  /// Rezervasyon tutma süresi 48 saat içinde dolacak (ya da dolmuş)
  /// kalemler, en yakın önce — alarm banner'ı için.
  List<CartItem> get itemsHoldExpiringSoon {
    final now = DateTime.now();
    return cart.items.where((i) {
      final hold = i.reservationHoldExpiresAt;
      return hold != null && hold.difference(now).inHours <= 48;
    }).toList()..sort(
      (a, b) =>
          a.reservationHoldExpiresAt!.compareTo(b.reservationHoldExpiresAt!),
    );
  }

  /// Aynı gün, 3 saat içinde birbirine denk gelen etkinlik çiftleri.
  List<(CartItem, CartItem)> get timeConflicts {
    final sorted = itemsByDate.where((i) => i.eventDateTime != null).toList();
    final conflicts = <(CartItem, CartItem)>[];
    for (var i = 0; i < sorted.length; i++) {
      for (var j = i + 1; j < sorted.length; j++) {
        final a = sorted[i].eventDateTime!;
        final b = sorted[j].eventDateTime!;
        if (b.difference(a).inHours >= 3)
          break; // sıralı olduğu için sonrası da uzak
        final sameDay =
            a.year == b.year && a.month == b.month && a.day == b.day;
        if (sameDay) conflicts.add((sorted[i], sorted[j]));
      }
    }
    return conflicts;
  }

  @override
  (String, String) toCollectionPreview() => ("Etkinlik Bileti Sepeti", "");
}
