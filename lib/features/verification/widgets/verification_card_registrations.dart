import '../../../core/cart/card_view_registry.dart';
import '../../../core/cart/profile_module_order.dart';
import '../../../models/feed_card/feed_card.dart';
import 'verification_profile_card_view.dart';

/// `registerProfileCardViews()`'ten bilinçli olarak AYRI — bu kart bir
/// içerik/lifestyle modülü değil, hesap durumu + form akışının kesiştiği
/// işlevsel bir ekran. Profil klasörü kalabalıklaşmasın diye kendi
/// dosyasında, `features/verification/` altında tutuluyor.
void registerVerificationCardViews() {
  CardViewRegistry.register<VerificationProfileCard>(
    (context, card, isActive) =>
        VerificationProfileCardView(card: card as VerificationProfileCard),
  );
  ProfileModuleOrder.register<VerificationProfileCard>();
}
