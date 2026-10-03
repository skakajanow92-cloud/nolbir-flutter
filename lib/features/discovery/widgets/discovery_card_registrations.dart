import '../../../core/cart/card_view_registry.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/product_card/product_card.dart';
import 'video_card_view.dart';
import 'product_card_view.dart';
import 'subscription_card_view.dart';
import 'bank_product_card_view.dart';
import 'insurance_product_card_view.dart';
import 'ecommerce_product_card_view.dart';
import 'product_grid_card_view.dart';

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
  CardViewRegistry.register<BankProductCard>(
    (context, card, isActive) =>
        BankProductCardView(card: card as BankProductCard),
  );
  CardViewRegistry.register<InsuranceProductCard>(
    (context, card, isActive) =>
        InsuranceProductCardView(card: card as InsuranceProductCard),
  );
  CardViewRegistry.register<EcommerceProductCard>(
    (context, card, isActive) =>
        EcommerceProductCardView(card: card as EcommerceProductCard),
  );
  CardViewRegistry.register<ProductGridCard>(
    (context, card, isActive) =>
        ProductGridCardView(card: card as ProductGridCard),
  );
}
