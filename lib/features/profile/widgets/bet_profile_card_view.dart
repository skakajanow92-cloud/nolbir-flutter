import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/bet.dart';

/// Bahis Profili — yirmi birinci profil modülü.
///
/// TASARIM NOTU: Bu kart bilerek NÖTR/organize edici — bahis önerisi,
/// oran tahmini ya da "kazanma ihtimali" göstermez; kullanıcının kendi
/// geçmiş ve planladığı kuponlarını listeleyen bir defter mantığındadır.
///
/// Bütçe başlığı `totalBudget` ile henüz sonuçlanmamış kuponların
/// `stake` toplamından `remainingBudget`i CANLI gösterir (bkz. bet.dart).
///
/// Modül vurgu rengi: koyu bordo-kırmızı — Tanışma modülünün gülünden
/// (0xFFB23A56) ve Kargo modülünün turuncu-kızılından (0xFFB8451F)
/// ayrışan, daha koyu/riskli bir ton.
class BetProfileCardView extends StatelessWidget {
  final BetProfileCard card;

  const BetProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF8C2A2A);
  static const _base = Color(0xFF130E0E);
  static const _baseEnd = Color(0xFF1D1414);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final upcoming = card.upcomingCoupons;
    final past = card.pastCoupons;

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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _BudgetRow(card: card),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Oynanacak Kuponlar (${upcoming.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 168,
                  child: upcoming.isEmpty
                      ? const _EmptyHint(text: "Gelecekte oynanacak kupon yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: upcoming.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _CouponMiniCard(coupon: upcoming[i], muted: false),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Geçmiş Kuponlar (${past.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 168,
                  child: past.isEmpty
                      ? const _EmptyHint(text: "Geçmiş kupon yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: past.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _CouponMiniCard(coupon: past[i], muted: true),
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
  final BetProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.receipt_long_outlined,
                color: BetProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Bahis", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${card.coupons.length} kupon",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final BetProfileCard card;
  const _BudgetRow({required this.card});

  @override
  Widget build(BuildContext context) {
    final net = card.netResult;

    return Row(
      children: [
        Expanded(
          child: _BudgetChip(
            label: "Kalan Bütçe",
            value: "${_formatMoney(card.remainingBudget)} ${card.currency}",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BudgetChip(
            label: "Toplam Bütçe",
            value: "${_formatMoney(card.totalBudget)} ${card.currency}",
          ),
        ),
        if (net != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _BudgetChip(
              label: "Net Sonuç",
              value: "${net >= 0 ? '+' : ''}${_formatMoney(net)} ${card.currency}",
              valueColor: net >= 0 ? const Color(0xFF7FD98A) : const Color(0xFFD98A7F),
            ),
          ),
        ],
      ],
    );
  }
}

class _BudgetChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _BudgetChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: BetProfileCardView.moduleAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: BetProfileCardView.moduleAccent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
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

class _CouponMiniCard extends StatelessWidget {
  final BetCoupon coupon;
  final bool muted;
  const _CouponMiniCard({required this.coupon, required this.muted});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(coupon.bookmaker);
    final net = coupon.netResult;

    return Opacity(
      opacity: muted ? 0.6 : 1.0,
      child: Container(
        width: 210,
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
                Expanded(
                  child: Text(coupon.bookmaker,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                _StatusPill(status: coupon.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              coupon.selections.length > 1
                  ? "${coupon.selections.length} maçlık kombine"
                  : (coupon.selections.isNotEmpty
                      ? coupon.selections.first.eventName
                      : "Kupon"),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text("${_formatMoney(coupon.stake)} ${coupon.currency} · Oran ${coupon.totalOdds.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(_formatDateTime(coupon.eventDateTime),
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            if (net != null) ...[
              const SizedBox(height: 4),
              Text(
                "${net >= 0 ? '+' : ''}${_formatMoney(net)} ${coupon.currency}",
                style: TextStyle(
                    color: net >= 0 ? const Color(0xFF7FD98A) : const Color(0xFFD98A7F),
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text("olası kazanç: ${_formatMoney(coupon.potentialReturn)} ${coupon.currency}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final BetStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BetStatus.won => const Color(0xFF7FD98A),
      BetStatus.lost => const Color(0xFFD98A7F),
      BetStatus.pending => Colors.white54,
      BetStatus.voided => Colors.white38,
      BetStatus.cashedOut => const Color(0xFFE0B23A),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.label,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}

// Bahis firması başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF5A2E2E),
  Color(0xFF3E4A5A),
  Color(0xFF5A4A2E),
  Color(0xFF3E5A45),
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

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
