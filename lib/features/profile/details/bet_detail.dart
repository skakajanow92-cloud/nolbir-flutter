import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/bet.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/bet_profile_card_view.dart';
import 'profile_detail_common.dart';

const _lostColor = Color(0xFFD98A7F);
const _cashedOutColor = Color(0xFFE0B23A);

Color _statusColor(BetStatus status) => switch (status) {
      BetStatus.won => detailOk,
      BetStatus.lost => _lostColor,
      BetStatus.pending => Colors.white54,
      BetStatus.voided => Colors.white38,
      BetStatus.cashedOut => _cashedOutColor,
    };

String _signed(double value, String currency) =>
    '${value > 0 ? '+' : ''}${formatMoney(value)} $currency';

/// Bahis modülünün masaüstü detay paneli görünümü. Mobildeki kart gibi
/// bilerek NÖTR: öneri, oran tahmini ya da kazanma ihtimali göstermez —
/// kullanıcının kendi kuponlarını (seçimleriyle birlikte) listeleyen bir
/// defterdir.
Widget buildBetDetail(BuildContext context, BetProfileCard card) {
  const accent = BetProfileCardView.moduleAccent;
  final upcoming = card.upcomingCoupons;
  final past = card.pastCoupons;
  final net = card.netResult;

  return DetailPage(
    title: 'Bahis',
    subtitle: '${card.coupons.length} kupon',
    icon: Icons.receipt_long_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Bütçe',
        spacing: 0,
        children: [
          DetailRow(
              label: 'Toplam bütçe',
              value: '${formatMoney(card.totalBudget)} ${card.currency}'),
          DetailRow(
              label: 'Ayrılan (bekleyen)',
              value: '${formatMoney(card.pendingStakeTotal)} ${card.currency}'),
          DetailRow(
            label: 'Kalan bütçe',
            value: '${formatMoney(card.remainingBudget)} ${card.currency}',
            emphasize: true,
          ),
          if (net != null)
            DetailRow(label: 'Net sonuç', value: _signed(net, card.currency)),
        ],
      ),
      DetailSection(
        title: 'Oynanacak Kuponlar (${upcoming.length})',
        children: [
          if (upcoming.isEmpty)
            const DetailEmpty('Gelecekte oynanacak kupon yok'),
          for (final c in upcoming) _couponItem(c, accent),
        ],
      ),
      DetailSection(
        title: 'Geçmiş Kuponlar (${past.length})',
        children: [
          if (past.isEmpty) const DetailEmpty('Geçmiş kupon yok'),
          for (final c in past) _couponItem(c, accent),
        ],
      ),
    ],
  );
}

Widget _couponItem(BetCoupon c, Color accent) {
  final net = c.netResult;
  final title = c.selections.length > 1
      ? '${c.selections.length} maçlık kombine'
      : (c.selections.isNotEmpty ? c.selections.first.eventName : 'Kupon');

  return DetailItem(
    accent: accent,
    icon: Icons.receipt_long_outlined,
    title: title,
    subtitle: c.bookmaker,
    badge: DetailBadge(label: c.status.label, color: _statusColor(c.status)),
    rows: [
      DetailRow(label: 'Kupon kodu', value: c.couponCode),
      DetailRow(label: 'Oynanma', value: formatDate(c.placedDate)),
      DetailRow(label: 'Etkinlik', value: formatDateTime(c.eventDateTime)),
      DetailRow(
          label: 'Bahis tutarı', value: '${formatMoney(c.stake)} ${c.currency}'),
      DetailRow(label: 'Toplam oran', value: c.totalOdds.toStringAsFixed(2)),
      if (c.status == BetStatus.cashedOut && c.cashedOutAmount != null)
        DetailRow(
            label: 'Erken bozum',
            value: '${formatMoney(c.cashedOutAmount!)} ${c.currency}'),
      if (net != null)
        DetailRow(label: 'Net sonuç', value: _signed(net, c.currency), emphasize: true)
      else
        DetailRow(
            label: 'Olası kazanç',
            value: '${formatMoney(c.potentialReturn)} ${c.currency}'),
      if (c.selections.isNotEmpty) ...[
        const _SelectionsLabel(),
        for (final s in c.selections) _SelectionRow(selection: s),
      ],
    ],
  );
}

class _SelectionsLabel extends StatelessWidget {
  const _SelectionsLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 10, bottom: 2),
      child: Text('Seçimler',
          style: TextStyle(
              color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  final BetSelection selection;

  const _SelectionRow({required this.selection});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selection.eventName,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${selection.market} · ${selection.pick}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(selection.odds.toStringAsFixed(2),
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
