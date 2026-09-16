/// Sağlık randevusunun türü.
enum AppointmentType { examination, checkup, labTest, imaging, vaccination }

extension AppointmentTypeLabel on AppointmentType {
  String get label => switch (this) {
        AppointmentType.examination => "Muayene",
        AppointmentType.checkup => "Kontrol",
        AppointmentType.labTest => "Tahlil",
        AppointmentType.imaging => "Görüntüleme",
        AppointmentType.vaccination => "Aşı",
      };
}

/// Bir doktor/hastane randevusu (geçmiş ya da yaklaşan).
///
/// Travel/Accommodation modüllerindeki aynı `isUpcoming` mantığını
/// izliyor — geçmiş ve yaklaşan randevular ayrı listelenebilsin diye.
class HealthAppointment {
  final String id;
  final String doctorName;
  final String specialty; // örn. "Kardiyoloji", "Dahiliye"
  final String facility; // hastane/klinik adı
  final AppointmentType type;
  final DateTime dateTime;
  final String? note;

  const HealthAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.facility,
    required this.type,
    required this.dateTime,
    this.note,
  });

  bool get isUpcoming => dateTime.isAfter(DateTime.now());
}

/// Düzenli kullanılan bir şeyin türü.
enum MedicationKind { medicine, supplement, vitamin }

extension MedicationKindLabel on MedicationKind {
  String get label => switch (this) {
        MedicationKind.medicine => "İlaç",
        MedicationKind.supplement => "Takviye",
        MedicationKind.vitamin => "Vitamin",
      };
}

/// Düzenli kullanılan bir ilaç/takviye/vitamin.
///
/// `endDate` BİLİNÇLİ olarak nullable — `null` "süresiz/devam eden
/// kullanım" demek (bkz. career.dart'taki `WorkExperience.isCurrent`
/// ile aynı desen).
class Medication {
  final String id;
  final String name;
  final MedicationKind kind;
  final String dosage; // örn. "500 mg", "1 ölçek"
  final String frequency; // örn. "Günde 2 kez, yemekten sonra"
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;

  const Medication({
    required this.id,
    required this.name,
    required this.kind,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
  });

  bool get isOngoing => endDate == null || endDate!.isAfter(DateTime.now());
}

/// Takip edilen ölçüm türü.
enum VitalType { bloodSugar, bloodPressure, bodyTemperature, pulse, weight, oxygenSaturation }

extension VitalTypeInfo on VitalType {
  String get label => switch (this) {
        VitalType.bloodSugar => "Kan Şekeri",
        VitalType.bloodPressure => "Tansiyon",
        VitalType.bodyTemperature => "Vücut Sıcaklığı",
        VitalType.pulse => "Nabız",
        VitalType.weight => "Kilo",
        VitalType.oxygenSaturation => "Oksijen Satürasyonu",
      };

  String get unit => switch (this) {
        VitalType.bloodSugar => "mg/dL",
        VitalType.bloodPressure => "mmHg",
        VitalType.bodyTemperature => "°C",
        VitalType.pulse => "bpm",
        VitalType.weight => "kg",
        VitalType.oxygenSaturation => "%",
      };

  /// Tansiyon iki değerle ifade edilir (büyük/küçük) — bu yüzden
  /// `VitalMeasurement.secondaryValue` sadece bu tür için anlamlı.
  bool get hasSecondaryValue => this == VitalType.bloodPressure;
}

/// Tek bir ölçüm kaydı.
///
/// NOT: Bu model yalnızca kullanıcının KENDİ girdiği/kaydettiği değerleri
/// saklar ve gösterir; herhangi bir teşhis ya da tıbbi yorum üretmez.
class VitalMeasurement {
  final String id;
  final VitalType type;
  final double value;
  final double? secondaryValue; // tansiyonun küçük değeri
  final DateTime measuredAt;
  final String? note;

  const VitalMeasurement({
    required this.id,
    required this.type,
    required this.value,
    this.secondaryValue,
    required this.measuredAt,
    this.note,
  });

  /// Görüntüleme için hazır metin — "120/80", "98.4" gibi.
  String get displayValue {
    String fmt(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    if (type.hasSecondaryValue && secondaryValue != null) {
      return "${fmt(value)}/${fmt(secondaryValue!)}";
    }
    return fmt(value);
  }

  /// Ölçümün üzerinden geçen gün sayısı.
  int get daysAgo => DateTime.now().difference(measuredAt).inDays;
}
