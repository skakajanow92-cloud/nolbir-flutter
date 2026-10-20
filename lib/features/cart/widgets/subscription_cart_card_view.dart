import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/hosting.dart';
import '../../../models/subscription_cart.dart';

/// Abonelik Sepeti Kartı — Sepet Kartları ailesinin onuncu üyesi.
///
/// TASARIM NOTU: Kalemler sahip türüne göre (koleksiyon sahibi / yayıncı /
/// yapımcı şirket) gruplanıyor. Abonelik sepetinde asıl risk SÜRPRİZ
/// TAHSİLAT olduğu için kartın üç özelliği buna odaklı: (1) ücretsiz
/// denemesi olan kalemlerde "bugün ödenecek" 0 gösteriliyor ve deneme
/// bitince ne zaman ne kadar tahsil edileceği açıkça yazılıyor, (2) üstte
/// en yakın deneme bitişi için uyarı banner'ı var, (3) taahhüt ve
/// otomatik yenileme rozet olarak görünür.
///
/// Fiyat karşılaştırması yerine plan SEVİYESİ karşılaştırması var — abonelik
/// içeriği sahibine özgü, başka bir sahipte aynısı bulunmaz.
///
/// NOT: Tüm kalemlerin TRY olduğu varsayılıyor (bkz. Cüzdan/Gayrimenkul
/// modüllerindeki aynı not).
///
/// Modül vurgu rengi: orkide moru — fuşya (0xFFA33A8C) ve menekşe-mordan
/// (0xFF6A4E9C) ayrışan, daha açık ve parlak bir "medya" tonu.
class SubscriptionCartCardView extends StatelessWidget {
  final SubscriptionCartCard card;

  const SubscriptionCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFFB05FD1);
  static const _base = Color(0xFF130E16);
  static const _baseEnd = Color(0xFF1C1522);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cart = card.cart;
    final grouped = card.itemsByOwnerKind;
    final trials = card.itemsWithTrial;

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
                if (trials.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _TrialBanner(item: trials.first),
                  ),
                ],
                const SizedBox(height: 20),
                _SectionLabel(text: "Aboneliklerim (${cart.items.length})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: cart.items.isEmpty
                      ? const Text("Sepetiniz boş",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Column(
                          children: grouped.entries
                              .map((e) => _KindGroup(kind: e.key, items: e.value))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                    text: "Plan Seviyeleri (${card.tierComparisons.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 148,
                  child: card.tierComparisons.isEmpty
                      ? const _EmptyHint(text: "Karşılaştırma için abonelik yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.tierComparisons.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, i) =>
                              _TierGroupMiniCard(group: card.tierComparisons[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Sana Özel Öneriler (${card.recommendations.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 168,
                  child: card.recommendations.isEmpty
                      ? const _EmptyHint(text: "Henüz öneri yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.recommendations.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _RecommendationMiniCard(plan: card.recommendations[i]),
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
  final SubscriptionCartCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    final trialCount = card.itemsWithTrial.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.subscriptions_outlined,
                color: SubscriptionCartCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Abonelik Sepeti", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(card.totalDueToday)} TRY",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 2),
        Text(
          "bugün ödenecek · ${card.cart.items.length} abonelik"
          "${trialCount > 0 ? ' · $trialCount ücretsiz deneme' : ''}",
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text("aylık karşılık ≈ ${_formatMoney(card.totalMonthlyEquivalent)} TRY",
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _TrialBanner extends StatelessWidget {
  final CartItem item;
  const _TrialBanner({required this.item});

  @override
  Widget build(BuildContext context) {
    final days = item.subTrialDays;
    final when = days <= 1 ? "Yarın" : "$days gün sonra";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0A030).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0A030).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_repeat_outlined, color: Color(0xFFE0A030), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$when ${item.subPlanName} için ${_formatMoney(item.lineTotal)} ${item.currency} "
              "tahsil edilecek (deneme bitiyor)",
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _KindGroup extends StatelessWidget {
  final SubscriptionOwnerKind kind;
  final List<CartItem> items;
  const _KindGroup({required this.kind, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForKind(kind), color: SubscriptionCartCardView.moduleAccent, size: 15),
              const SizedBox(width: 6),
              Text(kind.pluralLabel,
                  style: const TextStyle(
                      color: SubscriptionCartCardView.moduleAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _SubscriptionRow(item: item)),
        ],
      ),
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  final CartItem item;
  const _SubscriptionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(item.subOwnerName);
    final commitment = item.subMinCommitmentMonths;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(_iconForKind(item.subOwnerKind), color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.subOwnerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(item.subPlanName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  if (item.subContentSummary != null)
                    Text(item.subContentSummary!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (item.subHasTrial)
                        _Chip(
                            text: "${item.subTrialDays} gün ücretsiz",
                            color: const Color(0xFF7FD98A)),
                      if (commitment != null)
                        _Chip(text: "$commitment ay taahhüt", color: const Color(0xFFE0A030))
                      else
                        const _Chip(text: "Taahhütsüz", color: Colors.white54),
                      if (item.subAutoRenew)
                        const _Chip(text: "Otomatik yenilenir", color: Colors.white54),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.subHasTrial) ...[
                  const Text("0 TRY",
                      style: TextStyle(
                          color: Color(0xFF7FD98A), fontSize: 14, fontWeight: FontWeight.w700)),
                  Text("sonra ${_formatMoney(item.lineTotal)} / ${item.subBillingCycle.label}",
                      style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ] else ...[
                  Text("${_formatMoney(item.lineTotal)} ${item.currency}",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(item.subBillingCycle.label,
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
                const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
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
      backgroundColor: const Color(0xFF1C1522),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SubscriptionDetailSheet(item: item),
    );
  }
}

/// Abonelik kalemine dokununca açılan detay: kapsam, koşullar ve ödeme
/// dökümü (bkz. diğer modüllerdeki detay sheet presedanı).
class SubscriptionDetailSheet extends StatelessWidget {
  final CartItem item;
  const SubscriptionDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final commitment = item.subMinCommitmentMonths;

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
                  child: Text(item.subOwnerName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text("${item.subOwnerKind.label} · ${item.subPlanName}",
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            if (item.subContentSummary != null) ...[
              const SizedBox(height: 4),
              Text(item.subContentSummary!,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
            if (item.subFeatures.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _GroupLabel(text: "Kapsam"),
              ...item.subFeatures.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 15, color: Color(0xFF7FD98A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(f,
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 16),
            const _GroupLabel(text: "Koşullar"),
            _DetailRow(
                label: "Taahhüt",
                value: commitment != null ? "$commitment ay" : "Taahhütsüz"),
            _DetailRow(
                label: "Yenileme",
                value: item.subAutoRenew ? "Otomatik yenilenir" : "Manuel"),
            if (item.subHasTrial)
              _DetailRow(label: "Ücretsiz Deneme", value: "${item.subTrialDays} gün"),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Ödeme"),
            _DetailRow(
                label: "${item.subBillingCycle.label} Fiyat",
                value: "${_formatMoney(item.lineTotal)} ${item.currency}"),
            _DetailRow(
                label: "Bugün Ödenecek",
                value: "${_formatMoney(item.subChargedToday)} ${item.currency}"),
            _DetailRow(
                label: item.subHasTrial ? "İlk Tahsilat" : "Tahsilat",
                value: _formatDate(item.subFirstChargeDate)),
            _DetailRow(
                label: "Aylık Karşılık",
                value: "≈ ${_formatMoney(item.subLineMonthlyEquivalent)} ${item.currency}"),
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
      child: Text(text,
          style: const TextStyle(
              color: SubscriptionCartCardView.moduleAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
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
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _TierGroupMiniCard extends StatelessWidget {
  final SubscriptionTierGroup group;
  const _TierGroupMiniCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(group.ownerName);
    final selected = group.selectedTier;
    final cheapest = group.cheapestTier;
    final hasCheaper =
        selected != null && cheapest != null && cheapest.name != selected.name;
    final saving = hasCheaper ? -(group.monthlyDifference(cheapest) ?? 0) : 0.0;

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
            Text(group.ownerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            Text("${group.tiers.length} plan seviyesi",
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const Spacer(),
            if (selected != null) ...[
              Text("Seçili: ${selected.name}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              Text("${_formatMoney(selected.monthlyEquivalent)} ${selected.currency} / ay",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
            if (hasCheaper)
              Text(
                "${cheapest.name} ile ayda ${_formatMoney(saving)} TRY daha ucuz",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF7FD98A), fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1522),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TierComparisonSheet(group: group),
    );
  }
}

/// Plan seviyesi mini kartına dokununca açılan tüm seviyelerin listesi —
/// her seviye seçili plana göre aylık farkla gösterilir.
class TierComparisonSheet extends StatelessWidget {
  final SubscriptionTierGroup group;
  const TierComparisonSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final tiers = group.sortedByPrice;

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
                  child: Text(group.ownerName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Text("Fark, sepetteki seçili plana göre aylık karşılık üzerinden hesaplanır",
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 16),
            ...tiers.map((t) => _TierRow(
                  tier: t,
                  isSelected: t.name == group.selectedTierName,
                  difference: group.monthlyDifference(t),
                )),
          ],
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  final SubscriptionTier tier;
  final bool isSelected;
  final double? difference;
  const _TierRow({required this.tier, required this.isSelected, required this.difference});

  @override
  Widget build(BuildContext context) {
    Widget? diffChip;
    if (isSelected) {
      diffChip = const _Chip(text: "Seçili", color: SubscriptionCartCardView.moduleAccent);
    } else if (difference != null) {
      final cheaper = difference! < 0;
      diffChip = _Chip(
        text: "${cheaper ? '-' : '+'}${_formatMoney(difference!.abs())} TRY / ay",
        color: cheaper ? const Color(0xFF7FD98A) : const Color(0xFFE0A030),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(tier.name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    if (diffChip != null) ...[
                      const SizedBox(width: 8),
                      diffChip,
                    ],
                  ],
                ),
                if (tier.highlights.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(tier.highlights.join(" · "),
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${_formatMoney(tier.monthlyEquivalent)} / ay",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              Text("${_formatMoney(tier.price)} ${tier.currency} · ${tier.billingCycle.label}",
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationMiniCard extends StatelessWidget {
  final RecommendedSubscriptionPlan plan;
  const _RecommendationMiniCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(plan.ownerName);

    return Container(
      width: 185,
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
              _Chip(text: plan.reason.label, color: color),
              if (plan.bundleSavingsPercent != null)
                _Chip(
                    text: "%${plan.bundleSavingsPercent!.toStringAsFixed(0)} tasarruf",
                    color: const Color(0xFF7FD98A)),
            ],
          ),
          const SizedBox(height: 8),
          Text(plan.ownerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          Text("${plan.ownerKind.label} · ${plan.planName}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const Spacer(),
          if (plan.trialDays != null && plan.trialDays! > 0)
            Text("${plan.trialDays} gün ücretsiz",
                style: const TextStyle(color: Color(0xFF7FD98A), fontSize: 11)),
          Text("${_formatMoney(plan.price)} ${plan.currency} / ${plan.billingCycle.label}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

IconData _iconForKind(SubscriptionOwnerKind kind) => switch (kind) {
      SubscriptionOwnerKind.collectionOwner => Icons.collections_bookmark_outlined,
      SubscriptionOwnerKind.publisher => Icons.menu_book_outlined,
      SubscriptionOwnerKind.producer => Icons.movie_creation_outlined,
    };

// Sahip adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF4A2E5A),
  Color(0xFF3E4A5A),
  Color(0xFF5A2E45),
  Color(0xFF2E3E5A),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
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
