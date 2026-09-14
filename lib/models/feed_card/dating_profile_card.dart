import '../dating.dart';
import 'base.dart';

/// Onuncu profil modülü: sağa/sola kaydırarak eşleşme aranan akışlarda
/// (Tinder-benzeri bir özellik) kullanılabilecek "tam donanımlı" tanışma
/// profili — tanıtım yazısı, fotoğraflar, cinsel yönelim, aranan ilişki
/// türü ve kategorilere ayrılmış ilgi alanları (hobi/spor/sanatçı/film/
/// oyun/kitap/müzik).
///
/// NOT: Sağa/sola kaydırmalı eşleşme EKRANI burada TANIMLANMIYOR — bu kart
/// sadece o ekranda kullanılacak profil verisini taşıyor, diğer profil
/// modülleriyle aynı dikey Profil akışında önizleniyor.
class DatingProfileCard extends FeedCard implements Collectible {
  final String tagline;
  final List<String> photoUrls;
  final SexualOrientation sexualOrientation;
  final RelationshipGoal relationshipGoal;
  final List<InterestTag> interests;

  const DatingProfileCard({
    required String id,
    this.tagline = "",
    this.photoUrls = const [],
    this.sexualOrientation = SexualOrientation.preferNotToSay,
    this.relationshipGoal = RelationshipGoal.longTerm,
    this.interests = const [],
  }) : super(id);

  List<InterestTag> interestsOf(InterestCategory category) =>
      interests.where((t) => t.category == category).toList();

  @override
  (String, String) toCollectionPreview() =>
      ("Tanışma Profili", photoUrls.isNotEmpty ? photoUrls.first : "");
}
