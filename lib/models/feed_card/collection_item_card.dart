import 'base.dart';

class CollectionItemCard extends FeedCard implements Collectible {
  final String title;
  final String previewUrl;
  final FeedCard originalCard; // koleksiyona eklenen orijinal kart referansı

  const CollectionItemCard({
    required String id,
    required this.title,
    required this.previewUrl,
    required this.originalCard,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (title, previewUrl);
}
