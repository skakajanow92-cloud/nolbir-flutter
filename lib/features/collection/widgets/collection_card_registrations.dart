import '../../../core/cart/card_view_registry.dart';
import '../../../models/feed_card/feed_card.dart';
import 'collection_item_card_view.dart';

void registerCollectionCardViews() {
  CardViewRegistry.register<CollectionItemCard>(
    (context, card, isActive) =>
        CollectionItemCardView(card: card as CollectionItemCard),
  );
}
