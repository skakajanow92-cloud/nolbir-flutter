import 'base.dart';
import '../health.dart';

/// On dorduncu profil modülü: kullanıcının sağlık takibi — doktor/hastane
/// randevuları (geçmiş + yaklaşan), düzenli kullandığı ilaç/takviye/
/// vitaminler ve kendi kaydettiği ölçüm değerleri (kan şekeri, tansiyon,
/// vücut sıcaklığı vb.) son ölçüm tarihleriyle.
///
/// NOT: Randevu listeleri Travel/Accommodation modüllerindeki aynı
/// geçmiş/yaklaşan + 7 günlük alarm eşiğini izliyor. Bu kart yalnızca
/// kullanıcının KENDİ girdiği verileri saklar/gösterir; teşhis ya da
/// tıbbi yorum üretmez.
class HealthProfileCard extends FeedCard implements Collectible {
  final List<HealthAppointment> appointments;
  final List<Medication> medications;
  final List<VitalMeasurement> measurements;

  const HealthProfileCard({
    required String id,
    this.appointments = const [],
    this.medications = const [],
    this.measurements = const [],
  }) : super(id);

  List<HealthAppointment> get upcomingAppointments =>
      appointments.where((a) => a.isUpcoming).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<HealthAppointment> get pastAppointments =>
      appointments.where((a) => !a.isUpcoming).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<Medication> get ongoingMedications =>
      medications.where((m) => m.isOngoing).toList();

  /// Her ölçüm türü için YALNIZCA en son kayıt — kart "son ölçülen
  /// değerler"i gösterdiği için geçmiş kayıtlar burada elenir.
  List<VitalMeasurement> get latestMeasurements {
    final byType = <VitalType, VitalMeasurement>{};
    for (final m in measurements) {
      final existing = byType[m.type];
      if (existing == null || m.measuredAt.isAfter(existing.measuredAt)) {
        byType[m.type] = m;
      }
    }
    return byType.values.toList()
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
  }

  /// 7 günden az kalan en yakın randevu — varsa uyarı banner'ı için
  /// (bkz. TravelProfileCard/AccommodationProfileCard'daki aynı eşik).
  HealthAppointment? get nextAlertAppointment {
    final soon = upcomingAppointments.where(
      (a) => a.dateTime.difference(DateTime.now()).inDays <= 7,
    );
    return soon.isEmpty ? null : soon.first;
  }

  @override
  (String, String) toCollectionPreview() => ("Sağlık Profili", "");
}
