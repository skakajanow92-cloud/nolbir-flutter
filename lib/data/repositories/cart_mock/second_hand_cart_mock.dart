import '../../../models/cart_card/second_hand_cart_card.dart';
import '../../../models/second_hand_cart.dart';
import '../../../models/cart.dart';

SecondHandCartCard buildSecondHandCartMock() {
  return SecondHandCartCard(
    id: "secondhandcart1",
    cart: Cart(
      cartType: CartType.secondHand,
      items: [
        CartItem(
          id: "shci1",
          cartType: CartType.secondHand,
          title: "iPhone 12 128GB",
          price: 18500,
          metadata: const {
            "sellerName": "Emre Kaya",
            "sellerRating": 4.8,
            "sellerLocation": "Kadıköy, İstanbul",
            "condition": ItemCondition.likeNew,
          },
        ),
        CartItem(
          id: "shci2",
          cartType: CartType.secondHand,
          title: "IKEA Çalışma Masası",
          price: 950,
          metadata: const {
            "sellerName": "Selin Arslan",
            "sellerRating": 4.5,
            "sellerLocation": "Beşiktaş, İstanbul",
            "condition": ItemCondition.used,
          },
        ),
      ],
    ),
    similarListings: const [
      SimilarListingGroup(
        id: "sl1",
        listingTitle: "iPhone 12 128GB",
        offers: [
          IndividualSellerOffer(
            id: "iso1",
            sellerName: "Emre Kaya",
            sellerRating: 4.8,
            condition: ItemCondition.likeNew,
            price: 18500,
            location: "Kadıköy, İstanbul",
          ),
          IndividualSellerOffer(
            id: "iso2",
            sellerName: "Burak Yıldız",
            sellerRating: 4.2,
            condition: ItemCondition.used,
            price: 16900,
            location: "Bornova, İzmir",
          ),
          IndividualSellerOffer(
            id: "iso3",
            sellerName: "Deniz Aksoy",
            sellerRating: 4.9,
            condition: ItemCondition.brandNew,
            price: 21000,
            location: "Çankaya, Ankara",
          ),
        ],
      ),
    ],
    recommendations: const [
      RecommendedListing(
        id: "rl1",
        title: "iPhone 12 Şeffaf Kılıf",
        price: 120,
        sellerName: "Emre Kaya",
        condition: ItemCondition.brandNew,
        reason: ListingRecommendationReason.moreFromSeller,
      ),
      RecommendedListing(
        id: "rl2",
        title: "Samsung Galaxy S21 128GB",
        price: 14500,
        sellerName: "Ayşe Demir",
        condition: ItemCondition.used,
        reason: ListingRecommendationReason.similarListing,
      ),
    ],
  );
}
