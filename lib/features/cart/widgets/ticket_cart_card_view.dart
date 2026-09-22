import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/travel.dart';
import '../../../models/ticket_cart.dart';

/// Bilet Sepeti Kartı — Sepet Kartları ailesinin üçüncü üyesi.
///
/// TASARIM NOTU: Market/İkinci El Sepeti Kartlarıyla AYNI görsel dili
/// paylaşıyor (koyu gradyan, bölüm başlıkları, dikey "Sepetim" listesi +
/// yatay mini kart bölümleri). Farkı: her bilet kaleminde bir koltuk
/// durumu var (seçilmiş/seçilmemiş) ve "öneri" yerine aynı güzergâh için
/// firma/saat bazlı ALTERNATİFLER gösteriliyor.
///
/// Modül vurgu rengi: gökyüzü mavisi — Kargo modülünün lojistik
/// mavisinden (0xFF2E7BA6) ve Market Sepeti'nin kobaltından (0xFF3D6FD1)
/// ayrışan, daha açık/"uçuş" hissi veren ton.
class TicketCartCardView extends StatelessWidget {
  final TicketCartCard card;

  const TicketCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF2E93B8);
  static const _base = Color(0xFF0C1216);
  static const _baseEnd = Color(0xFF141C22);

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
                _SectionLabel(text: "Biletlerim (${cart.itemCount})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: cart.items.isEmpty
                      ? const Text("Sepetiniz boş",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Column(
                          children: cart.items
                              .map((item) => _TicketItemRow(item: item))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Alternatif Seçenekler (${card.alternatives.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: card.alternatives.isEmpty
                      ? const _EmptyHint(text: "Alternatif bulunamadı")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.alternatives.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) =>
                              _AlternativeGroupMiniCard(group: card.alternatives[i]),
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
            Icon(Icons.confirmation_num_outlined,
                color: TicketCartCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Bilet Sepeti", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(cart.subtotal)} TRY",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 2),
        Text("${cart.itemCount} bilet · ara toplam",
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

class _TicketItemRow extends StatelessWidget {
  final CartItem item;
  const _TicketItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(item.company);
    final seat = item.selectedSeat;
    final departure = item.departureDateTime;

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
            child: Icon(_iconFor(item.transportType), color: color, size: 20),
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
                  item.origin.isNotEmpty && item.destination.isNotEmpty
                      ? "${item.company} · ${item.origin} → ${item.destination}"
                      : item.company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                if (departure != null)
                  Text(_formatDateTime(departure),
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 4),
                _SeatStatus(seat: seat, availableCount: item.availableSeats.length),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text("${_formatMoney(item.lineTotal)} ${item.currency}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SeatStatus extends StatelessWidget {
  final String? seat;
  final int availableCount;
  const _SeatStatus({required this.seat, required this.availableCount});

  @override
  Widget build(BuildContext context) {
    if (seat != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF7FD98A).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_seat_outlined, size: 12, color: Color(0xFF7FD98A)),
            const SizedBox(width: 4),
            Text("Koltuk $seat",
                style: const TextStyle(
                    color: Color(0xFF7FD98A), fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE0A030).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        availableCount > 0 ? "Koltuk seçilmedi · $availableCount uygun" : "Koltuk seçilmedi",
        style: const TextStyle(
            color: Color(0xFFE0A030), fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AlternativeGroupMiniCard extends StatelessWidget {
  final AlternativeRouteGroup group;
  const _AlternativeGroupMiniCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor("${group.origin}${group.destination}");
    final cheapest = group.cheapestOption;
    final earliest = group.earliestOption;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 205,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${group.origin} → ${group.destination}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            if (cheapest != null) ...[
              Text("${_formatMoney(cheapest.price)} ${cheapest.currency}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              Text("en ucuz: ${cheapest.company}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
            if (earliest != null)
              Text("en erken: ${_formatTime(earliest.departureDateTime)} (${earliest.company})",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 4),
            Text("${group.options.length} seçenek",
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141C22),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AlternativeRouteSheet(group: group),
    );
  }
}

/// Alternatif grup mini kartına dokununca açılan tüm seçeneklerin listesi
/// (bkz. market_cart_card_view.dart'taki PriceComparisonSheet presedanı).
class AlternativeRouteSheet extends StatelessWidget {
  final AlternativeRouteGroup group;
  const AlternativeRouteSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final options = group.sortedByDeparture;
    final cheapestId = group.cheapestOption?.id;

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
                  child: Text("${group.origin} → ${group.destination}",
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
            ...options.map((o) => _OptionRow(option: o, isCheapest: o.id == cheapestId)),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final AlternativeTicketOption option;
  final bool isCheapest;
  const _OptionRow({required this.option, required this.isCheapest});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(_iconFor(option.transportType), size: 18, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(option.company,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    if (isCheapest) ...[
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
                Text(_formatDateTime(option.departureDateTime),
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                if (option.seatsAvailable != null)
                  Text("${option.seatsAvailable} koltuk uygun",
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text("${_formatMoney(option.price)} ${option.currency}",
              style: TextStyle(
                  color: isCheapest ? const Color(0xFF7FD98A) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

IconData _iconFor(TransportType type) => switch (type) {
      TransportType.flight => Icons.flight_takeoff,
      TransportType.bus => Icons.directions_bus_outlined,
      TransportType.train => Icons.train_outlined,
      TransportType.ferry => Icons.directions_boat_outlined,
    };

// Firma/güzergah adı başına sabit, elle seçilmiş uyumlu bir palet (bkz.
// diğer modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF1F5A6E),
  Color(0xFF3E4A5A),
  Color(0xFF5A4A1F),
  Color(0xFF3E5A4A),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}

String _formatDateTime(DateTime d) {
  final date =
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  final time =
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  return "$date · $time";
}

String _formatTime(DateTime d) =>
    "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
