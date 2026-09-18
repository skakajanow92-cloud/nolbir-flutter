import 'package:flutter/material.dart';
import 'package:nolbir/core/widgets/page_aware_scroll_view.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/cargo.dart';

/// Kargo Profili — on beşinci profil modülü.
///
/// TASARIM NOTU: Devam eden gönderi mini kartına dokununca — Insurance/
/// Channels/Estate modüllerindeki detay sheet presedanıyla aynı mantıkla
/// — tam takip zaman çizelgesi açılıyor (`ShipmentTrackingSheet`).
/// Konum bilgisi kartta AYRI bir alan değil, `Shipment.latestEvent`den
/// türetilerek gösteriliyor.
///
/// Modül vurgu rengi: lojistik mavisi — Sigorta modülünün indigosundan
/// (0xFF3A4E7A) ve Kariyer modülünün grafitinden (0xFF35404F) ayrışan,
/// daha canlı/soğuk bir mavi.
class CargoProfileCardView extends StatelessWidget {
  final CargoProfileCard card;

  const CargoProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF2E7BA6);
  static const _base = Color(0xFF0D1115);
  static const _baseEnd = Color(0xFF151B21);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final active = card.activeShipments;
    final past = card.pastShipments;

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
                  child: _Header(activeCount: active.length),
                ),
                const SizedBox(height: 22),
                _SectionLabel(text: "Devam Eden Gönderiler (${active.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 176,
                  child: active.isEmpty
                      ? const _EmptyHint(text: "Devam eden gönderi yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: active.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) => _ShipmentMiniCard(
                            shipment: active[i],
                            muted: false,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Geçmiş Gönderiler (${past.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 176,
                  child: past.isEmpty
                      ? const _EmptyHint(text: "Geçmiş gönderi yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: past.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) =>
                              _ShipmentMiniCard(shipment: past[i], muted: true),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text:
                      "Favori Kargo Firmalarım (${card.favoriteCompanies.length})",
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: card.favoriteCompanies.isEmpty
                      ? const Text(
                          "Henüz favori firma eklenmedi",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: card.favoriteCompanies
                              .map((c) => _CompanyChip(company: c))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Favori Kuryelerim (${card.favoriteCouriers.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 118,
                  child: card.favoriteCouriers.isEmpty
                      ? const _EmptyHint(text: "Henüz favori kurye eklenmedi")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.favoriteCouriers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _CourierMiniCard(
                            courier: card.favoriteCouriers[i],
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
  final int activeCount;
  const _Header({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              color: CargoProfileCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Kargo",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "$activeCount gönderi yolda",
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
        alignment: Alignment.topLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ),
    );
  }
}

class _ShipmentMiniCard extends StatelessWidget {
  final Shipment shipment;
  final bool muted;
  const _ShipmentMiniCard({required this.shipment, required this.muted});

  @override
  Widget build(BuildContext context) {
    final color = _companyColor(shipment.company);
    final latest = shipment.latestEvent;

    return Opacity(
      opacity: muted ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: () => _openDetail(context),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: color, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      shipment.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _DirectionBadge(isOutgoing: shipment.isOutgoing),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                shipment.contentDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${shipment.originCity} → ${shipment.destinationCity}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const Spacer(),
              if (latest != null) ...[
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 12, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        latest.locationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Text(
                shipment.status.label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151B21),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShipmentTrackingSheet(shipment: shipment),
    );
  }
}

class _DirectionBadge extends StatelessWidget {
  final bool isOutgoing;
  const _DirectionBadge({required this.isOutgoing});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isOutgoing ? Icons.north_east : Icons.south_west,
      size: 14,
      color: Colors.white38,
    );
  }
}

class _CompanyChip extends StatelessWidget {
  final FavoriteCargoCompany company;
  const _CompanyChip({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CargoProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CargoProfileCardView.moduleAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            company.name,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(width: 6),
          Icon(Icons.star, size: 12, color: const Color(0xFFE0B23A)),
          const SizedBox(width: 2),
          Text(
            company.rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CourierMiniCard extends StatelessWidget {
  final FavoriteCourier courier;
  const _CourierMiniCard({required this.courier});

  @override
  Widget build(BuildContext context) {
    final color = _companyColor(courier.name);

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
          Row(
            children: [
              Icon(Icons.badge_outlined, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  courier.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            courier.company,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFE0B23A), size: 13),
              const SizedBox(width: 3),
              Text(
                courier.rating.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "${courier.timesUsed} kez kullanıldı",
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

/// Gönderi mini kartına dokununca açılan tam takip zaman çizelgesi
/// (bkz. InsuranceProfileCardView/ChannelsProfileCardView'daki detay
/// sheet presedanı).
class ShipmentTrackingSheet extends StatelessWidget {
  final Shipment shipment;
  const ShipmentTrackingSheet({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    final events = shipment.sortedEvents;

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
                  child: Text(
                    shipment.contentDescription,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(
              "${shipment.company} · ${shipment.trackingNumber}",
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              shipment.isOutgoing
                  ? "Alıcı: ${shipment.receiverName}"
                  : "Gönderen: ${shipment.senderName}",
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Text(
              "Takip Geçmişi",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Text(
                "Henüz takip kaydı yok",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              )
            else
              ...List.generate(events.length, (i) {
                final isLast = i == events.length - 1;
                return _TimelineRow(event: events[i], isLatest: isLast);
              }),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TrackingEvent event;
  final bool isLatest;
  const _TimelineRow({required this.event, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    final color = isLatest ? CargoProfileCardView.moduleAccent : Colors.white24;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              Container(width: 2, height: 30, color: Colors.white12),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.status.label,
                  style: TextStyle(
                    color: isLatest ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: isLatest ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.locationLabel,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  _formatDateTime(event.timestamp),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Firma/kurye adı başına sabit, elle seçilmiş uyumlu bir palet (bkz.
// diğer modüllerdeki aynı yaklaşım).
const _companyPalette = <Color>[
  Color(0xFF1F4E63),
  Color(0xFF3E4A5A),
  Color(0xFF2E4A3E),
  Color(0xFF3E3E5A),
];

Color _companyColor(String seed) {
  final index = seed.hashCode.abs() % _companyPalette.length;
  return _companyPalette[index];
}

String _formatDateTime(DateTime d) {
  final date =
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  final time =
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  return "$date · $time";
}
