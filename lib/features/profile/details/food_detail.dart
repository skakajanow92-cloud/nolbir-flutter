import 'package:flutter/material.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/food_profile_card_view.dart';

/// Yemek modülünün masaüstü detay paneli görünümü: dört alt bölümün tam listesi.
Widget buildFoodDetail(BuildContext context, FoodProfileCard card) {
  const accent = FoodProfileCardView.moduleAccent;
  return DetailPage(
    title: 'Yemek',
    subtitle: '${card.favoriteRestaurants.length} favori mekan',
    icon: Icons.restaurant_menu_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Favori Yemekler (${card.favoriteFoods.length})',
        children: [
          card.favoriteFoods.isEmpty
              ? const DetailEmpty('Henüz favori yemek eklenmedi')
              : DetailChips(
                  accent: accent,
                  labels: [
                    for (final f in card.favoriteFoods)
                      f.cuisine != null ? '${f.name} · ${f.cuisine}' : f.name,
                  ],
                ),
        ],
      ),
      DetailSection(
        title: 'Favori Mekanlar (${card.favoriteRestaurants.length})',
        children: [
          if (card.favoriteRestaurants.isEmpty)
            const DetailEmpty('Henüz favori mekan yok'),
          for (final r in card.favoriteRestaurants)
            DetailItem(
              accent: accent,
              icon: Icons.storefront_outlined,
              title: r.name,
              subtitle: '${r.cuisine} · ${r.location}',
            ),
        ],
      ),
      DetailSection(
        title: 'Düzenli Siparişler (${card.recurringOrders.length})',
        children: [
          if (card.recurringOrders.isEmpty)
            const DetailEmpty('Henüz düzenli sipariş yok'),
          for (final o in card.recurringOrders)
            DetailItem(
              accent: accent,
              icon: Icons.repeat,
              title: o.orderDescription,
              subtitle: o.restaurantName,
              rows: [DetailRow(label: 'Sıklık', value: o.frequency)],
            ),
        ],
      ),
      DetailSection(
        title: 'Kafe Kartları (${card.loyaltyCards.length})',
        children: [
          if (card.loyaltyCards.isEmpty)
            const DetailEmpty('Henüz kayıtlı kafe kartı yok'),
          for (final c in card.loyaltyCards)
            DetailItem(
              accent: accent,
              icon: Icons.local_cafe_outlined,
              title: c.cafeName,
              rows: [
                if (c.hasStampProgress)
                  DetailProgress(
                    value: c.progress,
                    label: 'Damga',
                    caption: '${c.stampsCollected}/${c.stampsRequired}',
                  ),
                if (c.discountPercent != null)
                  DetailRow(
                    label: 'İndirim',
                    value: '%${c.discountPercent!.toStringAsFixed(0)}',
                  ),
                if (c.rewardDescription != null)
                  DetailRow(label: 'Ödül', value: c.rewardDescription!),
              ],
            ),
        ],
      ),
    ],
  );
}
