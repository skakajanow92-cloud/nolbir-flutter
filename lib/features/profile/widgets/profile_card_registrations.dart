import '../../../core/cart/card_view_registry.dart';
import '../../../models/feed_card.dart';
import 'profile_header_card_view.dart';
import 'user_post_card_view.dart';
import 'wallet_profile_card_view.dart';

void registerProfileCardViews() {
  CardViewRegistry.register<ProfileHeaderCard>(
    (context, card, isActive) =>
        ProfileHeaderCardView(card: card as ProfileHeaderCard),
  );
  CardViewRegistry.register<WalletProfileCard>(
    (context, card, isActive) =>
        WalletProfileCardView(card: card as WalletProfileCard),
  );
  CardViewRegistry.register<UserPostCard>(
    (context, card, isActive) => UserPostCardView(card: card as UserPostCard),
  );
}
