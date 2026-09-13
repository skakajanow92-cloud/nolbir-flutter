import 'package:flutter/material.dart';
import '../models/feed_card.dart';
import '../features/discovery/widgets/video_card_view.dart';
import '../features/discovery/widgets/product_card_view.dart';
import '../features/discovery/widgets/subscription_card_view.dart';
import '../features/profile/widgets/profile_header_card_view.dart';
import '../features/profile/widgets/user_post_card_view.dart';
import '../features/collection/widgets/collection_item_card_view.dart';
import '../features/cart/widgets/cart_summary_card_view.dart';

/// TÜM tab'ların ortak kullandığı tek factory.
/// Yeni bir kart tipi eklediğinde sadece buraya bir case eklemen yeterli;
/// VerticalCardFeed'e veya tab widget'larına dokunmana gerek yok.
Widget buildFeedCard(BuildContext context, FeedCard card, bool isActive) {
  return switch (card) {
    VideoCard v => VideoCardView(card: v, isActive: isActive),
    ProductCard p => ProductCardView(card: p),
    SubscriptionCard s => SubscriptionCardView(card: s),
    ProfileHeaderCard pr => ProfileHeaderCardView(card: pr),
    UserPostCard up => UserPostCardView(card: up),
    CollectionItemCard c => CollectionItemCardView(card: c),
    CartSummaryCard cs => CartSummaryCardView(card: cs),
  };
}
