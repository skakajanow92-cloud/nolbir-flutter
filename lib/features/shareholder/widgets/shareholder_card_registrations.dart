import '../../../core/cart/card_view_registry.dart';
import '../../../core/cart/profile_module_order.dart';
import '../../../models/feed_card/feed_card.dart';
import 'shareholder_application_card_view.dart';

/// `registerProfileCardViews()`'ten bilinçli olarak AYRI — bu kart bir
/// içerik/lifestyle modülü değil, hesap durumu/form akışı. Profil
/// klasörü kalabalıklaşmasın diye kendi dosyasında.
void registerShareholderCardViews() {
  CardViewRegistry.register<ShareholderApplicationCard>(
    (context, card, isActive) =>
        ShareholderApplicationCardView(card: card as ShareholderApplicationCard),
  );
  ProfileModuleOrder.register<ShareholderApplicationCard>();
}
