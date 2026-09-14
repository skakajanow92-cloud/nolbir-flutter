import '../accommodation.dart';
import 'base.dart';

/// Beşinci profil modülü: kullanıcının farklı otellerden aldığı konaklama
/// rezervasyonları — hem geçmiş hem yaklaşan. Seyahat modülüyle aynı
/// geçmiş/yaklaşan + alarm mantığını izliyor.
class AccommodationProfileCard extends FeedCard implements Collectible {
  final List<AccommodationReservation> reservations;

  const AccommodationProfileCard({
    required String id,
    this.reservations = const [],
  }) : super(id);

  List<AccommodationReservation> get upcoming =>
      reservations.where((r) => r.isUpcoming).toList()
        ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

  List<AccommodationReservation> get past =>
      reservations.where((r) => !r.isUpcoming).toList()
        ..sort((a, b) => b.checkIn.compareTo(a.checkIn));

  /// Check-in'e 7 günden az kalan en yakın rezervasyon — varsa uyarı
  /// banner'ı için kullanılır (bkz. TravelProfileCard'daki aynı eşik).
  AccommodationReservation? get nextAlertReservation {
    final soon = upcoming.where(
      (r) => r.checkIn.difference(DateTime.now()).inDays <= 7,
    );
    return soon.isEmpty ? null : soon.first;
  }

  @override
  (String, String) toCollectionPreview() => ("Konaklama Profili", "");
}
