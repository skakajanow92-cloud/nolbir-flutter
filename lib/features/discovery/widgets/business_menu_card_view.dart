import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'ecommerce_shared_widgets.dart' show StoreLogo, RatingBadge;
import 'menu_item_detail_sheet.dart';

class BusinessMenuCardView extends StatelessWidget {
  final BusinessMenuCard card;

  const BusinessMenuCardView({super.key, required this.card});

  static const _base = Color(0xFF1A1208);
  static const _baseEnd = Color(0xFF221A0E);
  static const accent = Color(0xFFE08A3E);

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(card: card),
      body: Column(
        children: [
          for (final item in card.items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _MenuItemTile(card: card, item: item),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final BusinessMenuCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StoreLogo(logoUrl: card.businessLogoUrl, name: card.businessName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.businessType,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _InfoChip(
              icon: Icons.delivery_dining,
              text: "${card.deliveryTimeMinutes} dk",
            ),
            _InfoChip(
              icon: Icons.payments_outlined,
              text: card.deliveryFee == 0
                  ? "Ücretsiz teslimat"
                  : "${card.deliveryFee.toStringAsFixed(0)} ${card.currency} teslimat",
            ),
            if (card.minOrderAmount > 0)
              _InfoChip(
                icon: Icons.shopping_bag_outlined,
                text:
                    "Min. ${card.minOrderAmount.toStringAsFixed(0)} ${card.currency}",
              ),
            if (card.distanceKm != null)
              _InfoChip(
                icon: Icons.location_on_outlined,
                text: "${card.distanceKm!.toStringAsFixed(1)} km",
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final BusinessMenuCard card;
  final MenuItem item;
  const _MenuItemTile({required this.card, required this.item});

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuItemDetailSheet(business: card, item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                color: Colors.white.withValues(alpha: 0.06),
                child: item.imageUrl.isEmpty
                    ? const Icon(Icons.restaurant, color: Colors.white24)
                    : Image.network(item.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.effectivePrice.toStringAsFixed(2)} ${card.currency}",
                    style: const TextStyle(
                      color: BusinessMenuCardView.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: BusinessMenuCardView.accent,
              ),
              onPressed: () => _openDetail(context),
            ),
          ],
        ),
      ),
    );
  }
}
