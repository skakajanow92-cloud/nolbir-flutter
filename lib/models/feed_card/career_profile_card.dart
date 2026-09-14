import '../career.dart';
import 'base.dart';

/// Dokuzuncu profil modülü: kullanıcının iş dünyası/kariyer geçmişi —
/// iş deneyimleri (güncel dahil), eğitim bilgileri ve yetenekler.
/// Deneyim/eğitim modeli TravelTicket/AccommodationReservation'daki
/// geçmiş/güncel ayrımına benzer şekilde `endDate == null` ile "hâlâ
/// devam ediyor" durumunu taşıyor (bkz. career.dart).
class CareerProfileCard extends FeedCard implements Collectible {
  final String headline;
  final List<WorkExperience> experiences;
  final List<EducationEntry> educations;
  final List<Skill> skills;

  const CareerProfileCard({
    required String id,
    this.headline = "",
    this.experiences = const [],
    this.educations = const [],
    this.skills = const [],
  }) : super(id);

  List<WorkExperience> get sortedExperiences =>
      experiences.toList()..sort((a, b) => b.startDate.compareTo(a.startDate));

  List<EducationEntry> get sortedEducations =>
      educations.toList()..sort((a, b) => b.startDate.compareTo(a.startDate));

  /// Bitiş tarihi olmayan (hâlâ devam eden) en güncel iş deneyimi.
  WorkExperience? get currentExperience {
    final current = experiences.where((e) => e.isCurrent);
    if (current.isEmpty) return null;
    return current.reduce((a, b) => a.startDate.isAfter(b.startDate) ? a : b);
  }

  @override
  (String, String) toCollectionPreview() => ("Kariyer Profili", "");
}
