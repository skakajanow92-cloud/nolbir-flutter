import '../../../models/feed_card/feed_card.dart';
import '../../../models/career.dart';

/// Kariyer modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
CareerProfileCard buildCareerMock() {
  return CareerProfileCard(
    id: "career1",
    headline: "Kıdemli Ürün Tasarımcısı",
    experiences: [
      WorkExperience(
        id: "we1",
        company: "Trendyol",
        title: "Kıdemli Ürün Tasarımcısı",
        employmentType: EmploymentType.fullTime,
        location: "İstanbul, Türkiye",
        startDate: DateTime(2023, 4, 1),
        description: "Mobil alışveriş deneyimi ve tasarım sistemi.",
      ),
      WorkExperience(
        id: "we2",
        company: "Getir",
        title: "Ürün Tasarımcısı",
        employmentType: EmploymentType.fullTime,
        location: "İstanbul, Türkiye",
        startDate: DateTime(2020, 9, 1),
        endDate: DateTime(2023, 3, 1),
      ),
      WorkExperience(
        id: "we3",
        company: "Bina Yazılım",
        title: "Tasarım Stajyeri",
        employmentType: EmploymentType.internship,
        location: "Ankara, Türkiye",
        startDate: DateTime(2019, 6, 1),
        endDate: DateTime(2019, 9, 1),
      ),
    ],
    educations: [
      EducationEntry(
        id: "ed1",
        school: "Orta Doğu Teknik Üniversitesi",
        degree: "Lisans",
        fieldOfStudy: "Endüstri Ürünleri Tasarımı",
        startDate: DateTime(2016, 9, 1),
        endDate: DateTime(2020, 6, 1),
      ),
    ],
    skills: const [
      Skill(id: "sk1", name: "Figma", level: SkillLevel.expert),
      Skill(
        id: "sk2",
        name: "Tasarım Sistemleri",
        level: SkillLevel.advanced,
      ),
      Skill(
        id: "sk3",
        name: "Kullanıcı Araştırması",
        level: SkillLevel.advanced,
      ),
      Skill(id: "sk4", name: "Flutter", level: SkillLevel.intermediate),
      Skill(id: "sk5", name: "Prototipleme", level: SkillLevel.expert),
    ],
  );
}
