import '../../../models/cart_card/cart_card.dart';
import '../../../models/hotel_cart.dart';
import '../../../models/cart.dart';

HotelCartCard buildHotelCartMock() {
  // Tarihler bilerek DateTime.now() bazlı — diğer modüllerdeki gelecek-olay
  // mock'larıyla aynı yaklaşım, demo hangi gün açılırsa açılsın anlamlı
  // kalsın diye.
  final belekCheckIn = DateTime.now().add(const Duration(days: 20));
  final belekCheckOut = belekCheckIn.add(const Duration(days: 3));
  final swissCheckIn = DateTime.now().add(const Duration(days: 34));
  final swissCheckOut = swissCheckIn.add(const Duration(days: 2));

  return HotelCartCard(
    id: "hotelcart1",
    cart: Cart(
      cartType: CartType.accommodation,
      items: [
        CartItem(
          id: "hci1",
          cartType: CartType.accommodation,
          title: "Rixos Premium Belek",
          price: 42000, // 3 gecenin toplamı, tek oda
          metadata: {
            "hotelName": "Rixos Premium Belek",
            "location": "Belek, Antalya",
            "roomType": "Suit",
            "guestCount": 2,
            "checkIn": belekCheckIn,
            "checkOut": belekCheckOut,
            "boardType": "Her Şey Dahil",
            "freeCancellation": true,
            // Alarm banner'ını göstermek için kısa tutma süresi.
            "holdExpiresAt": DateTime.now().add(const Duration(hours: 5)),
          },
        ),
        CartItem(
          id: "hci2",
          cartType: CartType.accommodation,
          title: "Swissôtel The Bosphorus",
          price: 16000, // 2 gecenin toplamı, tek oda
          metadata: {
            "hotelName": "Swissôtel The Bosphorus",
            "location": "Beşiktaş, İstanbul",
            "roomType": "Deluxe Oda",
            "guestCount": 1,
            "checkIn": swissCheckIn,
            "checkOut": swissCheckOut,
            "boardType": "Kahvaltı Dahil",
            "freeCancellation": false,
            "holdExpiresAt": DateTime.now().add(const Duration(days: 3)),
          },
        ),
      ],
    ),
    priceComparisons: [
      HotelComparisonGroup(
        id: "hc1",
        hotelName: "Rixos Premium Belek",
        location: "Belek, Antalya",
        roomType: "Suit",
        checkIn: belekCheckIn,
        checkOut: belekCheckOut,
        offers: const [
          PlatformOffer(
            id: "po1",
            platformName: "Booking.com",
            totalPrice: 42000,
            freeCancellation: true,
            breakfastIncluded: true,
          ),
          PlatformOffer(
            id: "po2",
            platformName: "Otelz.com",
            totalPrice: 40800,
            freeCancellation: false,
            breakfastIncluded: true,
          ),
          PlatformOffer(
            id: "po3",
            platformName: "Otel Web Sitesi",
            totalPrice: 41500,
            freeCancellation: true,
            breakfastIncluded: true,
          ),
          PlatformOffer(
            id: "po4",
            platformName: "Jolly Tur",
            totalPrice: 0,
            isAvailable: false,
          ),
        ],
      ),
      HotelComparisonGroup(
        id: "hc2",
        hotelName: "Swissôtel The Bosphorus",
        location: "Beşiktaş, İstanbul",
        roomType: "Deluxe Oda",
        checkIn: swissCheckIn,
        checkOut: swissCheckOut,
        offers: const [
          PlatformOffer(
            id: "po5",
            platformName: "Booking.com",
            totalPrice: 16000,
            freeCancellation: false,
            breakfastIncluded: true,
          ),
          PlatformOffer(
            id: "po6",
            platformName: "Otelz.com",
            totalPrice: 15200,
            freeCancellation: true,
            breakfastIncluded: true,
          ),
          PlatformOffer(
            id: "po7",
            platformName: "Otel Web Sitesi",
            totalPrice: 16800,
            freeCancellation: true,
            breakfastIncluded: true,
          ),
        ],
      ),
    ],
    recommendations: const [
      RecommendedHotel(
        id: "rh1",
        hotelName: "Regnum Carya",
        location: "Belek, Antalya",
        pricePerNight: 11800,
        rating: 9.1,
        reason: HotelRecommendationReason.similarHotel,
      ),
      RecommendedHotel(
        id: "rh2",
        hotelName: "Maxx Royal Belek",
        location: "Belek, Antalya",
        pricePerNight: 15200,
        rating: 9.3,
        reason: HotelRecommendationReason.nearbyAlternative,
      ),
      RecommendedHotel(
        id: "rh3",
        hotelName: "Swissôtel Büyük Efes",
        location: "Alsancak, İzmir",
        pricePerNight: 6400,
        rating: 8.8,
        reason: HotelRecommendationReason.sameChain,
      ),
    ],
  );
}
