import '../../../models/feed_card/feed_card.dart';
import '../../../models/engagement.dart';

/// Etkileşim modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
EngagementProfileCard buildEngagementMock() {
  return EngagementProfileCard(
    id: "engagement1",
    summary: const EngagementSummary(
      followerCount: 128,
      followingCount: 84,
      totalPosts: 37,
      totalImpressions: 214500,
      totalComments: 612,
      totalReplies: 218,
      totalReferrals: 19,
    ),
    referrals: [
      ReferralMention(
        id: "ref1",
        fromUsername: "elif.demir",
        type: ReferralType.recommendation,
        note: "Harika içerikler paylaşıyor, takip edin!",
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ReferralMention(
        id: "ref2",
        fromUsername: "mehmetcan",
        type: ReferralType.mention,
        note: "Son gönderisinden bahsetti",
        date: DateTime.now().subtract(const Duration(days: 6)),
      ),
      ReferralMention(
        id: "ref3",
        fromUsername: "seda_k",
        type: ReferralType.share,
        date: DateTime.now().subtract(const Duration(days: 11)),
      ),
    ],
    topDiscussions: [
      PostDiscussion(
        id: "disc1",
        postCaption: "Bodrum'dan gün batımı",
        commentCount: 84,
        replyCount: 31,
        impressionCount: 15200,
      ),
      PostDiscussion(
        id: "disc2",
        postCaption: "Yeni yıl hedeflerim",
        commentCount: 52,
        replyCount: 12,
        impressionCount: 9800,
      ),
      PostDiscussion(
        id: "disc3",
        postCaption: "Ev tadilatı öncesi/sonrası",
        commentCount: 41,
        replyCount: 26,
        impressionCount: 7400,
      ),
    ],
  );
}
