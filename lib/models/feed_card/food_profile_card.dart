import '../food.dart';
import 'base.dart';

/// Altıncı profil modülü: kullanıcının yemek/kafe alışkanlıkları —
/// favori yemekler, favori mekanlar, düzenli siparişler, kafe sadakat/
/// indirim kartları. Önceki modüllerden farklı olarak dört alt bölümü var.
class FoodProfileCard extends FeedCard implements Collectible {
  final List<FavoriteFood> favoriteFoods;
  final List<FavoriteRestaurant> favoriteRestaurants;
  final List<RecurringOrder> recurringOrders;
  final List<CafeLoyaltyCard> loyaltyCards;

  const FoodProfileCard({
    required String id,
    this.favoriteFoods = const [],
    this.favoriteRestaurants = const [],
    this.recurringOrders = const [],
    this.loyaltyCards = const [],
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => ("Yemek Profili", "");
}
