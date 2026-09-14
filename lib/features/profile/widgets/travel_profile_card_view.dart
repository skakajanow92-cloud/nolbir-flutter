import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/travel.dart';

/// Seyahat Profili — dördüncü profil modülü.
/// Modül vurgu rengi: sıcak amber-turuncu — önceki modüllerin (bordo,
/// zümrüt, indigo) koyu/soğuk tonlarından bilinçli olarak ayrışıyor,
/// "ufuk/yolculuk" hissi veriyor.
class TravelProfileCardView extends StatelessWidget {
  final TravelProfileCard card;

  const TravelProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFFA85A2A);
  static const _base = Color(0xFF14100D);
  static const _baseEnd = Color(0xFF1C1712);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final upcoming = card.upcoming;
    final past = card.past;
    final alertTicket = card.nextAlertTicket;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.explore_outlined,
                        color: moduleAccent, size: 20),
                    const SizedBox(width: 8),
                    const Text("Seyahat",
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                  ],
                ),
              ),
              if (alertTicket != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AlertBanner(ticket: alertTicket),
                ),
              ],
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Yaklaşan Yolculuklar (${upcoming.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: upcoming.isEmpty
                    ? const _EmptyHint(text: "Yaklaşan yolculuk yok")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: upcoming.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _TicketMiniCard(ticket: upcoming[i], muted: false),
                      ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Geçmiş Yolculuklar (${past.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: past.isEmpty
                    ? const _EmptyHint(text: "Geçmiş yolculuk yok")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: past.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _TicketMiniCard(ticket: past[i], muted: true),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final TravelTicket ticket;
  const _AlertBanner({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final days = ticket.departureDateTime.difference(DateTime.now()).inDays;
    final whenText = days <= 0 ? "Bugün" : "$days gün sonra";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TravelProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: TravelProfileCardView.moduleAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined,
              color: TravelProfileCardView.moduleAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$whenText: ${ticket.company} · ${ticket.origin} → ${ticket.destination}",
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

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      ),
    );
  }
}

class _TicketMiniCard extends StatelessWidget {
  final TravelTicket ticket;
  final bool muted;
  const _TicketMiniCard({required this.ticket, required this.muted});

  @override
  Widget build(BuildContext context) {
    final color = _companyColor(ticket.company);
    final opacity = muted ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(16),
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
                Icon(_iconFor(ticket.transportType), color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "${ticket.origin} → ${ticket.destination}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(_formatDateTime(ticket.departureDateTime),
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            if (ticket.seatNumber != null)
              Text("Koltuk ${ticket.seatNumber}",
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
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

// Şirket başına sabit, elle seçilmiş uyumlu bir palet (bkz. wallet ve
// insurance modüllerindeki aynı yaklaşım).
const _companyPalette = <Color>[
  Color(0xFF5A3E1F),
  Color(0xFF3E4A5A),
  Color(0xFF5A2E3E),
  Color(0xFF3E5A45),
];

Color _companyColor(String company) {
  final index = company.hashCode.abs() % _companyPalette.length;
  return _companyPalette[index];
}

String _formatDateTime(DateTime d) {
  final date =
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  final time =
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  return "$date · $time";
}
