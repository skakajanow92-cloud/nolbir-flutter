import '../../../models/feed_card/feed_card.dart';
import '../../../models/food.dart';

/// Yemek modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
FoodProfileCard buildFoodMock() {
  return const FoodProfileCard(
    id: "food1",
    favoriteFoods: [
      FavoriteFood(id: "ff1", name: "Mantı", cuisine: "Türk"),
      FavoriteFood(id: "ff2", name: "Izgara Köfte", cuisine: "Türk"),
      FavoriteFood(id: "ff3", name: "Sushi", cuisine: "Japon"),
      FavoriteFood(id: "ff4", name: "Tiramisu", cuisine: "İtalyan"),
    ],
    favoriteRestaurants: [
      FavoriteRestaurant(
        id: "fr1",
        name: "Nusr-Et",
        cuisine: "Steakhouse",
        location: "İstanbul",
      ),
      FavoriteRestaurant(
        id: "fr2",
        name: "Mikla",
        cuisine: "Modern Türk",
        location: "İstanbul",
      ),
      FavoriteRestaurant(
        id: "fr3",
        name: "Kronotrop",
        cuisine: "Kahve",
        location: "Ankara",
      ),
    ],
    recurringOrders: [
      RecurringOrder(
        id: "ro1",
        restaurantName: "Domino's Pizza",
        orderDescription: "Büyük Boy Karışık Pizza",
        frequency: "Her Cuma akşamı",
      ),
      RecurringOrder(
        id: "ro2",
        restaurantName: "Starbucks",
        orderDescription: "Büyük Boy Latte",
        frequency: "Her sabah işe giderken",
      ),
    ],
    loyaltyCards: [
      CafeLoyaltyCard(
        id: "cl1",
        cafeName: "Kronotrop",
        stampsCollected: 7,
        stampsRequired: 10,
        rewardDescription: "1 Ücretsiz Filtre Kahve",
      ),
      CafeLoyaltyCard(
        id: "cl2",
        cafeName: "Starbucks Rewards",
        stampsCollected: 145,
        stampsRequired: 200,
        rewardDescription: "Ücretsiz İçecek",
      ),
      CafeLoyaltyCard(
        id: "cl3",
        cafeName: "Simit Sarayı",
        discountPercent: 15,
        rewardDescription: "Kart sahiplerine sabit indirim",
      ),
    ],
  );
}
