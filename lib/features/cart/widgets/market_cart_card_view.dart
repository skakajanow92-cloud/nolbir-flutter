import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/cart.dart';
import '../../../models/market_cart.dart';

/// Market Sepeti Kartı — Sepet Kartları ailesinin ilk üyesi.
///
/// TASARIM NOTU: Profil modülleriyle AYNI görsel dili paylaşıyor (koyu
/// gradyan zemin, bölüm başlıkları, mini kartlar) ama farklı bir amaca
/// hizmet ediyor: profil modülleri kullanıcının SAHİP OLDUĞU varlıkları
/// gösterirken, sepet kartları SATIN ALMAYA HAZIRLANDIĞI şeyleri
/// gösteriyor. "Sepetim" bölümü bilerek dikey liste — bir alışveriş
/// sepeti doğal olarak yatay kaydırmalı mini kartlardan çok dikey bir
/// döküm gibi okunur; diğer bölümler (karşılaştırma, öneriler) yatay
/// kaydırmalı kalmaya devam ediyor.
///
/// Modül vurgu rengi: canlı kobalt mavisi — önceki tüm profil
/// modüllerinden daha doygun/parlak, "e-ticaret/market" hissi için
/// bilerek seçildi.
class MarketCartCardView extends StatelessWidget {
  final MarketCartCard card;

  const MarketCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF3D6FD1);
  static const _base = Color(0xFF0D1018);
  static const _baseEnd = Color(0xFF141A26);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cart = card.cart;

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
                  child: _Header(cart: cart),
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: "Sepetim (${cart.itemCount} ürün)"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: cart.items.isEmpty
                      ? const Text("Sepetiniz boş",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Column(
                          children: cart.items
                              .map((item) => _CartItemRow(item: item))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                    text: "Fiyat Karşılaştırması (${card.priceComparisons.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 148,
                  child: card.priceComparisons.isEmpty
                      ? const _EmptyHint(text: "Karşılaştırma için ürün yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.priceComparisons.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) =>
                              _ComparisonMiniCard(group: card.priceComparisons[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Sana Özel Öneriler (${card.recommendations.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 158,
                  child: card.recommendations.isEmpty
                      ? const _EmptyHint(text: "Henüz öneri yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.recommendations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _RecommendationMiniCard(product: card.recommendations[i]),
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
  const _Header({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.shopping_cart_outlined,
                color: MarketCartCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Market Sepeti", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(cart.subtotal)} TRY",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 2),
        Text("${cart.itemCount} ürün · ara toplam",
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
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

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(item.marketName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.shopping_bag_outlined, color: color, size: 20),
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
                const SizedBox(height: 2),
                Text(
                  item.unitLabel != null
                      ? "${item.marketName} · ${item.unitLabel}"
                      : item.marketName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
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

class _ComparisonMiniCard extends StatelessWidget {
  final PriceComparisonGroup group;
  const _ComparisonMiniCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(group.productName);
    final cheapest = group.cheapestOffer;
    final savings = group.savingsPercentVsHighest;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            if (group.unitLabel != null)
              Text(group.unitLabel!,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const Spacer(),
            if (cheapest != null) ...[
              Text("${_formatMoney(cheapest.price)} ${cheapest.currency}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              Text("en ucuz: ${cheapest.marketName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              if (savings != null && savings > 0)
                Text("%${savings.toStringAsFixed(0)} tasarruf",
                    style: const TextStyle(color: Color(0xFF7FD98A), fontSize: 11)),
            ] else
              const Text("Stokta teklif yok",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Text("${group.offers.length} markette",
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141A26),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PriceComparisonSheet(group: group),
    );
  }
}

/// Karşılaştırma mini kartına dokununca açılan tüm tekliflerin listesi
/// (bkz. diğer modüllerdeki detay sheet presedanı).
class PriceComparisonSheet extends StatelessWidget {
  final PriceComparisonGroup group;
  const PriceComparisonSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final offers = group.sortedByPrice;
    final cheapestId = group.cheapestOffer?.id;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(group.productName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            if (group.unitLabel != null)
              Text(group.unitLabel!,
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 16),
            ...offers.map((o) => _OfferRow(offer: o, isCheapest: o.id == cheapestId)),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final MarketOffer offer;
  final bool isCheapest;
  const _OfferRow({required this.offer, required this.isCheapest});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: offer.inStock ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(offer.marketName,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  if (isCheapest && offer.inStock) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FD98A).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("En Ucuz",
                          style: TextStyle(
                              color: Color(0xFF7FD98A),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
            if (!offer.inStock)
              const Text("Stokta yok",
                  style: TextStyle(color: Colors.white38, fontSize: 12))
            else
              Text("${_formatMoney(offer.price)} ${offer.currency}",
                  style: TextStyle(
                      color: isCheapest ? const Color(0xFF7FD98A) : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _RecommendationMiniCard extends StatelessWidget {
  final RecommendedProduct product;
  const _RecommendationMiniCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(product.marketName);

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(product.reason.label,
                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Text(product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text("${_formatMoney(product.price)} ${product.currency}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(product.marketName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

// Market/ürün adı başına sabit, elle seçilmiş uyumlu bir palet (bkz.
// diğer modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF2E3E5A),
  Color(0xFF5A3E2E),
  Color(0xFF2E5A3E),
  Color(0xFF4A2E5A),
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
