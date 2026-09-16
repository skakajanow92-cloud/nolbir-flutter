import 'base.dart';
import '../event.dart';

/// On besinci profil modülü: kullanıcının eğlence hayatı — favori
/// etkinlikleri (sanatçı/takım/tür) ve satın aldığı biletler; hem geçmiş
/// hem de tarihi henüz gelmemiş, önceden alınmış gelecek biletler.
///
/// Travel/Accommodation/Health modüllerindeki aynı geçmiş/yaklaşan +
/// 7 günlük alarm eşiğini izliyor. Farkı: bilette satın alma tarihi de
/// tutuluyor, böylece "ne kadar önceden alındığı" gösterilebiliyor
/// (bkz. event.dart'taki purchaseDate/eventDateTime ayrımı).
class EventProfileCard extends FeedCard implements Collectible {
  final List<FavoriteEvent> favorites;
  final List<EventTicket> tickets;

  const EventProfileCard({
    required String id,
    this.favorites = const [],
    this.tickets = const [],
  }) : super(id);

  List<EventTicket> get upcoming => tickets.where((t) => t.isUpcoming).toList()
    ..sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));

  List<EventTicket> get past => tickets.where((t) => !t.isUpcoming).toList()
    ..sort((a, b) => b.eventDateTime.compareTo(a.eventDateTime));

  /// Etkinliğine 7 günden az kalan en yakın bilet — varsa uyarı banner'ı
  /// için (bkz. Travel/Accommodation/Health modüllerindeki aynı eşik).
  EventTicket? get nextAlertTicket {
    final soon = upcoming.where(
      (t) => t.eventDateTime.difference(DateTime.now()).inDays <= 7,
    );
    return soon.isEmpty ? null : soon.first;
  }

  @override
  (String, String) toCollectionPreview() => ("Eğlence Profili", "");
}