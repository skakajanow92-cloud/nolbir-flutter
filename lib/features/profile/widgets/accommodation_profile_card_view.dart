import 'package:flutter/material.dart';
import '../../../models/feed_card.dart';
import '../../../models/accommodation.dart';

/// Konaklama Profili — beşinci profil modülü.
/// Modül vurgu rengi: koyu gül-mor (mauve) — önceki dört modülden
/// (bordo, zümrüt, indigo, amber) ayrışan, "konfor/misafirperverlik" hissi.
class AccommodationProfileCardView extends StatelessWidget {
  final AccommodationProfileCard card;

  const AccommodationProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF6B4258);
  static const _base = Color(0xFF120F13);
  static const _baseEnd = Color(0xFF1B1620);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final upcoming = card.upcoming;
    final past = card.past;
    final alert = card.nextAlertReservation;

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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.hotel_outlined, color: moduleAccent, size: 20),
                    SizedBox(width: 8),
                    Text("Konaklama",
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                  ],
                ),
              ),
              if (alert != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AlertBanner(reservation: alert),
                ),
              ],
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Yaklaşan Rezervasyonlar (${upcoming.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 158,
                child: upcoming.isEmpty
                    ? const _EmptyHint(text: "Yaklaşan rezervasyon yok")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: upcoming.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _ReservationMiniCard(reservation: upcoming[i], muted: false),
                      ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Geçmiş Rezervasyonlar (${past.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 158,
                child: past.isEmpty
                    ? const _EmptyHint(text: "Geçmiş rezervasyon yok")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: past.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _ReservationMiniCard(reservation: past[i], muted: true),
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
  final AccommodationReservation reservation;
  const _AlertBanner({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final days = reservation.checkIn.difference(DateTime.now()).inDays;
    final whenText = days <= 0 ? "Bugün" : "$days gün sonra";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AccommodationProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AccommodationProfileCardView.moduleAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined,
              color: AccommodationProfileCardView.moduleAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$whenText: ${reservation.hotelName} · ${reservation.location}",
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

class _ReservationMiniCard extends StatelessWidget {
  final AccommodationReservation reservation;
  final bool muted;
  const _ReservationMiniCard({required this.reservation, required this.muted});

  @override
  Widget build(BuildContext context) {
    final color = _hotelColor(reservation.hotelName);

    return Opacity(
      opacity: muted ? 0.5 : 1.0,
      child: Container(
        width: 200,
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
                Icon(Icons.king_bed_outlined, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reservation.hotelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(reservation.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              "${_formatDate(reservation.checkIn)} - ${_formatDate(reservation.checkOut)}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text("${reservation.nights} gece · ${reservation.guestCount} misafir",
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const Spacer(),
            Text(
              "${_formatMoney(reservation.price)} ${reservation.currency}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// Otel başına sabit, elle seçilmiş uyumlu bir palet (bkz. wallet/insurance/
// travel modüllerindeki aynı yaklaşım).
const _hotelPalette = <Color>[
  Color(0xFF5A2E45),
  Color(0xFF3E4A5A),
  Color(0xFF5A4E33),
  Color(0xFF3E5A4A),
];

Color _hotelColor(String hotelName) {
  final index = hotelName.hashCode.abs() % _hotelPalette.length;
  return _hotelPalette[index];
}

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
