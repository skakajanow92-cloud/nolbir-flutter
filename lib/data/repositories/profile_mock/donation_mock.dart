import '../../../models/feed_card/feed_card.dart';
import '../../../models/donation.dart';

/// Bağış modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
DonationProfileCard buildDonationMock() {
  return DonationProfileCard(
    id: "donation1",
    // NOT: Demo verisinde bilinçli olarak KURGUSAL bir parti adı
    // kullanıldı — gerçek bir parti adı demo ekran görüntülerinde
    // yanlış anlaşılabilir. Alan opsiyonel: null/boş bırakılırsa
    // görünüm bu satırı otomatik gizler (bkz. _Header'daki hasParty).
    politicalParty: "Yeşil Gelecek Partisi",
    affiliations: [
      Affiliation(
        id: "aff1",
        name: "TEMA Vakfı",
        type: AffiliationType.organization,
        role: "Bağışçı Üye",
      ),
      Affiliation(
        id: "aff2",
        name: "LÖSEV",
        type: AffiliationType.organization,
        role: "Gönüllü",
      ),
      Affiliation(
        id: "aff3",
        name: "Mahalle Dayanışma Topluluğu",
        type: AffiliationType.community,
      ),
    ],
    donations: [
      Donation(
        id: "don1",
        organization: "TEMA Vakfı",
        amount: 500,
        date: DateTime(2026, 1, 15),
      ),
      Donation(
        id: "don2",
        organization: "LÖSEV",
        amount: 250,
        date: DateTime(2026, 8, 1),
        isRecurring: true,
      ),
      Donation(
        id: "don3",
        organization: "AHBAP",
        amount: 1000,
        date: DateTime(2025, 12, 20),
      ),
    ],
  );
}
