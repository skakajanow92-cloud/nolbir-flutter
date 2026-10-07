import '../feed_card/base.dart';

class YoutubeChannel {
  final String id;
  final String name;
  final String avatarUrl;
  final int subscriberCount;

  const YoutubeChannel({
    required this.id,
    required this.name,
    this.avatarUrl = "",
    this.subscriberCount = 0,
  });
}

class LongVideoItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final Duration duration;
  final YoutubeChannel channel;
  final int viewCount;
  final DateTime uploadedAt;

  const LongVideoItem({
    required this.id,
    required this.title,
    required this.channel,
    required this.uploadedAt,
    this.thumbnailUrl = "",
    this.duration = const Duration(minutes: 5),
    this.viewCount = 0,
  });
}

/// Orta tab için: YouTube ana sayfası tarzı karışık (farklı kanal/konu)
/// uzun video akışı kartı. `SocialFeedCard`/`VideoFeedCard` ile aynı
/// aile — kendi içinde dikey kaydırmalı, sonsuz üretimli, dış akışta
/// gezinme buton tabanlı (`NavArrowOverlay`).
///
/// Buna ek olarak üstte abone olunan kanalların yatay şeridi var — bir
/// kanala dokunmak, o kanalın tüm videolarını en son yüklenen üstte
/// gelecek şekilde listeleyen bir dialog açar.
class YoutubeFeedCard extends FeedCard implements Collectible, LiveCollectible {
  final List<YoutubeChannel> subscribedChannels;
  final List<LongVideoItem> seedVideos;

  const YoutubeFeedCard({
    required String id,
    required this.subscribedChannels,
    required this.seedVideos,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (
    "Video Akışı (Uzun Form)",
    seedVideos.isNotEmpty ? seedVideos.first.thumbnailUrl : "",
  );
}
