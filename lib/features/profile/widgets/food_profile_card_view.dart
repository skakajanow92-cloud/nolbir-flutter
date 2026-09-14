import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/food.dart';
import '../../../core/widgets/page_aware_scroll_view.dart';

/// Yemek Profili — altıncı profil modülü.
///
/// TASARIM NOTU: Bu modülün dört alt bölümü var (favori yemekler, favori
/// mekanlar, düzenli siparişler, kafe kartları) — önceki modüllerin aksine
/// içeriğin her cihazda tek ekrana sığacağını garanti edemiyoruz. Bu
/// yüzden bilinçli olarak içerik `SingleChildScrollView` ile dikey
/// kaydırılabilir yapıldı (taşma/overflow hatası riski almaktansa).
/// Alt bölümlerin kendisi yatay kaydırıldığı için (farklı eksen) dıştaki
/// dikey kaydırmayla çakışmıyor; dıştaki dikey kaydırma ile üstteki
/// PageView'ın sayfa geçişi arasında olası ince gesture etkileşimleri
/// ileride NotificationListener ile ayrıca ayarlanabilir.
///
/// Modül vurgu rengi: koyu zeytin-hardal sarısı — önceki beş modülden
/// (bordo/zümrüt/indigo/amber/mor) ayrışan altıncı renk.
class FoodProfileCardView extends StatelessWidget {
  final FoodProfileCard card;

  const FoodProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF83752E);
  static const _base = Color(0xFF121108);
  static const _baseEnd = Color(0xFF1A180E);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final placeCount = card.favoriteRestaurants.length;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: SafeArea(
          child: PageAwareScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(placeCount: placeCount),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Favori Yemekler"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: card.favoriteFoods.isEmpty
                      ? const Text(
                          "Henüz favori yemek eklenmedi",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: card.favoriteFoods
                              .map((f) => _FoodChip(food: f))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Favori Mekanlar (${card.favoriteRestaurants.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: card.favoriteRestaurants.isEmpty
                      ? const _EmptyHint(text: "Henüz favori mekan yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.favoriteRestaurants.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _RestaurantMiniCard(
                            restaurant: card.favoriteRestaurants[i],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Düzenli Siparişlerim (${card.recurringOrders.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 108,
                  child: card.recurringOrders.isEmpty
                      ? const _EmptyHint(text: "Henüz düzenli sipariş yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.recurringOrders.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _OrderMiniCard(order: card.recurringOrders[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Kafe Kartlarım (${card.loyaltyCards.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: card.loyaltyCards.isEmpty
                      ? const _EmptyHint(text: "Henüz kayıtlı kafe kartı yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.loyaltyCards.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _LoyaltyMiniCard(
                            loyaltyCard: card.loyaltyCards[i],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int placeCount;
  const _Header({required this.placeCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              color: FoodProfileCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Yemek",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "$placeCount favori mekan",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ),
    );
  }
}

class _FoodChip extends StatelessWidget {
  final FavoriteFood food;
  const _FoodChip({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: FoodProfileCardView.moduleAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FoodProfileCardView.moduleAccent.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        food.cuisine != null ? "${food.name} · ${food.cuisine}" : food.name,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class _RestaurantMiniCard extends StatelessWidget {
  final FavoriteRestaurant restaurant;
  const _RestaurantMiniCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final color = _placeColor(restaurant.name);
    return Container(
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.storefront_outlined, color: color, size: 18),
          const Spacer(),
          Text(
            restaurant.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            restaurant.cuisine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            restaurant.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _OrderMiniCard extends StatelessWidget {
  final RecurringOrder order;
  const _OrderMiniCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = _placeColor(order.restaurantName);
    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.restaurantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.orderDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            order.frequency,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyMiniCard extends StatelessWidget {
  final CafeLoyaltyCard loyaltyCard;
  const _LoyaltyMiniCard({required this.loyaltyCard});

  @override
  Widget build(BuildContext context) {
    final color = _placeColor(loyaltyCard.cafeName);
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.55)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  loyaltyCard.cafeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(
                Icons.local_cafe_outlined,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
          const Spacer(),
          if (loyaltyCard.hasStampProgress) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: loyaltyCard.progress,
                minHeight: 5,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${loyaltyCard.stampsCollected}/${loyaltyCard.stampsRequired} damga",
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ] else if (loyaltyCard.discountPercent != null)
            Text(
              "%${loyaltyCard.discountPercent!.toStringAsFixed(0)} indirim",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (loyaltyCard.rewardDescription != null) ...[
            const SizedBox(height: 4),
            Text(
              loyaltyCard.rewardDescription!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// Mekan/kafe başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _placePalette = <Color>[
  Color(0xFF5A4E1F),
  Color(0xFF3E5A3E),
  Color(0xFF5A3E2E),
  Color(0xFF3E4A5A),
];

Color _placeColor(String name) {
  final index = name.hashCode.abs() % _placePalette.length;
  return _placePalette[index];
}
