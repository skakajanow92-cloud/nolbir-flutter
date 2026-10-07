import '../../../core/cart/card_view_registry.dart';
import '../../../core/cart/profile_module_order.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/feed_card/feed_card.dart';
import 'bank_cart_card_view.dart';
import 'cart_summary_card_view.dart';
import 'food_cart_card_view.dart';
import 'market_cart_card_view.dart';
import 'second_hand_cart_card_view.dart';
import 'ticket_cart_card_view.dart';
import 'hotel_cart_card_view.dart';
import 'pharmacy_cart_card_view.dart';

void registerCartCardViews() {
  CardViewRegistry.register<CartSummaryCard>(
    (context, card, isActive) =>
        CartSummaryCardView(card: card as CartSummaryCard),
  );
  // registerAllCardViews() içinde registerCartCardViews(),
  // registerProfileCardViews()'ten SONRA çağrıldığı için sepet özetleri
  // otomatik olarak profil akışının en sonunda çıkar.
  ProfileModuleOrder.register<CartSummaryCard>();

  CardViewRegistry.register<MarketCartCard>(
    (context, card, isActive) =>
        MarketCartCardView(card: card as MarketCartCard),
  );
  ProfileModuleOrder.register<MarketCartCard>();

  CardViewRegistry.register<SecondHandCartCard>(
    (context, card, isActive) =>
        SecondHandCartCardView(card: card as SecondHandCartCard),
  );
  ProfileModuleOrder.register<SecondHandCartCard>();

  CardViewRegistry.register<TicketCartCard>(
    ((context, card, isActive) =>
        TicketCartCardView(card: card as TicketCartCard)),
  );
  ProfileModuleOrder.register<TicketCartCard>();

  CardViewRegistry.register<HotelCartCard>(
    ((context, card, isActive) =>
        HotelCartCardView(card: card as HotelCartCard)),
  );
  ProfileModuleOrder.register<HotelCartCard>();

  CardViewRegistry.register<FoodCartCard>(
    (context, card, isActive) => FoodCartCardView(card: card as FoodCartCard),
  );
  ProfileModuleOrder.register<FoodCartCard>();

  CardViewRegistry.register<BankCartCard>(
    (context, card, isActive) => BankCartCardView(card: card as BankCartCard),
  );
  ProfileModuleOrder.register<BankCartCard>();

  CardViewRegistry.register<PharmacyCartCard>(
    (context, card, isActive) =>
        PharmacyCartCardView(card: card as PharmacyCartCard),
  );
  ProfileModuleOrder.register<PharmacyCartCard>();
}
