import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/hotel_cart.dart';

/// Otel Rezervasyon Sepeti Kartı — Sepet Kartları ailesinin dördüncü üyesi.
///
/// TASARIM NOTU: Diğer sepet kartlarıyla AYNI görsel dili paylaşıyor
/// (koyu gradyan, bölüm başlıkları, dikey "Rezervasyonlarım" listesi +
/// yatay mini kart bölümleri). Bu kartın kendine özgü yanı: sepetteki her
/// rezervasyon henüz ÖDENMEMİŞ ve otel tarafından belirli bir süre
/// tutuluyor — bu yüzden 48 saat içinde dolacak tutma süreleri için üstte
/// bir uyarı banner'ı çıkıyor (bkz. Seyahat/Sağlık/Bilet modüllerindeki
/// alarm banner'ları).
///
/// Modül vurgu rengi: adaçayı yeşili — zümrüt (0xFF1F6F5C), çim yeşili
/// (0xFF5AA33A) ve turkuazdan (0xFF2FA8A3) daha soluk, "konfor/spa" hissi
/// veren ton.
class HotelCartCardView extends StatelessWidget {
  final HotelCartCard card;

  const HotelCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF7FA88A);
  static const _base = Color(0xFF0E1310);
  static const _baseEnd = Color(0xFF151C17);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cart = card.cart;
    final expiring = card.itemsHoldExpiringSoon;

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
                if (expiring.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _HoldBanner(item: expiring.first),
                  ),
                ],
                const SizedBox(height: 20),
                _SectionLabel(text: "Rezervasyonlarım (${cart.items.length})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: cart.items.isEmpty
                      ? const Text("Sepetiniz boş",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Column(
                          children: cart.items
                              .map((item) => _HotelItemRow(item: item))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                    text: "Fiyat Karşılaştırması (${card.priceComparisons.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 172,
                  child: card.priceComparisons.isEmpty
                      ? const _EmptyHint(text: "Karşılaştırma için rezervasyon yok")
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
                _SectionLabel(text: "Sana Özel Otel Önerileri (${card.recommendations.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 168,
                  child: card.recommendations.isEmpty
                      ? const _EmptyHint(text: "Henüz öneri yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.recommendations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _RecommendationMiniCard(hotel: card.recommendations[i]),
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
            Icon(Icons.hotel_outlined, color: HotelCartCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Otel Rezervasyon Sepeti",
                style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(cart.subtotal)} TRY",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 2),
        Text("${cart.items.length} rezervasyon · ödenmemiş toplam",
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
      ],
    );
  }
}

class _HoldBanner extends StatelessWidget {
  final CartItem item;
  const _HoldBanner({required this.item});

  @override
  Widget build(BuildContext context) {
    final hold = item.holdExpiresAt;
    final remaining = hold?.difference(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0A030).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0A030).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFFE0A030), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${item.hotelName}: ${_holdSentence(remaining)}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
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

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _HotelItemRow extends StatelessWidget {
  final CartItem item;
  const _HotelItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(item.hotelName);
    final checkIn = item.checkIn;
    final checkOut = item.checkOut;
    final nights = item.nights;
    final perNight = item.pricePerNight;
    final hold = item.holdExpiresAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.king_bed_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.hotelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  item.roomType.isNotEmpty
                      ? "${item.location} · ${item.roomType}"
                      : item.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                if (checkIn != null && checkOut != null)
                  Text(
                    "${_formatDate(checkIn)} - ${_formatDate(checkOut)}"
                    "${nights != null ? ' · $nights gece' : ''} · ${item.guestCount} misafir",
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.boardType != null)
                      _Chip(text: item.boardType!, color: Colors.white54),
                    if (item.freeCancellation)
                      const _Chip(text: "Ücretsiz İptal", color: Color(0xFF7FD98A)),
                    if (hold != null)
                      _Chip(
                        text: _holdSentence(hold.difference(DateTime.now())),
                        color: const Color(0xFFE0A030),
                      ),
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
              if (perNight != null)
                Text("${_formatMoney(perNight)} / gece",
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              if (item.quantity > 1)
                Text("${item.quantity} oda",
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComparisonMiniCard extends StatelessWidget {
  final HotelComparisonGroup group;
  const _ComparisonMiniCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(group.hotelName);
    final cheapest = group.cheapestOffer;
    final flexible = group.cheapestFreeCancellationOffer;
    final savings = group.savingsPercentVsHighest;
    final showFlexibleLine =
        flexible != null && cheapest != null && flexible.id != cheapest.id;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
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
            Text(group.hotelName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            Text("${group.location} · ${group.nights} gece",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const Spacer(),
            if (cheapest != null) ...[
              Text("${_formatMoney(cheapest.totalPrice)} ${cheapest.currency}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              Text("en ucuz: ${cheapest.platformName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              if (savings != null && savings > 0)
                Text("%${savings.toStringAsFixed(0)} tasarruf",
                    style: const TextStyle(color: Color(0xFF7FD98A), fontSize: 11)),
              if (showFlexibleLine)
                Text(
                  "ücretsiz iptalli: ${_formatMoney(flexible.totalPrice)} (${flexible.platformName})",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
            ] else
              const Text("Müsait teklif yok",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Text("${group.offers.length} platformda",
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151C17),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => HotelComparisonSheet(group: group),
    );
  }
}

/// Karşılaştırma mini kartına dokununca açılan tüm platform tekliflerinin
/// listesi (bkz. market_cart_card_view.dart'taki PriceComparisonSheet
/// presedanı).
class HotelComparisonSheet extends StatelessWidget {
  final HotelComparisonGroup group;
  const HotelComparisonSheet({super.key, required this.group});

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
                  child: Text(group.hotelName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(
              "${group.roomType} · ${_formatDate(group.checkIn)} - ${_formatDate(group.checkOut)} · ${group.nights} gece",
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...offers.map((o) => _OfferRow(offer: o, isCheapest: o.id == cheapestId)),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final PlatformOffer offer;
  final bool isCheapest;
  const _OfferRow({required this.offer, required this.isCheapest});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: offer.isAvailable ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(offer.platformName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      if (isCheapest && offer.isAvailable) ...[
                        const SizedBox(width: 8),
                        const _Chip(text: "En Ucuz", color: Color(0xFF7FD98A)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (offer.freeCancellation)
                        const _Chip(text: "Ücretsiz İptal", color: Color(0xFF7FD98A))
                      else
                        const _Chip(text: "İptal Edilemez", color: Colors.white38),
                      if (offer.breakfastIncluded)
                        const _Chip(text: "Kahvaltı Dahil", color: Colors.white54),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!offer.isAvailable)
              const Text("Müsait değil",
                  style: TextStyle(color: Colors.white38, fontSize: 12))
            else
              Text("${_formatMoney(offer.totalPrice)} ${offer.currency}",
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
  final RecommendedHotel hotel;
  const _RecommendationMiniCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(hotel.hotelName);

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
          _Chip(text: hotel.reason.label, color: color),
          const SizedBox(height: 8),
          Text(hotel.hotelName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          Text(hotel.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const Spacer(),
          Text("${_formatMoney(hotel.pricePerNight)} ${hotel.currency} / gece",
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          if (hotel.rating != null)
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Color(0xFFE0B23A)),
                const SizedBox(width: 3),
                Text(hotel.rating!.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
        ],
      ),
    );
  }
}

// Otel adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF2E4A3A),
  Color(0xFF3E4A5A),
  Color(0xFF4A3E2E),
  Color(0xFF4A2E45),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

String _formatRemaining(Duration d) {
  if (d.inDays >= 1) return "${d.inDays} gün";
  if (d.inHours >= 1) return "${d.inHours} saat";
  return "${d.inMinutes} dk";
}

/// Tutma süresini tek bir cümle olarak anlatır; süre dolmuşsa bunu
/// açıkça söyler ("süre doldu kaldı" gibi bozuk bir cümle çıkmasın diye).
String _holdSentence(Duration? d) {
  if (d == null) return "";
  if (d.isNegative) return "tutma süresi doldu";
  return "ödeme için ${_formatRemaining(d)} kaldı";
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
