import '../../models/feed_card.dart';

CollectionItemCard toCollectionItem(FeedCard card) {
  final (String title, String previewUrl) = switch (card) {
    Collectible c => c.toCollectionPreview(),
    _ => _fallbackPreview(card),
  };

  return CollectionItemCard(
    id: "col_${card.id}",
    title: title,
    previewUrl: previewUrl,
    originalCard: card,
  );
}

(String, String) _fallbackPreview(FeedCard card) {
  return (card.runtimeType.toString(), "");
}