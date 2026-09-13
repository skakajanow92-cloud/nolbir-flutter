import '../../models/feed_card.dart';

CollectionItemCard toCollectionItem(FeedCard card) {
  String title;
  String previewUrl;

  if (card is Collectible) {
    (title, previewUrl) = card.toCollectionPreview();
  } else {
    (title, previewUrl) = _fallbackPreview(card);
  }

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
