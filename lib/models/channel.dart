/// Bir kanala ait tek bir video.
class ChannelVideo {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final Duration duration;
  final int viewCount;
  final int commentCount;
  final int likeCount;
  final DateTime publishedDate;

  const ChannelVideo({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.duration,
    this.viewCount = 0,
    this.commentCount = 0,
    this.likeCount = 0,
    required this.publishedDate,
  });
}

/// Bir kanaldaki bir videoya yapılmış yorum — moderasyon/inceleme akışı
/// için `isReviewed` alanı taşıyor.
class ChannelComment {
  final String id;
  final String videoTitle;
  final String authorUsername;
  final String text;
  final DateTime date;
  final bool isReviewed;

  const ChannelComment({
    required this.id,
    required this.videoTitle,
    required this.authorUsername,
    required this.text,
    required this.date,
    this.isReviewed = false,
  });
}

/// Kullanıcının yönettiği tek bir kanal.
///
/// NOT: EngagementProfileCard'daki (7. modül) genel profil etkileşim
/// özetinden BİLİNÇLİ olarak bağımsız — o, kullanıcının kişisel akışındaki
/// (gönderi/yorum/referans) genel bir analiz; bu ise kullanıcının sahip
/// olduğu, her biri kendi videolarına/yorumlarına/istatistiklerine sahip
/// AYRI kanal varlıklarını modelliyor (bkz. WalletProfileCard'daki
/// "birden fazla hesap" yaklaşımına benzer çoklu-varlık deseni).
class Channel {
  final String id;
  final String name;
  final String? avatarUrl;
  final String description;
  final String category; // örn. "Teknoloji", "Yemek", "Vlog"
  final int subscriberCount;
  final int totalViews;
  final DateTime createdDate;
  final List<ChannelVideo> videos;
  final List<ChannelComment> pendingComments;

  const Channel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.description = "",
    this.category = "",
    this.subscriberCount = 0,
    this.totalViews = 0,
    required this.createdDate,
    this.videos = const [],
    this.pendingComments = const [],
  });

  int get videoCount => videos.length;

  int get unreviewedCommentCount =>
      pendingComments.where((c) => !c.isReviewed).length;

  List<ChannelVideo> get videosByRecency => videos.toList()
    ..sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
}
