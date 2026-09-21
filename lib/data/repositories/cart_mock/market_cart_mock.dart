import '../../../models/feed_card/feed_card.dart';
import '../../../models/market_cart.dart';
import '../../../models/cart.dart';

MarketCartCard buildMarketCartMock() {
  return MarketCartCard(
    id: "marketcart1",
    cart: Cart(
      cartType: CartType.market,
      items: [
        CartItem(
          id: "mci1",
          cartType: CartType.market,
          title: "Süt 1L",
          price: 42.50,
          quantity: 2,
          metadata: const {"marketName": "Migros", "unit": "1 L"},
        ),
        CartItem(
          id: "mci2",
          cartType: CartType.market,
          title: "Yumurta 15'li",
          price: 89.90,
          metadata: const {"marketName": "CarrefourSA", "unit": "15 adet"},
        ),
        CartItem(
          id: "mci3",
          cartType: CartType.market,
          title: "Zeytinyağı 1L",
          price: 310.00,
          metadata: const {"marketName": "Migros", "unit": "1 L"},
        ),
      ],
    ),
    priceComparisons: const [
      PriceComparisonGroup(
        id: "pc1",
        productName: "Süt 1L",
        unitLabel: "1 L",
        offers: [
          MarketOffer(id: "of1", marketName: "Migros", price: 42.50),
          MarketOffer(id: "of2", marketName: "CarrefourSA", price: 39.90),
          MarketOffer(id: "of3", marketName: "A101", price: 37.50),
        ],
      ),
      PriceComparisonGroup(
        id: "pc2",
        productName: "Zeytinyağı 1L",
        unitLabel: "1 L",
        offers: [
          MarketOffer(id: "of4", marketName: "Migros", price: 310.00),
          MarketOffer(id: "of5", marketName: "ŞOK", price: 289.90),
          MarketOffer(
            id: "of6",
            marketName: "CarrefourSA",
            price: 0,
            inStock: false,
          ),
        ],
      ),
    ],
    recommendations: const [
      RecommendedProduct(
        id: "rp1",
        title: "Yoğurt 1kg",
        price: 54.90,
        marketName: "Migros",
        reason: RecommendationReason.moreFromMarket,
      ),
      RecommendedProduct(
        id: "rp2",
        title: "Badem Sütü 1L",
        price: 68.00,
        marketName: "CarrefourSA",
        reason: RecommendationReason.similarProduct,
      ),
      RecommendedProduct(
        id: "rp3",
        title: "Ayçiçek Yağı 1L",
        price: 145.00,
        marketName: "Migros",
        reason: RecommendationReason.similarProduct,
      ),
    ],
  );
}
