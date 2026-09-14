import 'base.dart';

class UserPostCard extends FeedCard implements Collectible {
  final String mediaUrl;
  final String caption;

  const UserPostCard({
    required String id,
    required this.mediaUrl,
    required this.caption,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (caption, mediaUrl);
}
