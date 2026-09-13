import '../../../core/cart/card_view_registry.dart';
import '../../../models/feed_card.dart';
import 'video_card_view.dart';
import 'product_card_view.dart';
import 'subscription_card_view.dart';

void registerDiscoveryCardViews() {
  CardViewRegistry.register<VideoCard>(
    (context, card, isActive) =>
        VideoCardView(card: card as VideoCard, isActive: isActive),
  );
  CardViewRegistry.register<ProductCard>(
    (context, card, isActive) => ProductCardView(card: card as ProductCard),
  );
  CardViewRegistry.register<SubscriptionCard>(
    (context, card, isActive) =>
        SubscriptionCardView(card: card as SubscriptionCard),
  );
}
