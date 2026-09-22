import '../cart.dart';
import '../feed_card/base.dart';
import '../ticket_cart.dart';

/// Sepet Kartları ailesinin üçüncü üyesi: Bilet Sepeti. Farklı
/// firmalardan (havayolu/otobüs/vapur/tren) alınmış, henüz satın
/// alınmamış biletler — koltuk durumu ve aynı güzergâh için alternatif
/// firma/saat seçenekleriyle.
///
/// NOT: `cart` alanı `Cart`/`CartItem`/`CartType` modelini (`CartType.
/// travelTicket`) kullanıyor; bilete özel alanlar (firma, güzergah,
/// koltuk) `CartItem.metadata` üzerinden `TicketCartItemExtras`
/// extension'ıyla okunuyor (bkz. ticket_cart.dart). `TransportType`
/// travel.dart'tan yeniden kullanılıyor.
class TicketCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<AlternativeRouteGroup> alternatives;

  const TicketCartCard({
    required String id,
    required this.cart,
    this.alternatives = const [],
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => ("Bilet Sepeti", "");
}
