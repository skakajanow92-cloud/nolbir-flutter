import '../../../core/cart/card_view_registry.dart';
import '../../../models/feed_card.dart';
import 'cart_summary_card_view.dart';

void registerCartCardViews() {
  CardViewRegistry.register<CartSummaryCard>(
    (context, card, isActive) =>
        CartSummaryCardView(card: card as CartSummaryCard),
  );
}
