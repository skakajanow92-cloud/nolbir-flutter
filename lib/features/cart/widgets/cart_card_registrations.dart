import '../../../core/cart/card_view_registry.dart';
import '../../../core/cart/profile_module_order.dart';
import '../../../models/feed_card/feed_card.dart';
import 'cart_summary_card_view.dart';
import 'market_cart_card_view.dart';

void registerCartCardViews() {
  CardViewRegistry.register<CartSummaryCard>(
    (context, card, isActive) =>
        CartSummaryCardView(card: card as CartSummaryCard),
  );
  // registerAllCardViews() içinde registerCartCardViews(),
  // registerProfileCardViews()'ten SONRA çağrıldığı için sepet özetleri
  // otomatik olarak profil akışının en sonunda çıkar.
  ProfileModuleOrder.register<CartSummaryCard>();

  CardViewRegistry.register<MarketCartCard>(
    (context, card, isActive) =>
        MarketCartCardView(card: card as MarketCartCard),
  );
  ProfileModuleOrder.register<MarketCartCard>();
}
