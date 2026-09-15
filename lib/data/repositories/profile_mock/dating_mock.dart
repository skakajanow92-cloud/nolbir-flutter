import '../../../models/feed_card/feed_card.dart';
import '../../../models/dating.dart';

/// Tanışma modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
DatingProfileCard buildDatingMock() {
  return const DatingProfileCard(
    id: "dating1",
    tagline: "Hafta sonu dağ yürüyüşleri, hafta içi kitap kafeler.",
    photoUrls: [],
    sexualOrientation: SexualOrientation.heterosexual,
    relationshipGoal: RelationshipGoal.longTerm,
    interests: [
      InterestTag(
        id: "int1",
        category: InterestCategory.hobby,
        label: "Doğa Yürüyüşü",
      ),
      InterestTag(
        id: "int2",
        category: InterestCategory.sport,
        label: "Yüzme",
      ),
      InterestTag(
        id: "int3",
        category: InterestCategory.artist,
        label: "Sezen Aksu",
      ),
      InterestTag(
        id: "int4",
        category: InterestCategory.movie,
        label: "Interstellar",
      ),
      InterestTag(
        id: "int5",
        category: InterestCategory.game,
        label: "Zelda",
      ),
      InterestTag(
        id: "int6",
        category: InterestCategory.book,
        label: "Kürk Mantolu Madonna",
      ),
      InterestTag(
        id: "int7",
        category: InterestCategory.music,
        label: "Alternatif Rock",
      ),
    ],
  );
}
