import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/second_hand_cart.dart';

/// İkinci El Sepeti Kartı — Sepet Kartları ailesinin ikinci üyesi.
///
/// TASARIM NOTU: Market Sepeti Kartı ile AYNI görsel dili paylaşıyor
/// (koyu gradyan, bölüm başlıkları, dikey "Sepetim" listesi + yatay
/// mini kart bölümleri) ama satıcı kavramı kasıtlı olarak farklı
/// vurgulanıyor: her satır bireysel satıcının adını, puanını ve
/// ürünün durumunu (Sıfır/Az Kullanılmış/İkinci El) gösteriyor —
/// kurumsal bir market rozeti değil.
///
/// Modül vurgu rengi: toz lila — "vintage/ikinci el" hissi veren,
/// Market Sepeti'nin kobalt mavisinden (0xFF3D6FD1) ve önceki mor
/// tonlarından (menekşe-mor, mor-gri sunucu, fuşya, mauve) ayrışan
/// daha nötr/toz bir ton.
class SecondHandCartCardView extends StatelessWidget {
  final SecondHandCartCard card;

  const SecondHandCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF6E6280);
  static const _base = Color(0xFF120F16);
  static const _baseEnd = Color(0xFF1A1620);

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
                _SectionLabel(text: "Benzer İlanlarla Karşılaştır (${card.similarListings.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 160,
                  child: card.similarListings.isEmpty
                      ? const _EmptyHint(text: "Karşılaştırma için ilan yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.similarListings.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) =>
                              _ListingGroupMiniCard(group: card.similarListings[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Sana Özel İlan Önerileri (${card.recommendations.length})"),
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
                              _RecommendationMiniCard(listing: card.recommendations[i]),
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
            Icon(Icons.recycling_outlined,
                color: SecondHandCartCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("İkinci El Sepeti", style: TextStyle(color: Colors.white54, fontSize: 14)),
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

class _ConditionBadge extends StatelessWidget {
  final ItemCondition condition;
  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    final color = switch (condition) {
      ItemCondition.brandNew => const Color(0xFF7FD98A),
      ItemCondition.likeNew => const Color(0xFFB8D97F),
      ItemCondition.used => Colors.white54,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(condition.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(item.sellerName);

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
            child: Icon(Icons.storefront_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    _ConditionBadge(condition: item.condition),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(item.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    if (item.sellerRating != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star, size: 11, color: Color(0xFFE0B23A)),
                      Text(item.sellerRating!.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                    if (item.sellerLocation != null) ...[
                      const SizedBox(width: 6),
                      Text("· ${item.sellerLocation}",
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ],
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

class _ListingGroupMiniCard extends StatelessWidget {
  final SimilarListingGroup group;
  const _ListingGroupMiniCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(group.listingTitle);
    final cheapest = group.cheapestOffer;

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
            Text(group.listingTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            if (cheapest != null) ...[
              Text("${_formatMoney(cheapest.price)} ${cheapest.currency}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              Text("en ucuz: ${cheapest.sellerName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              _ConditionBadge(condition: cheapest.condition),
            ] else
              const Text("Aktif ilan yok",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Text("${group.offers.length} ilan",
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1620),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SimilarListingSheet(group: group),
    );
  }
}

/// İlan grubu mini kartına dokununca açılan tüm satıcı tekliflerinin
/// listesi (bkz. market_cart_card_view.dart'taki PriceComparisonSheet
/// presedanı).
class SimilarListingSheet extends StatelessWidget {
  final SimilarListingGroup group;
  const SimilarListingSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final offers = group.sortedByPrice;
    final cheapestId = group.cheapestOffer?.id;
    final highestRatedId = group.highestRatedOffer?.id;

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
                  child: Text(group.listingTitle,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...offers.map((o) => _OfferRow(
                  offer: o,
                  isCheapest: o.id == cheapestId,
                  isHighestRated: o.id == highestRatedId,
                )),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final IndividualSellerOffer offer;
  final bool isCheapest;
  final bool isHighestRated;
  const _OfferRow({
    required this.offer,
    required this.isCheapest,
    required this.isHighestRated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(offer.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    if (offer.sellerRating != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star, size: 12, color: Color(0xFFE0B23A)),
                      Text(offer.sellerRating!.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _ConditionBadge(condition: offer.condition),
                    if (offer.location != null) ...[
                      const SizedBox(width: 6),
                      Text(offer.location!,
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ],
                ),
                if (isCheapest || isHighestRated) ...[
                  const SizedBox(height: 4),
                  Text(
                    isCheapest && isHighestRated
                        ? "En ucuz · En yüksek puanlı"
                        : (isCheapest ? "En ucuz" : "En yüksek puanlı"),
                    style: const TextStyle(
                        color: Color(0xFF7FD98A), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          Text("${_formatMoney(offer.price)} ${offer.currency}",
              style: TextStyle(
                  color: isCheapest ? const Color(0xFF7FD98A) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RecommendationMiniCard extends StatelessWidget {
  final RecommendedListing listing;
  const _RecommendationMiniCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(listing.sellerName);

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(listing.reason.label,
                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Text(listing.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text("${_formatMoney(listing.price)} ${listing.currency}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(listing.sellerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 2),
          _ConditionBadge(condition: listing.condition),
        ],
      ),
    );
  }
}

// Satıcı/ilan adı başına sabit, elle seçilmiş uyumlu bir palet (bkz.
// diğer modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF4A3E5A),
  Color(0xFF3E4A5A),
  Color(0xFF5A3E45),
  Color(0xFF4A4A3E),
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
