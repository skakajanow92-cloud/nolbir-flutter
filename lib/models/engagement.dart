/// Kullanıcıya başkaları tarafından yapılan ikincil referans türü —
/// bir gönderiden bağımsız, doğrudan profile yapılan atıf/tavsiye/paylaşım.
enum ReferralType { mention, recommendation, share }

extension ReferralTypeLabel on ReferralType {
  String get label => switch (this) {
        ReferralType.mention => "Referans",
        ReferralType.recommendation => "Arkadaşa Tavsiye",
        ReferralType.share => "Paylaşım",
      };
}

/// Başka bir kullanıcının bu profile yaptığı ikincil referans/tavsiye/
/// paylaşım kaydı.
class ReferralMention {
  final String id;
  final String fromUsername;
  final ReferralType type;
  final String? note; // örn. tavsiye metni ya da kısa bağlam
  final DateTime date;

  const ReferralMention({
    required this.id,
    required this.fromUsername,
    required this.type,
    this.note,
    required this.date,
  });
}

/// Bir gönderi üzerindeki etkileşim/tartışma özeti. Yorum sayısı ile o
/// yorumlara yapılan alt yorum (reply/tartışma) sayısı BİLİNÇLİ olarak ayrı
/// tutuluyor — "toplam yorum" ile "yorumlar üzerindeki tartışma" farklı
/// sinyaller (bkz. EngagementSummary.totalComments / totalReplies).
class PostDiscussion {
  final String id;
  final String postCaption; // ilgili gönderinin kısa açıklaması/başlığı
  final int commentCount;
  final int replyCount;
  final int impressionCount;

  const PostDiscussion({
    required this.id,
    required this.postCaption,
    required this.commentCount,
    this.replyCount = 0,
    this.impressionCount = 0,
  });

  int get totalDiscussion => commentCount + replyCount;
}

/// Etkileşim analizi profilinin sayısal özeti (agrega değerler).
///
/// NOT: `followerCount`/`followingCount` burada ProfileHeaderCard'daki
/// `followerCount`'tan BİLİNÇLİ olarak bağımsız tutuluyor — Temel Bilgiler
/// kartındaki alan kimlik/profil bağlamı için, buradaki ise analiz
/// bağlamı için. İleride backend adımında iki alan aynı kaynağa
/// bağlanabilir ama modelde ayrı kalmaları modülleri birbirinden
/// bağımsız tutma prensibiyle (bkz. diğer profil modülleri) tutarlı.
class EngagementSummary {
  final int followerCount;
  final int followingCount;
  final int totalPosts;
  final int totalImpressions;
  final int totalComments;
  final int totalReplies;
  final int totalReferrals;

  const EngagementSummary({
    this.followerCount = 0,
    this.followingCount = 0,
    this.totalPosts = 0,
    this.totalImpressions = 0,
    this.totalComments = 0,
    this.totalReplies = 0,
    this.totalReferrals = 0,
  });
}
