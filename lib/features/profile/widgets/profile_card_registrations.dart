import '../../../core/cart/card_view_registry.dart';
import '../../../core/cart/profile_module_order.dart';
import '../../../models/feed_card.dart';
import 'profile_header_card_view.dart';
import 'user_post_card_view.dart';
import 'wallet_profile_card_view.dart';
import 'insurance_profile_card_view.dart';

/// Bu fonksiyondaki her blok ARTIK iki işi birden yapıyor: hem görünümü
/// kaydediyor (CardViewRegistry) hem de profil akışındaki sırasını
/// belirliyor (ProfileModuleOrder). Yeni bir profil modülü eklerken bu iki
/// satırı bir arada, istediğin sıraya yazman yeterli.
void registerProfileCardViews() {
  CardViewRegistry.register<ProfileHeaderCard>(
    (context, card, isActive) =>
        ProfileHeaderCardView(card: card as ProfileHeaderCard),
  );
  ProfileModuleOrder.register<ProfileHeaderCard>();

  CardViewRegistry.register<WalletProfileCard>(
    (context, card, isActive) =>
        WalletProfileCardView(card: card as WalletProfileCard),
  );
  ProfileModuleOrder.register<WalletProfileCard>();

  CardViewRegistry.register<InsuranceProfileCard>(
    (context, card, isActive) =>
        InsuranceProfileCardView(card: card as InsuranceProfileCard),
  );
  ProfileModuleOrder.register<InsuranceProfileCard>();

  CardViewRegistry.register<UserPostCard>(
    (context, card, isActive) => UserPostCardView(card: card as UserPostCard),
  );
  ProfileModuleOrder.register<UserPostCard>();
}
