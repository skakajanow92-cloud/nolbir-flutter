import '../../../core/layout/card_detail_registry.dart';
import '../../../models/feed_card/feed_card.dart';
import 'details/accommodation_detail.dart';
import 'details/career_detail.dart';
import 'details/dating_detail.dart';
import 'details/engagement_detail.dart';
import 'details/food_detail.dart';
import 'details/header_detail.dart';
import 'details/insurance_detail.dart';
import 'details/travel_detail.dart';
import 'details/user_post_detail.dart';
import 'details/wallet_detail.dart';

/// Profil modüllerinin masaüstü detay paneli kayıtları. Bu dosya SADECE
/// kayıt satırlarını tutar; her modülün görünümü `details/` altında kendi
/// dosyasındadır.
///
/// Yeni bir profil modülü eklerken:
///  1. `details/<modul>_detail.dart` içine `build<Modul>Detail` yaz
///  2. Yukarıya import, aşağıya bir `register` satırı ekle
void registerProfileCardDetails() {
  CardDetailRegistry.register<ProfileHeaderCard>(buildProfileHeaderDetail);
  CardDetailRegistry.register<WalletProfileCard>(buildWalletDetail);
  CardDetailRegistry.register<InsuranceProfileCard>(buildInsuranceDetail);
  CardDetailRegistry.register<TravelProfileCard>(buildTravelDetail);
  CardDetailRegistry.register<AccommodationProfileCard>(buildAccommodationDetail);
  CardDetailRegistry.register<FoodProfileCard>(buildFoodDetail);
  CardDetailRegistry.register<EngagementProfileCard>(buildEngagementDetail);
  CardDetailRegistry.register<CareerProfileCard>(buildCareerDetail);
  CardDetailRegistry.register<DatingProfileCard>(buildDatingDetail);
  CardDetailRegistry.register<UserPostCard>(buildUserPostDetail);
}
