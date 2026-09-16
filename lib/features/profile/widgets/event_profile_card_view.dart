import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/event.dart';

/// Eğlence & Bilet Profili — on ikinci profil modülü.
///
/// TASARIM NOTU: Üç alt bölümü var (favori etkinlikler, gelecek biletler,
/// geçmiş biletler) — Food/Career/Health modüllerindeki aynı gerekçeyle
/// dikey `SingleChildScrollView` kullanıldı.
///
/// Gelecek biletlerde bilet kartı, etkinliğe kalan süreyi VE biletin ne
/// kadar önceden alındığını gösteriyor — bu modülün asıl senaryosu
/// "aylar öncesinden alınmış, tarihi henüz gelmemiş bilet" (bkz.
/// event.dart'taki purchaseDate/eventDateTime ayrımı).
///
/// Modül vurgu rengi: canlı magenta-fuşya — Tanışma modülünün
/// gül-kırmızısından (0xFFB23A56) ayrışan, "sahne ışığı" hissi.
class EventProfileCardView extends StatelessWidget {
  final EventProfileCard card;

  const EventProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFFA33A8C);
  static const _base = Color(0xFF140E13);
  static const _baseEnd = Color(0xFF1D141B);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final upcoming = card.upcoming;
    final past = card.past;
    final alert = card.nextAlertTicket;

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
                  child: _Header(upcomingCount: upcoming.length),
                ),
                if (alert != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _AlertBanner(ticket: alert),
                  ),
                ],
                const SizedBox(height: 22),
                _SectionLabel(
                  text: "Favori Etkinliklerim (${card.favorites.length})",
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: card.favorites.isEmpty
                      ? const Text(
                          "Henüz favori etkinlik eklenmedi",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: card.favorites
                              .map((f) => _FavoriteChip(favorite: f))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Gelecek Biletlerim (${upcoming.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 176,
                  child: upcoming.isEmpty
                      ? const _EmptyHint(
                          text: "Gelecek bir etkinlik bileti yok",
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: upcoming.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _TicketMiniCard(
                            ticket: upcoming[i],
                            muted: false,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Geçmiş Biletlerim (${past.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 176,
                  child: past.isEmpty
                      ? const _EmptyHint(text: "Geçmiş etkinlik bileti yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: past.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _TicketMiniCard(ticket: past[i], muted: true),
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
  final int upcomingCount;
  const _Header({required this.upcomingCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              color: EventProfileCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Eğlence",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "$upcomingCount bilet sırada",
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

class _AlertBanner extends StatelessWidget {
  final EventTicket ticket;
  const _AlertBanner({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final days = ticket.daysUntilEvent;
    final whenText = days <= 0 ? "Bugün" : "$days gün sonra";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EventProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: EventProfileCardView.moduleAccent.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: EventProfileCardView.moduleAccent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$whenText: ${ticket.eventName} · ${ticket.venue}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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

class _FavoriteChip extends StatelessWidget {
  final FavoriteEvent favorite;
  const _FavoriteChip({required this.favorite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: EventProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EventProfileCardView.moduleAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(favorite.category), size: 13, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            favorite.name,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TicketMiniCard extends StatelessWidget {
  final EventTicket ticket;
  final bool muted;
  const _TicketMiniCard({required this.ticket, required this.muted});

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(ticket.eventName);

    return Opacity(
      opacity: muted ? 0.5 : 1.0,
      child: Container(
        width: 215,
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
                Icon(_iconFor(ticket.category), color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  ticket.category.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (ticket.quantity > 1)
                  Text(
                    "x${ticket.quantity}",
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.eventName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${ticket.venue} · ${ticket.city}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const Spacer(),
            Text(
              _formatDateTime(ticket.eventDateTime),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (ticket.seat != null)
              Text(
                ticket.seat!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            if (!muted) ...[
              const SizedBox(height: 6),
              _AdvanceHint(ticket: ticket),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Tarihi henüz gelmemiş, önceden alınmış bilet" vurgusu — etkinliğe
/// kalan süre ve biletin ne kadar önceden alındığı.
class _AdvanceHint extends StatelessWidget {
  final EventTicket ticket;
  const _AdvanceHint({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final remaining = ticket.daysUntilEvent;
    final advance = ticket.daysBoughtInAdvance;
    final remainingText = remaining <= 0 ? "Bugün" : "$remaining gün kaldı";

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 12,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            advance > 0
                ? "$remainingText · $advance gün önceden alındı"
                : remainingText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

IconData _iconFor(EventCategory category) => switch (category) {
  EventCategory.concert => Icons.music_note_outlined,
  EventCategory.theater => Icons.theater_comedy_outlined,
  EventCategory.cinema => Icons.local_movies_outlined,
  EventCategory.sports => Icons.sports_soccer_outlined,
  EventCategory.festival => Icons.festival_outlined,
  EventCategory.standup => Icons.mic_none_outlined,
  EventCategory.exhibition => Icons.museum_outlined,
};

// Etkinlik başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _eventPalette = <Color>[
  Color(0xFF5A2E52),
  Color(0xFF3E3A5A),
  Color(0xFF5A3E2E),
  Color(0xFF2E4A5A),
];

Color _eventColor(String name) {
  final index = name.hashCode.abs() % _eventPalette.length;
  return _eventPalette[index];
}

String _formatDateTime(DateTime d) {
  final date =
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  final time =
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  return "$date · $time";
}
