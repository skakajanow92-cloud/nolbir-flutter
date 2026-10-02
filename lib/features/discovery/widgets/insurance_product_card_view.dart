import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../collection/widgets/save_to_collection_button.dart';

class InsuranceProductCardView extends StatelessWidget {
  final InsuranceProductCard card;

  const InsuranceProductCardView({super.key, required this.card});

  static const _base = Color(0xFF14101F);
  static const _baseEnd = Color(0xFF1C1630);
  static const accent = Color(0xFF8B6CF0);

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(card: card),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(card.description,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.4)),
          ),
          const SizedBox(height: 18),
          if (card.imageUrls.isNotEmpty) ...[
            _ImageGallery(imageUrls: card.imageUrls),
            const SizedBox(height: 20),
          ],
          if (card.coverageHighlights.isNotEmpty) ...[
            const CardSectionLabel(text: "Teminatlar"),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: card.coverageHighlights
                    .map((h) => _HighlightChip(text: h))
                    .toList(),
              ),
            ),
            const SizedBox(height: 22),
          ],
          const CardSectionLabel(text: "Paket Seçenekleri"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PlanOptionsList(card: card),
          ),
          if (card.deductible != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Muafiyet: ${card.deductible!.toStringAsFixed(0)} ${card.currency}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ActionRow(card: card),
          ),
          if (card.detailUrl != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Ürün detayları: ${card.detailUrl}",
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InsuranceProductCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    final isBroker = card.sellerKind == InsuranceSellerKind.brokerAgent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CompanyLogo(logoUrl: card.sellerLogoUrl, name: card.sellerName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(card.sellerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (isBroker) ...[
                        const SizedBox(width: 6),
                        _Badge(text: "Acente"),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(card.coverageType.label,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            _RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
          ],
        ),
        if (isBroker) ...[
          const SizedBox(height: 10),
          _UnderwriterLine(
            name: card.underwritingCompanyName!,
            logoUrl: card.underwritingCompanyLogoUrl,
          ),
        ],
      ],
    );
  }
}

/// Acente vitrininde: "Bu poliçe X Sigorta tarafından üstlenilmektedir."
class _UnderwriterLine extends StatelessWidget {
  final String name;
  final String? logoUrl;
  const _UnderwriterLine({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (logoUrl != null && logoUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(logoUrl!, width: 20, height: 20, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
          ] else
            const Icon(Icons.verified_outlined, color: Colors.white38, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "Bu poliçe $name tarafından üstlenilmektedir",
              style: const TextStyle(color: Colors.white54, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  const _CompanyLogo({required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: logoUrl.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield_outlined, color: Colors.white54),
              ),
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: InsuranceProductCardView.accent.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;
  const _RatingBadge({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 2),
            Text(rating.toStringAsFixed(1),
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        Text("$reviewCount değerlendirme",
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  const _ImageGallery({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 220,
            color: Colors.white.withValues(alpha: 0.06),
            child: Image.network(
              imageUrls[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_outlined, color: Colors.white24),
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  final String text;
  const _HighlightChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: InsuranceProductCardView.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: InsuranceProductCardView.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PlanOptionsList extends StatelessWidget {
  final InsuranceProductCard card;
  const _PlanOptionsList({required this.card});

  @override
  Widget build(BuildContext context) {
    final cheapest = card.cheapestPlan;
    return Column(
      children: [
        for (final plan in card.planOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: identical(plan, cheapest)
                    ? Border.all(
                        color: InsuranceProductCardView.accent.withValues(alpha: 0.5))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(plan.coverageSummary,
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(
                    "${plan.monthlyPremium.toStringAsFixed(0)} ${card.currency}/ay",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final InsuranceProductCard card;
  const _ActionRow({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: InsuranceProductCardView.accent),
            onPressed: () {
              // TODO: teklif/başvuru akışı — form sistemine bağlanacak
            },
            child: const Text("Teklif al"),
          ),
        ),
        const SizedBox(width: 10),
        SaveToCollectionButton(card: card),
      ],
    );
  }
}