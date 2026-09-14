import '../engagement.dart';
import 'base.dart';

/// Sekizinci profil modülü: kullanıcının takipçi/takip, paylaşım, izlenim
/// ve etkileşim (yorum/referans/tavsiye) verilerinin analiz özeti.
/// Önceki modüllerin aksine somut varlıkları (hesap, poliçe, bilet...)
/// değil, bunların ÜZERİNE kurulu sayısal/analitik bir özeti listeliyor.
class EngagementProfileCard extends FeedCard implements Collectible {
  final EngagementSummary summary;
  final List<ReferralMention> referrals;
  final List<PostDiscussion> topDiscussions;

  const EngagementProfileCard({
    required String id,
    this.summary = const EngagementSummary(),
    this.referrals = const [],
    this.topDiscussions = const [],
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => ("Etkileşim Profili", "");
}
