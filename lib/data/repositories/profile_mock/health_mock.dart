import '../../../models/feed_card/feed_card.dart';
import '../../../models/health.dart';

HealthProfileCard buildHealthMock() {
  return HealthProfileCard(
    id: "health1",
    appointments: [
      // Geçmiş randevular — sabit tarihler.
      HealthAppointment(
        id: "ap1",
        doctorName: "Dr. Kemal Aydın",
        specialty: "Dahiliye",
        facility: "Acıbadem Hastanesi",
        type: AppointmentType.examination,
        dateTime: DateTime(2026, 4, 18, 10, 30),
      ),
      HealthAppointment(
        id: "ap2",
        doctorName: "Dr. Selin Kaya",
        specialty: "Göz Hastalıkları",
        facility: "Memorial Şişli",
        type: AppointmentType.checkup,
        dateTime: DateTime(2026, 1, 9, 14, 0),
      ),
      // Yaklaşan randevular — travel/accommodation modüllerindeki gibi
      // bilerek DateTime.now() bazlı, sabit tarih değil.
      HealthAppointment(
        id: "ap3",
        doctorName: "Dr. Kemal Aydın",
        specialty: "Dahiliye",
        facility: "Acıbadem Hastanesi",
        type: AppointmentType.labTest,
        dateTime: DateTime.now().add(const Duration(days: 4, hours: 3)),
        note: "Aç karnına gidilecek",
      ),
      HealthAppointment(
        id: "ap4",
        doctorName: "Dr. Merve Şahin",
        specialty: "Diş Hekimliği",
        facility: "Dentapark Klinik",
        type: AppointmentType.checkup,
        dateTime: DateTime.now().add(const Duration(days: 28)),
      ),
    ],
    medications: [
      Medication(
        id: "med1",
        name: "D Vitamini",
        kind: MedicationKind.vitamin,
        dosage: "1000 IU",
        frequency: "Günde 1 kez, sabah",
        startDate: DateTime(2026, 1, 15),
        prescribedBy: "Dr. Kemal Aydın",
      ),
      Medication(
        id: "med2",
        name: "Omega-3",
        kind: MedicationKind.supplement,
        dosage: "1 kapsül",
        frequency: "Günde 1 kez, akşam yemeğiyle",
        startDate: DateTime(2025, 11, 1),
      ),
      Medication(
        id: "med3",
        name: "Magnezyum",
        kind: MedicationKind.supplement,
        dosage: "375 mg",
        frequency: "Akşam, yatmadan önce",
        startDate: DateTime(2026, 5, 20),
      ),
    ],
    measurements: [
      VitalMeasurement(
        id: "vm1",
        type: VitalType.bloodPressure,
        value: 118,
        secondaryValue: 76,
        measuredAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VitalMeasurement(
        id: "vm2",
        type: VitalType.bloodSugar,
        value: 94,
        measuredAt: DateTime.now().subtract(const Duration(days: 5)),
        note: "Açlık",
      ),
      VitalMeasurement(
        id: "vm3",
        type: VitalType.bodyTemperature,
        value: 36.6,
        measuredAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      VitalMeasurement(
        id: "vm4",
        type: VitalType.pulse,
        value: 72,
        measuredAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      // Aynı türden daha eski bir kayıt — latestMeasurements'ın yalnızca
      // en günceli göstermesini doğrulamak için bilinçli olarak eklendi.
      VitalMeasurement(
        id: "vm5",
        type: VitalType.bloodPressure,
        value: 126,
        secondaryValue: 82,
        measuredAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ],
  );
}
