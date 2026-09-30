import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/food_cart.dart';

/// Yemek Sepeti Kartı — Sepet Kartları ailesinin beşinci üyesi.
///
/// TASARIM NOTU: Diğer sepet kartlarıyla AYNI görsel dili paylaşıyor.
/// Market Sepeti'nden farkı: burada "aynı ürünün farklı satıcılardaki
/// fiyatı" kıyaslaması anlamsız (bir yemek farklı restoranlarda aynı
/// ürün sayılmaz) — bu yüzden fiyat karşılaştırma bölümü YOK, bunun
/// yerine iki zenginleştirme bölümü var: yakındaki işletmeler ve
/// yüksek puanlı ürün önerileri. "Siparişim" bölümü işletmeye göre
/// gruplanıyor çünkü sepet market sepetindeki gibi birden fazla
/// işletmeden oluşabilir.
///
/// Modül vurgu rengi: mercan/kiremit kırmızısı — Bahis modülünün koyu
/// bordosundan (0xFF8C2A2A) ve Tanışma modülünün gülünden (0xFFB23A56)
/// ayrışan, "iştah açıcı" bir ton.
class FoodCartCardView extends StatelessWidget {
  final FoodCartCard card;

  const FoodCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFFC94F45);
  static const _base = Color(0xFF140F0E);
  static const _baseEnd = Color(0xFF1E1614);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cart = card.cart;
    final grouped = card.itemsByRestaurant;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(cart: cart, restaurantCount: grouped.length),
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: "Siparişim (${cart.itemCount} ürün)"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: cart.items.isEmpty
                      ? const Text("Sepetiniz boş",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Column(
                          children: grouped.entries
                              .map((e) => _RestaurantGroup(
                                    restaurantName: e.key,
                                    items: e.value,
                                  ))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Yakınımdaki İşletmeler (${card.nearbyBusinesses.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 138,
                  child: card.nearbyBusinesses.isEmpty
                      ? const _EmptyHint(text: "Yakında işletme bulunamadı")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.nearbyBusinesses.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _BusinessMiniCard(business: card.nearbyBusinesses[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                    text: "Yüksek Puanlı Ürün Önerileri (${card.highRatedDishes.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 148,
                  child: card.highRatedDishes.isEmpty
                      ? const _EmptyHint(text: "Henüz öneri yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.highRatedDishes.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _DishMiniCard(dish: card.highRatedDishes[i]),
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
  final Cart cart;
  final int restaurantCount;
  const _Header({required this.cart, required this.restaurantCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.restaurant_outlined,
                color: FoodCartCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Yemek Sepeti", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(cart.subtotal)} TRY",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 2),
        Text(
          restaurantCount > 1
              ? "${cart.itemCount} ürün · $restaurantCount işletmeden"
              : "${cart.itemCount} ürün",
          style: const TextStyle(color: Colors.white38, fontSize: 13),
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
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
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
        alignment: Alignment.topLeft,
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      ),
    );
  }
}

class _RestaurantGroup extends StatelessWidget {
  final String restaurantName;
  final List<CartItem> items;
  const _RestaurantGroup({required this.restaurantName, required this.items});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(restaurantName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, color: color, size: 15),
              const SizedBox(width: 6),
              Text(restaurantName,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _FoodItemRow(item: item, color: color)),
        ],
      ),
    );
  }
}

class _FoodItemRow extends StatelessWidget {
  final CartItem item;
  final Color color;
  const _FoodItemRow({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.lunch_dining_outlined, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                if (item.category != null)
                  Text(item.category!,
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                if (item.specialInstructions != null)
                  Text("Not: ${item.specialInstructions}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${_formatMoney(item.lineTotal)} ${item.currency}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              if (item.quantity > 1)
                Text("${item.quantity} adet",
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessMiniCard extends StatelessWidget {
  final NearbyBusiness business;
  const _BusinessMiniCard({required this.business});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(business.name);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(business.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          Text(business.cuisineType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Color(0xFFE0B23A)),
              const SizedBox(width: 3),
              Text(business.rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(width: 8),
              Icon(Icons.place_outlined, size: 12, color: color),
              const SizedBox(width: 3),
              Text("${business.distanceKm.toStringAsFixed(1)} km",
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text("${business.estimatedDeliveryMinutes} dk teslimat",
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          if (business.minOrderAmount != null)
            Text("min. ${_formatMoney(business.minOrderAmount!)} TRY",
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class _DishMiniCard extends StatelessWidget {
  final HighRatedDish dish;
  const _DishMiniCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(dish.businessName);

    return Container(
      width: 172,
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
              const Icon(Icons.star, size: 13, color: Color(0xFFE0B23A)),
              const SizedBox(width: 3),
              Text(dish.rating.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Color(0xFFE0B23A), fontSize: 12, fontWeight: FontWeight.w600)),
              if (dish.ratingCount != null) ...[
                const SizedBox(width: 4),
                Text("(${dish.ratingCount})",
                    style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(dish.dishName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text("${_formatMoney(dish.price)} ${dish.currency}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(dish.businessName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// İşletme adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF5A2E2E),
  Color(0xFF5A4A2E),
  Color(0xFF3E4A5A),
  Color(0xFF4A5A3E),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
