import '../education.dart';
import 'base.dart';

/// On üçüncü profil modülü: kullanıcının farklı eğitim kuruluşlarıyla
/// etkileşimi — devam eden, tamamlanmış ve periyodik tekrar eden
/// programlar/kurslar. Hiyerarşi StreamingProfileCard'daki gibi iki
/// seviyeli: kurum > program.
///
/// "Devam eden / biten / periyodik" ayrımı üç ayrı enum değeri değil,
/// `EducationProgram`'daki iki bağımsız sinyalden TÜRETİLİYOR
/// (`isRecurring` ve `endDate == null`) — bkz. education.dart'taki
/// tasarım notu. Burada raporlama amacıyla üçünü birbirini dışlayan
/// kategorilere ayırıyoruz: periyodik olan bir program `isRecurring`
/// bayrağı sayesinde önceliklidir (devam ediyor ya da bitmiş olsa bile).
class EducationProfileCard extends FeedCard implements Collectible {
  final List<EducationInstitution> institutions;

  const EducationProfileCard({
    required String id,
    this.institutions = const [],
  }) : super(id);

  int get periodicCount => institutions.fold(
      0, (sum, i) => sum + i.programs.where((p) => p.isRecurring).length);

  int get ongoingCount => institutions.fold(
      0,
      (sum, i) => sum +
          i.programs.where((p) => !p.isRecurring && p.isOngoing).length);

  int get completedCount => institutions.fold(
      0,
      (sum, i) => sum +
          i.programs.where((p) => !p.isRecurring && !p.isOngoing).length);

  /// Periyodik bir programın bir sonraki yenilenmesine 7 günden az kalan
  /// en yakın kaydı döner — varsa uyarı banner'ı için (bkz.
  /// StreamingProfileCard/TravelProfileCard'daki aynı eşik).
  EducationProgram? get nextRenewalAlert {
    final candidates = <EducationProgram>[];
    for (final inst in institutions) {
      for (final p in inst.programs) {
        final days = p.daysUntilRenewal;
        if (p.isRecurring && days != null && days >= 0 && days <= 7) {
          candidates.add(p);
        }
      }
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.nextRenewalDate!.compareTo(b.nextRenewalDate!));
    return candidates.first;
  }

  @override
  (String, String) toCollectionPreview() => ("Eğitim Profili", "");
}
