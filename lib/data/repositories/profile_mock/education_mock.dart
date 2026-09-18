import '../../../models/feed_card/feed_card.dart';
import '../../../models/education.dart';

/// Eğitim modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
EducationProfileCard buildEducationMock() {
  return EducationProfileCard(
    id: "education1",
    institutions: [
      EducationInstitution(
        id: "inst1",
        name: "Boğaziçi Üniversitesi",
        interactionChannel: "Öğrenci Bilgi Sistemi",
        programs: [
          EducationProgram(
            id: "edu1",
            name: "İşletme Yüksek Lisans",
            type: EducationProgramType.degree,
            startDate: DateTime(2020, 9, 1),
            endDate: DateTime(2022, 6, 15),
            hasCertificate: true,
          ),
        ],
      ),
      EducationInstitution(
        id: "inst2",
        name: "Coursera",
        interactionChannel: "Mobil Uygulama",
        programs: [
          EducationProgram(
            id: "edu2",
            name: "Makine Öğrenmesi Uzmanlığı",
            type: EducationProgramType.certificate,
            startDate: DateTime(2026, 3, 1),
            progressPercent: 60,
            price: 1450,
          ),
          EducationProgram(
            id: "edu3",
            name: "Veri Bilimi Temelleri",
            type: EducationProgramType.certificate,
            startDate: DateTime(2025, 1, 10),
            endDate: DateTime(2025, 4, 20),
            hasCertificate: true,
            price: 890,
          ),
        ],
      ),
      EducationInstitution(
        id: "inst3",
        name: "British Council",
        interactionChannel: "E-posta",
        programs: [
          // Periyodik program — bilerek DateTime.now() bazlı, sabit tarih
          // değil (travel/accommodation/streaming modüllerindeki aynı
          // yaklaşım: demo hangi tarihte test edilirse edilsin uyarı
          // anlamlı kalsın).
          EducationProgram(
            id: "edu4",
            name: "İleri İngilizce Konuşma Kulübü",
            type: EducationProgramType.languageSchool,
            startDate: DateTime(2026, 1, 15),
            isRecurring: true,
            nextRenewalDate: DateTime.now().add(const Duration(days: 4)),
            price: 650,
          ),
        ],
      ),
      EducationInstitution(
        id: "inst4",
        name: "Udemy",
        programs: [
          EducationProgram(
            id: "edu5",
            name: "Flutter ile Mobil Uygulama Geliştirme",
            type: EducationProgramType.course,
            startDate: DateTime(2026, 7, 1),
            progressPercent: 30,
            price: 249.90,
          ),
        ],
      ),
    ],
  );
}
