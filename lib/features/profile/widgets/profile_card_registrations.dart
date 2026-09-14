import '../../../core/cart/card_view_registry.dart';
import '../../../core/cart/profile_module_order.dart';
import '../../../models/feed_card/feed_card.dart';
import 'profile_header_card_view.dart';
import 'user_post_card_view.dart';
import 'wallet_profile_card_view.dart';
import 'insurance_profile_card_view.dart';
import 'travel_profile_card_view.dart';
import 'accommodation_profile_card_view.dart';
import 'food_profile_card_view.dart';
import 'engagement_profile_card_view.dart';
import 'career_profile_card_view.dart';
import 'dating_profile_card_view.dart';

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

  CardViewRegistry.register<TravelProfileCard>(
    (context, card, isActive) =>
        TravelProfileCardView(card: card as TravelProfileCard),
  );
  ProfileModuleOrder.register<TravelProfileCard>();

  CardViewRegistry.register<AccommodationProfileCard>(
    (context, card, isActive) =>
        AccommodationProfileCardView(card: card as AccommodationProfileCard),
  );
  ProfileModuleOrder.register<AccommodationProfileCard>();

  CardViewRegistry.register<FoodProfileCard>(
    (context, card, isActive) =>
        FoodProfileCardView(card: card as FoodProfileCard),
  );
  ProfileModuleOrder.register<FoodProfileCard>();

  CardViewRegistry.register<EngagementProfileCard>(
    (context, card, isActive) =>
        EngagementProfileCardView(card: card as EngagementProfileCard),
  );
  ProfileModuleOrder.register<EngagementProfileCard>();

  CardViewRegistry.register<CareerProfileCard>(
    (context, card, isActive) =>
        CareerProfileCardView(card: card as CareerProfileCard),
  );
  ProfileModuleOrder.register<CareerProfileCard>();

  CardViewRegistry.register<DatingProfileCard>(
    (context, card, isActive) =>
        DatingProfileCardView(card: card as DatingProfileCard),
  );
  ProfileModuleOrder.register<DatingProfileCard>();

  CardViewRegistry.register<UserPostCard>(
    (context, card, isActive) => UserPostCardView(card: card as UserPostCard),
  );
  ProfileModuleOrder.register<UserPostCard>();
}
