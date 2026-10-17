import '../../../core/cart/card_view_registry.dart';
import '../../../core/cart/profile_module_order.dart';
import '../../../models/feed_card/feed_card.dart';
import 'admin_application_card_view.dart';

/// `registerProfileCardViews()`'ten bilinçli olarak AYRI — bu kart bir
/// içerik modülü değil, hesap durumu/form akışı.
void registerAdminCardViews() {
  CardViewRegistry.register<AdminApplicationCard>(
    (context, card, isActive) =>
        AdminApplicationCardView(card: card as AdminApplicationCard),
  );
  ProfileModuleOrder.register<AdminApplicationCard>();
}
