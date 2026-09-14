/// Bir iş deneyiminin çalışma türü.
enum EmploymentType { fullTime, partTime, freelance, internship, contract }

extension EmploymentTypeLabel on EmploymentType {
  String get label => switch (this) {
        EmploymentType.fullTime => "Tam Zamanlı",
        EmploymentType.partTime => "Yarı Zamanlı",
        EmploymentType.freelance => "Serbest Çalışma",
        EmploymentType.internship => "Staj",
        EmploymentType.contract => "Sözleşmeli",
      };
}

/// Kullanıcının bir şirketteki tek bir çalışma dönemi.
///
/// `endDate` BİLİNÇLİ olarak nullable — `null` "hâlâ orada çalışıyor"
/// anlamına gelir (bkz. `isCurrent`). Bu, Travel/Accommodation
/// modüllerindeki "yaklaşan/geçmiş" ayrımına benzer, ama burada tek bir
/// tarih alanının kendisi durumu taşıyor.
class WorkExperience {
  final String id;
  final String company;
  final String title;
  final EmploymentType employmentType;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  const WorkExperience({
    required this.id,
    required this.company,
    required this.title,
    required this.employmentType,
    required this.location,
    required this.startDate,
    this.endDate,
    this.description,
  });

  bool get isCurrent => endDate == null;

  /// Yaklaşık süre (ay) — basit takvim farkı, gün hassasiyeti önemli değil.
  int get durationInMonths {
    final end = endDate ?? DateTime.now();
    return (end.year - startDate.year) * 12 + (end.month - startDate.month);
  }
}

/// Kullanıcının bir eğitim dönemi (okul/derece).
class EducationEntry {
  final String id;
  final String school;
  final String degree; // örn. "Lisans", "Yüksek Lisans"
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final String? note;

  const EducationEntry({
    required this.id,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.note,
  });

  bool get isOngoing => endDate == null;
}

/// Yetenek seviyesi.
enum SkillLevel { beginner, intermediate, advanced, expert }

extension SkillLevelLabel on SkillLevel {
  String get label => switch (this) {
        SkillLevel.beginner => "Başlangıç",
        SkillLevel.intermediate => "Orta",
        SkillLevel.advanced => "İleri",
        SkillLevel.expert => "Uzman",
      };

  double get progress => switch (this) {
        SkillLevel.beginner => 0.25,
        SkillLevel.intermediate => 0.5,
        SkillLevel.advanced => 0.75,
        SkillLevel.expert => 1.0,
      };
}

/// Kullanıcının beyan ettiği tek bir yetenek.
class Skill {
  final String id;
  final String name;
  final SkillLevel level;

  const Skill({required this.id, required this.name, required this.level});
}
