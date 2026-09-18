enum EducationProgramType { course, certificate, degree, workshop, languageSchool }

extension EducationProgramTypeLabel on EducationProgramType {
  String get label => switch (this) {
        EducationProgramType.course => "Kurs",
        EducationProgramType.certificate => "Sertifika Programı",
        EducationProgramType.degree => "Derece Programı",
        EducationProgramType.workshop => "Atölye",
        EducationProgramType.languageSchool => "Dil Kursu",
      };
}

/// Bir eğitim kuruluşundan alınan TEK bir program/kurs.
///
/// TASARIM NOTU: `endDate == null` "hâlâ devam ediyor" anlamına gelir —
/// CareerProfileCard'daki WorkExperience'ın aynı deseni. `isRecurring` +
/// `nextRenewalDate` ise StreamingPackage'daki periyodik yenileme
/// mantığının aynısı — bir dil kursu paketi gibi tekrar eden bir eğitim
/// için kullanılır.
class EducationProgram {
  final String id;
  final String name;
  final EducationProgramType type;
  final DateTime startDate;
  final DateTime? endDate; // null = hâlâ devam ediyor
  final double progressPercent; // 0-100
  final bool isRecurring;
  final DateTime? nextRenewalDate; // isRecurring ise bir sonraki dönem
  final double price;
  final String currency;
  final bool hasCertificate;

  const EducationProgram({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    this.endDate,
    this.progressPercent = 0,
    this.isRecurring = false,
    this.nextRenewalDate,
    this.price = 0,
    this.currency = "TRY",
    this.hasCertificate = false,
  });

  bool get isOngoing => endDate == null;

  int? get daysUntilRenewal =>
      nextRenewalDate?.difference(DateTime.now()).inDays;
}

/// Kullanıcının etkileşimde olduğu bir eğitim kuruluşu (üniversite,
/// online platform, dil okulu, atölye merkezi vb.) ve ondan aldığı
/// programlar.
class EducationInstitution {
  final String id;
  final String name;
  final List<EducationProgram> programs;
  /// Kurumla ETKİLEŞİM MEKANİZMASI — örn. "Öğrenci Bilgi Sistemi",
  /// "Mobil Uygulama", "E-posta". Opsiyonel: doldurulmazsa görünümde bu
  /// satır hiç gösterilmez (bkz. DonationProfileCard'daki politicalParty
  /// ile aynı desen).
  final String? interactionChannel;

  const EducationInstitution({
    required this.id,
    required this.name,
    this.programs = const [],
    this.interactionChannel,
  });

  List<EducationProgram> get ongoingPrograms =>
      programs.where((p) => p.isOngoing).toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));

  List<EducationProgram> get completedPrograms =>
      programs.where((p) => !p.isOngoing).toList()
        ..sort((a, b) => b.endDate!.compareTo(a.endDate!));
}
