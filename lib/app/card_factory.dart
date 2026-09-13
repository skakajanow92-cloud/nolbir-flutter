import 'package:flutter/material.dart';
import '../models/feed_card.dart';
import '../core/cart/card_view_registry.dart';

/// Geriye dönük uyumluluk için korunan ince sarmalayıcı — tab'lar ve
/// VerticalCardFeed hâlâ `buildFeedCard`'ı çağırıyor, gerçek dispatch
/// artık CardViewRegistry üzerinden yapılıyor.
Widget buildFeedCard(BuildContext context, FeedCard card, bool isActive) {
  return CardViewRegistry.build(context, card, isActive);
}
