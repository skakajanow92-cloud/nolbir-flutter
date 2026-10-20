import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/event.dart';
import '../../../models/event_ticket_cart.dart';

/// Etkinlik Bileti Sepeti Kartı — Sepet Kartları ailesinin sekizinci üyesi.
///
/// TASARIM NOTU: Seyahat Bileti Sepeti'nden (ulaşım) farklı olarak burada
/// bilet, bir etkinliğe GİRİŞ izni: blok/sıra/koltuk/giriş kapısı alanları
/// kalemde görünür, dokununca `TicketEntrySheet` bir bilet koçanı gibi
/// tüm giriş bilgilerini gösterir. Rezervasyonlar henüz ödenmemiş ve belirli
/// bir süre tutuluyor (bkz. Otel Sepeti'ndeki aynı mantık).
///
/// İki uyarı banner'ı var: tutma süresi 48 saat içinde dolacak rezervasyon
/// ve aynı gün 3 saat içinde çakışan iki etkinlik.
///
/// Modül vurgu rengi: misket limonu — önceki yeşil/sarı tonlardan (çim,
/// nane, hardal, taksi sarısı) ayrışan, "festival" hissi veren sarımsı
/// yeşil.
class EventTicketCartCardView extends StatelessWidget {
  final EventTicketCartCard card;

  const EventTicketCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFFA8B83A);
  static const _base = Color(0xFF12130B);
  static const _baseEnd = Color(0xFF1A1C10);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cart = card.cart;
    final items = card.itemsByDate;
    final expiring = card.itemsHoldExpiringSoon;
    final conflicts = card.timeConflicts;

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
                  child: _Header(card: card),
                ),
                if (expiring.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _Banner(
                      icon: Icons.timer_outlined,
                      text:
                          "${expiring.first.eventName}: ${_holdSentence(expiring.first.reservationHoldExpiresAt?.difference(DateTime.now()))}",
                    ),
                  ),
                ],
                if (conflicts.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _Banner(
                      icon: Icons.warning_amber_rounded,
                      text:
                          "${conflicts.first.$1.eventName} ve ${conflicts.first.$2.eventName} aynı saatlere denk geliyor",
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _SectionLabel(text: "Biletlerim (${cart.itemCount})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: items.isEmpty
                      ? const Text(
                          "Sepetiniz boş",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Column(
                          children: items
                              .map((i) => _TicketRow(item: i))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text:
                      "Sana Özel Etkinlikler (${card.recommendations.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 176,
                  child: card.recommendations.isEmpty
                      ? const _EmptyHint(text: "Henüz öneri yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.recommendations.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _RecommendationMiniCard(
                            event: card.recommendations[i],
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
  final EventTicketCartCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.local_activity_outlined,
              color: EventTicketCartCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Etkinlik Bileti Sepeti",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(card.cart.subtotal)} TRY",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "${card.cart.itemCount} bilet · ${card.cart.items.length} etkinlik",
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Banner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0A030).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE0A030).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE0A030), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
        alignment: Alignment.topLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
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
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final CartItem item;
  const _TicketRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(item.organizerName);
    final date = item.eventDateTime;
    final hold = item.reservationHoldExpiresAt;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
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
              child: Icon(_iconFor(item.eventCategory), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${item.organizerName} · ${item.eventVenue}"
                    "${item.eventCity.isNotEmpty ? ', ${item.eventCity}' : ''}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (date != null)
                    Text(
                      _formatDateTime(date),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Chip(
                        text: item.seatSummary,
                        color: item.isGeneralAdmission
                            ? Colors.white54
                            : EventTicketCartCardView.moduleAccent,
                      ),
                      if (item.entranceGate != null)
                        _Chip(text: item.entranceGate!, color: Colors.white54),
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
                Text(
                  "${_formatMoney(item.lineTotal)} ${item.currency}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.quantity > 1)
                  Text(
                    "${item.quantity} bilet",
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white24,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1C10),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TicketEntrySheet(item: item),
    );
  }
}

/// Bilet kalemine dokununca açılan, bilet koçanı gibi tüm giriş
/// bilgilerini gösteren detay sheet (bkz. diğer detay sheet presedanları).
class TicketEntrySheet extends StatelessWidget {
  final CartItem item;
  const TicketEntrySheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final date = item.eventDateTime;
    final hold = item.reservationHoldExpiresAt;

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
                    item.eventName,
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
              item.eventCategory.label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Etkinlik"),
            _DetailRow(label: "Organizatör", value: item.organizerName),
            _DetailRow(
              label: "Mekan",
              value: item.eventCity.isNotEmpty
                  ? "${item.eventVenue}, ${item.eventCity}"
                  : item.eventVenue,
            ),
            if (date != null)
              _DetailRow(label: "Tarih / Saat", value: _formatDateTime(date)),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Giriş Bilgileri"),
            if (item.isGeneralAdmission)
              const _DetailRow(label: "Giriş Türü", value: "Numarasız giriş")
            else ...[
              if (item.seatSection != null)
                _DetailRow(label: "Blok / Bölüm", value: item.seatSection!),
              if (item.seatRow != null)
                _DetailRow(label: "Sıra", value: "${item.seatRow}"),
              if (item.seatNumber != null)
                _DetailRow(label: "Koltuk", value: item.seatNumber!),
            ],
            if (item.entranceGate != null)
              _DetailRow(label: "Giriş Kapısı", value: item.entranceGate!),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Rezervasyon"),
            _DetailRow(label: "Bilet Adedi", value: "${item.quantity}"),
            _DetailRow(
              label: "Tutar",
              value: "${_formatMoney(item.lineTotal)} ${item.currency}",
            ),
            if (hold != null)
              _DetailRow(
                label: "Tutma Süresi",
                value: _holdSentence(hold.difference(DateTime.now())),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: EventTicketCartCardView.moduleAccent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
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

class _RecommendationMiniCard extends StatelessWidget {
  final RecommendedEventTicket event;
  const _RecommendationMiniCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(event.eventName);

    return Container(
      width: 195,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _Chip(text: event.reason.label, color: color),
              if (event.isSellingFast)
                const _Chip(text: "Hızlı Tükeniyor", color: Color(0xFFE0A030)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.eventName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "${event.venue} · ${event.city}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const Spacer(),
          Text(
            _formatDateTime(event.eventDateTime),
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          Text(
            "${_formatMoney(event.fromPrice)} ${event.currency}'den",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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

// Organizatör adı başına sabit, elle seçilmiş uyumlu bir palet (bkz.
// diğer modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF4A5A1F),
  Color(0xFF3E4A5A),
  Color(0xFF5A3E2E),
  Color(0xFF4A2E5A),
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

String _formatRemaining(Duration d) {
  if (d.inDays >= 1) return "${d.inDays} gün";
  if (d.inHours >= 1) return "${d.inHours} saat";
  return "${d.inMinutes} dk";
}

/// Tutma süresini tek bir cümle olarak anlatır; süre dolmuşsa bunu açıkça
/// söyler (bkz. hotel_cart_card_view.dart'taki aynı yardımcı).
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
