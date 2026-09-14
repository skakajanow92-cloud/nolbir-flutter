import '../travel.dart';
import 'base.dart';

/// Dördüncü profil modülü: kullanıcının farklı şirketlerden aldığı araç
/// biletleri (uçak/otobüs/tren/feribot) — hem geçmiş hem yaklaşan.
/// Konaklama bilerek kapsam dışı; ayrı bir modül olarak eklenecek.
class TravelProfileCard extends FeedCard implements Collectible {
  final List<TravelTicket> tickets;

  const TravelProfileCard({required String id, this.tickets = const []})
    : super(id);

  List<TravelTicket> get upcoming =>
      tickets.where((t) => t.isUpcoming).toList()
        ..sort((a, b) => a.departureDateTime.compareTo(b.departureDateTime));

  List<TravelTicket> get past =>
      tickets.where((t) => !t.isUpcoming).toList()
        ..sort((a, b) => b.departureDateTime.compareTo(a.departureDateTime));

  /// Kalkışa 7 günden az kalan en yakın yolculuk — varsa uyarı banner'ı
  /// için kullanılır.
  TravelTicket? get nextAlertTicket {
    final soon = upcoming.where(
      (t) => t.departureDateTime.difference(DateTime.now()).inDays <= 7,
    );
    return soon.isEmpty ? null : soon.first;
  }

  @override
  (String, String) toCollectionPreview() => ("Seyahat Profili", "");
}
