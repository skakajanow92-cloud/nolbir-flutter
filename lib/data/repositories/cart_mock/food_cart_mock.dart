import '../../../models/cart_card/cart_card.dart';
import '../../../models/food_cart.dart';
import '../../../models/cart.dart';

FoodCartCard buildFoodCartMock() {
  return FoodCartCard(
    id: "foodcart1",
    cart: Cart(
      cartType: CartType.food,
      items: [
        CartItem(
          id: "fci1",
          cartType: CartType.food,
          title: "Karışık Pizza",
          price: 245.00,
          metadata: const {
            "restaurantName": "Pizza Locale",
            "category": "Ana Yemek",
            "specialInstructions": "Acısız olsun",
            "estimatedPrepMinutes": 25,
          },
        ),
        CartItem(
          id: "fci2",
          cartType: CartType.food,
          title: "Ayran",
          price: 25.00,
          quantity: 2,
          metadata: const {
            "restaurantName": "Pizza Locale",
            "category": "İçecek",
          },
        ),
        CartItem(
          id: "fci3",
          cartType: CartType.food,
          title: "Baklava Tabağı",
          price: 180.00,
          metadata: const {
            "restaurantName": "Güllüoğlu",
            "category": "Tatlı",
            "estimatedPrepMinutes": 10,
          },
        ),
      ],
    ),
    nearbyBusinesses: const [
      NearbyBusiness(
        id: "nb1",
        name: "Pizza Locale",
        cuisineType: "İtalyan",
        distanceKm: 0.8,
        rating: 4.6,
        estimatedDeliveryMinutes: 30,
        minOrderAmount: 150,
      ),
      NearbyBusiness(
        id: "nb2",
        name: "Güllüoğlu",
        cuisineType: "Tatlı & Baklava",
        distanceKm: 1.4,
        rating: 4.8,
        estimatedDeliveryMinutes: 35,
      ),
      NearbyBusiness(
        id: "nb3",
        name: "Kahve Durağı",
        cuisineType: "Kahve",
        distanceKm: 0.3,
        rating: 4.3,
        estimatedDeliveryMinutes: 15,
        minOrderAmount: 60,
      ),
    ],
    highRatedDishes: const [
      HighRatedDish(
        id: "hrd1",
        dishName: "Trüf Mantarlı Pizza",
        businessName: "Pizza Locale",
        price: 310.00,
        rating: 4.9,
        ratingCount: 214,
      ),
      HighRatedDish(
        id: "hrd2",
        dishName: "Fıstıklı Baklava (1 Kg)",
        businessName: "Güllüoğlu",
        price: 620.00,
        rating: 4.9,
        ratingCount: 512,
      ),
      HighRatedDish(
        id: "hrd3",
        dishName: "Cortado",
        businessName: "Kahve Durağı",
        price: 85.00,
        rating: 4.7,
        ratingCount: 98,
      ),
    ],
  );
}
