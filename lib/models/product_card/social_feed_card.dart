import '../feed_card/base.dart';

class StoryItem {
  final String id;
  final String username;
  final String avatarUrl;
  final bool isViewed;

  const StoryItem({
    required this.id,
    required this.username,
    this.avatarUrl = "",
    this.isViewed = false,
  });
}

class SocialPost {
  final String id;
  final String username;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  final int likeCount;
  final int commentCount;
  final DateTime postedAt;

  const SocialPost({
    required this.id,
    required this.username,
    required this.imageUrl,
    required this.caption,
    required this.postedAt,
    this.avatarUrl = "",
    this.likeCount = 0,
    this.commentCount = 0,
  });
}

/// Orta tab için: Instagram/X tarzı sonsuz akış kartı. Diğer kartlardan
/// yapısal farkı: kendi İÇİNDE ikinci bir dikey kaydırma alanı barındırır
/// (üstte yatay hikayeler, altında sonsuz gönderi akışı). Bu yüzden
/// `PageAwareScrollView`'in overscroll-devir mekanizması BİLEREK
/// kullanılmadı — bu listenin ulaşılacak bir sınırı yok, sürekli yeni
/// gönderi üretiliyor, dolayısıyla "sınıra gelince bir sonraki ana karta
/// geç" davranışı hiç tetiklenmez. Bunun yerine sağda sabit konumlu
/// yukarı/aşağı ok butonları ana akışta gezinmeyi sağlıyor (bkz. view).
class SocialFeedCard extends FeedCard implements Collectible, LiveCollectible {
  final List<StoryItem> stories;
  final List<SocialPost> seedPosts;

  const SocialFeedCard({
    required String id,
    required this.stories,
    required this.seedPosts,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (
        "Sosyal Akış",
        seedPosts.isNotEmpty ? seedPosts.first.imageUrl : "",
      );
}