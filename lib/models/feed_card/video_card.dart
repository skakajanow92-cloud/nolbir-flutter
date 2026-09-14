import 'base.dart';

/// --- ORTA TAB (Genel Akış) için kart tipleri ---

class VideoCard extends FeedCard implements Collectible {
  final String videoUrl;
  final String username;
  final String description;
  final int likeCount;

  const VideoCard({
    required String id,
    required this.videoUrl,
    required this.username,
    required this.description,
    this.likeCount = 0,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() =>
      ("@$username: $description", videoUrl);
}
