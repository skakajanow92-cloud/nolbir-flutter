import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/bank_cart.dart';

/// Banka Ürünleri Sepeti Kartı — Sepet Kartları ailesinin altıncı üyesi.
///
/// TASARIM NOTU: Diğer sepet kartlarından FARKLI bir doğası var — burada
/// "ödeme" bir bitiş değil başlangıç. Her kalem, para transferiyle açılan
/// (vadeli mevduat, kıymetli maden) ya da forma yönlendirip belge onayı
/// bekleyen (kredi, kiralık kasa, kripto) bir başvuru süreci içinde; bu
/// yüzden "Sepetim" yerine "İşlemdeki Ürünlerim"/"Tamamlanan Ürünlerim"
/// ayrımı var ve her kalem dokununca (Kargo modülündeki
/// `ShipmentTrackingSheet` presedanıyla aynı mantık) tam adım geçmişini
/// gösteren bir zaman çizelgesi açılıyor.
///
/// Modül vurgu rengi: koyu lacivert — mevcut tüm mavilerden (indigo,
/// lojistik, çelik, kobalt, gökyüzü) daha koyu/doygun, klasik
/// "banka/güven" hissi için bilerek seçildi.
class BankCartCardView extends StatelessWidget {
  final BankCartCard card;

  const BankCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF1F3A5C);
  static const _base = Color(0xFF0A0E13);
  static const _baseEnd = Color(0xFF11171F);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final active = card.activeItems;
    final completed = card.completedItems;

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
                const SizedBox(height: 20),
                _SectionLabel(text: "İşlemdeki Ürünlerim (${active.length})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: active.isEmpty
                      ? const Text("İşlemde ürün yok",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Column(
                          children: active.map((item) => _BankItemRow(item: item)).toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Tamamlanan Ürünlerim (${completed.length})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: completed.isEmpty
                      ? const Text("Henüz tamamlanan ürün yok",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Column(
                          children: completed
                              .map((item) => _BankItemRow(item: item, muted: true))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Faiz Karşılaştırması (${card.comparisons.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 158,
                  child: card.comparisons.isEmpty
                      ? const _EmptyHint(text: "Karşılaştırma için ürün yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.comparisons.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) =>
                              _ComparisonMiniCard(group: card.comparisons[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Sana Özel Ürün Önerileri (${card.recommendations.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: card.recommendations.isEmpty
                      ? const _EmptyHint(text: "Henüz öneri yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.recommendations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _RecommendationMiniCard(product: card.recommendations[i]),
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
  final BankCartCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.account_balance_outlined,
                color: BankCartCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Banka Ürünleri", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${card.cart.items.length} ürün",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 2),
        const Text("başvurularınız süreç içinde takip edilir",
            style: TextStyle(color: Colors.white38, fontSize: 13)),
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

class _StepBadge extends StatelessWidget {
  final ProcessStepStatus status;
  final String label;
  const _StepBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ProcessStepStatus.pending => Colors.white54,
      ProcessStepStatus.inProgress => const Color(0xFFE0A030),
      ProcessStepStatus.completed => const Color(0xFF7FD98A),
      ProcessStepStatus.rejected => const Color(0xFFD98A7F),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _BankItemRow extends StatelessWidget {
  final CartItem item;
  final bool muted;
  const _BankItemRow({required this.item, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(item.bankName);
    final current = item.currentStep;
    final total = item.processSteps.length;
    final done = item.completedStepCount;

    return Opacity(
      opacity: muted ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: () => _openDetail(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: item.hasRejectedStep
                    ? const Color(0xFFD98A7F).withValues(alpha: 0.4)
                    : Colors.white12),
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
                child: Icon(_iconFor(item.productType), color: color, size: 20),
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
                      "${item.bankName} · ${item.productType.label}"
                      "${item.interestRate != null ? ' · %${item.interestRate!.toStringAsFixed(1)}' : ''}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    if (item.isFullyProcessed)
                      const _StepBadge(status: ProcessStepStatus.completed, label: "Tamamlandı")
                    else if (item.hasRejectedStep)
                      const _StepBadge(status: ProcessStepStatus.rejected, label: "Reddedildi")
                    else if (current != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StepBadge(status: current.status, label: current.label),
                          const SizedBox(width: 6),
                          Text("$done/$total adım",
                              style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text("${_formatMoney(item.lineTotal)} ${item.currency}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11171F),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BankProductProcessSheet(item: item),
    );
  }
}

/// Ürün kalemine dokununca açılan tam işlem adımı zaman çizelgesi
/// (bkz. cargo_cart_card_view.dart'taki ShipmentTrackingSheet presedanı).
class BankProductProcessSheet extends StatelessWidget {
  final CartItem item;
  const BankProductProcessSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final steps = item.processSteps;

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
                  child: Text(item.title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text("${item.bankName} · ${item.productType.label}",
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            const Text("Başvuru Süreci",
                style: TextStyle(
                    color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (steps.isEmpty)
              const Text("Henüz süreç adımı yok",
                  style: TextStyle(color: Colors.white38, fontSize: 13))
            else
              ...List.generate(steps.length, (i) {
                final isLast = i == steps.length - 1;
                return _TimelineRow(step: steps[i], isLast: isLast);
              }),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final ProcessStep step;
  final bool isLast;
  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = switch (step.status) {
      ProcessStepStatus.pending => Colors.white24,
      ProcessStepStatus.inProgress => const Color(0xFFE0A030),
      ProcessStepStatus.completed => const Color(0xFF7FD98A),
      ProcessStepStatus.rejected => const Color(0xFFD98A7F),
    };

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
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
              if (!isLast) Container(width: 2, height: 30, color: Colors.white12),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.label,
                    style: TextStyle(
                        color: step.status == ProcessStepStatus.pending
                            ? Colors.white38
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(step.status.label,
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                if (step.completedAt != null)
                  Text(_formatDateTime(step.completedAt!),
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                if (step.note != null)
                  Text(step.note!,
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonMiniCard extends StatelessWidget {
  final InterestRateComparisonGroup group;
  const _ComparisonMiniCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(group.productName);
    final best = group.bestOffer;
    final directionLabel = group.lowerIsBetter ? "en düşük faiz" : "en yüksek faiz";

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
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
            Text(group.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            Text(directionLabel,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
            const Spacer(),
            if (best != null) ...[
              Text("%${best.interestRate.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              Text(best.bankName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ] else
              const Text("Müsait teklif yok",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Text("${group.offers.length} bankada",
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11171F),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => InterestRateComparisonSheet(group: group),
    );
  }
}

/// Karşılaştırma mini kartına dokununca açılan tüm banka tekliflerinin
/// listesi.
class InterestRateComparisonSheet extends StatelessWidget {
  final InterestRateComparisonGroup group;
  const InterestRateComparisonSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final offers = group.sortedByBest;
    final bestId = group.bestOffer?.id;

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
                  child: Text(group.productName,
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
              group.lowerIsBetter
                  ? "En düşük faiz en iyi teklif sayılır"
                  : "En yüksek faiz en iyi teklif sayılır",
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...offers.map((o) => _OfferRow(offer: o, isBest: o.id == bestId)),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final BankOffer offer;
  final bool isBest;
  const _OfferRow({required this.offer, required this.isBest});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: offer.isAvailable ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(offer.bankName,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  if (isBest && offer.isAvailable) ...[
                    const SizedBox(width: 8),
                    const _StepBadge(status: ProcessStepStatus.completed, label: "En İyi Teklif"),
                  ],
                ],
              ),
            ),
            if (!offer.isAvailable)
              const Text("Müsait değil",
                  style: TextStyle(color: Colors.white38, fontSize: 12))
            else
              Text("%${offer.interestRate.toStringAsFixed(2)}",
                  style: TextStyle(
                      color: isBest ? const Color(0xFF7FD98A) : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _RecommendationMiniCard extends StatelessWidget {
  final RecommendedBankProduct product;
  const _RecommendationMiniCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(product.bankName);

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
            child: Text(product.reason.label,
                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Text(product.productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (product.interestRate != null)
            Text("%${product.interestRate!.toStringAsFixed(2)}",
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          Text(product.bankName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

IconData _iconFor(BankProductType type) => switch (type) {
      BankProductType.deposit => Icons.savings_outlined,
      BankProductType.preciousMetal => Icons.diamond_outlined,
      BankProductType.loan => Icons.request_quote_outlined,
      BankProductType.safeBox => Icons.lock_outlined,
      BankProductType.crypto => Icons.currency_bitcoin,
    };

// Banka adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF1F3E5A),
  Color(0xFF3E4A5A),
  Color(0xFF2E3E4A),
  Color(0xFF3E2E4A),
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
