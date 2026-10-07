import '../feed_card/base.dart';

class FeedVideoItem {
  final String id;
  final String videoUrl;
  final String username;
  final String description;
  final int likeCount;
  final int commentCount;

  const FeedVideoItem({
    required this.id,
    required this.videoUrl,
    required this.username,
    required this.description,
    this.likeCount = 0,
    this.commentCount = 0,
  });
}

/// TikTok tarzı, kendi içinde dikey kaydırmalı video kartı. Tek videoluk
/// `VideoCard` zaten var — bu kart onun tersine: kullanıcı "sadece
/// videoların art arda geldiği bir akış" istediğinde Koleksiyon'a
/// eklenmek üzere var. `SocialFeedCard` gibi `LiveCollectible` — statik
/// önizleme yerine koleksiyonda da canlı haliyle (kendi iç PageView'ıyla)
/// render edilmeli.
///
/// GESTURE ÇAKIŞMASI: İçindeki `PageView` de DİKEY, dış ana akış da
/// dikey. Aynı eksende iç içe olduklarından dokunmatik sürükleme jesti
/// en içteki Scrollable'a (bu video PageView'ına) verilir ve asla dışarı
/// devredilmez. `PageAwareScrollView`'deki overscroll-devir tekniği bile
/// burada işe yaramaz çünkü iç liste sonsuz, hiçbir sınıra ulaşmaz. Bu
/// yüzden dış akışta gezinme TAMAMEN `NavArrowOverlay` butonlarıyla.
class VideoFeedCard extends FeedCard implements Collectible, LiveCollectible {
  final List<FeedVideoItem> seedVideos;

  const VideoFeedCard({required String id, required this.seedVideos})
    : super(id);

  @override
  (String, String) toCollectionPreview() => ("Video Akışı", "");
}
