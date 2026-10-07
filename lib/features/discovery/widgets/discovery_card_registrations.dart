import '../../../core/cart/card_view_registry.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/product_card/product_card.dart';
import 'business_menu_card_view.dart';
import 'custom_gift_order_card_view.dart';
import 'custom_jewelry_order_card_view.dart';
import 'food_item_card_view.dart';
import 'food_place_search_card_view.dart';
import 'gift_catalog_card_view.dart';
import 'gift_item_card_view.dart';
import 'hotel_search_card_view.dart';
import 'jewelry_catalog_card_view.dart';
import 'jewelry_item_card_view.dart';
import 'messages_list_card_view.dart';
import 'popular_hotels_card_view.dart';
import 'social_feed_card_view.dart';
import 'video_card_view.dart';
import 'product_card_view.dart';
import 'subscription_card_view.dart';
import 'bank_product_card_view.dart';
import 'insurance_product_card_view.dart';
import 'ecommerce_product_card_view.dart';
import 'product_grid_card_view.dart';
import 'ticket_search_card_view.dart';
import 'popular_routes_card_view.dart';

void registerDiscoveryCardViews() {
  CardViewRegistry.register<VideoCard>(
    (context, card, isActive) =>
        VideoCardView(card: card as VideoCard, isActive: isActive),
  );
  CardViewRegistry.register<ProductCard>(
    (context, card, isActive) => ProductCardView(card: card as ProductCard),
  );
  CardViewRegistry.register<SubscriptionCard>(
    (context, card, isActive) =>
        SubscriptionCardView(card: card as SubscriptionCard),
  );
  CardViewRegistry.register<BankProductCard>(
    (context, card, isActive) =>
        BankProductCardView(card: card as BankProductCard),
  );
  CardViewRegistry.register<InsuranceProductCard>(
    (context, card, isActive) =>
        InsuranceProductCardView(card: card as InsuranceProductCard),
  );
  CardViewRegistry.register<EcommerceProductCard>(
    (context, card, isActive) =>
        EcommerceProductCardView(card: card as EcommerceProductCard),
  );
  CardViewRegistry.register<ProductGridCard>(
    (context, card, isActive) =>
        ProductGridCardView(card: card as ProductGridCard),
  );
  CardViewRegistry.register<TicketSearchCard>(
    (context, card, isActive) =>
        TicketSearchCardView(card: card as TicketSearchCard),
  );
  CardViewRegistry.register<PopularRoutesCard>(
    (context, card, isActive) =>
        PopularRoutesCardView(card: card as PopularRoutesCard),
  );
  CardViewRegistry.register<HotelSearchCard>(
    (context, card, isActive) =>
        HotelSearchCardView(card: card as HotelSearchCard),
  );
  CardViewRegistry.register<PopularHotelsCard>(
    (context, card, isActive) =>
        PopularHotelsCardView(card: card as PopularHotelsCard),
  );
  CardViewRegistry.register<FoodItemCard>(
    (context, card, isActive) => FoodItemCardView(card: card as FoodItemCard),
  );
  CardViewRegistry.register<BusinessMenuCard>(
    (context, card, isActive) =>
        BusinessMenuCardView(card: card as BusinessMenuCard),
  );
  CardViewRegistry.register<FoodPlaceSearchCard>(
    (context, card, isActive) =>
        FoodPlaceSearchCardView(card: card as FoodPlaceSearchCard),
  );
  CardViewRegistry.register<JewelryItemCard>(
    (context, card, isActive) =>
        JewelryItemCardView(card: card as JewelryItemCard),
  );
  CardViewRegistry.register<JewelryCatalogCard>(
    (context, card, isActive) =>
        JewelryCatalogCardView(card: card as JewelryCatalogCard),
  );
  CardViewRegistry.register<CustomJewelryOrderCard>(
    (context, card, isActive) =>
        CustomJewelryOrderCardView(card: card as CustomJewelryOrderCard),
  );
  CardViewRegistry.register<GiftItemCard>(
    (context, card, isActive) => GiftItemCardView(card: card as GiftItemCard),
  );
  CardViewRegistry.register<GiftCatalogCard>(
    (context, card, isActive) =>
        GiftCatalogCardView(card: card as GiftCatalogCard),
  );
  CardViewRegistry.register<CustomGiftOrderCard>(
    (context, card, isActive) =>
        CustomGiftOrderCardView(card: card as CustomGiftOrderCard),
  );
  CardViewRegistry.register<MessagesListCard>(
    (context, card, isActive) =>
        MessagesListCardView(card: card as MessagesListCard),
  );
  CardViewRegistry.register<SocialFeedCard>(
    (context, card, isActive) =>
        SocialFeedCardView(card: card as SocialFeedCard),
  );
}
