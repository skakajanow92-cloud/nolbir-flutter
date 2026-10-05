import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'ecommerce_shared_widgets.dart';
import 'jewelry_catalog_item_detail_sheet.dart';

class JewelryCatalogCardView extends StatelessWidget {
  final JewelryCatalogCard card;

  const JewelryCatalogCardView({super.key, required this.card});

  static const _base = Color(0xFF1C1710);
  static const _baseEnd = Color(0xFF26200F);
  static const accent = Color(0xFFD4A947);

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(card: card),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: card.items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, i) =>
              _CatalogTile(brand: card, item: card.items[i]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final JewelryCatalogCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StoreLogo(logoUrl: card.brandLogoUrl, name: card.brandName),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.brandName,
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
                "${card.items.length} ürün",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}

class _CatalogTile extends StatelessWidget {
  final JewelryCatalogCard brand;
  final JewelryCatalogItem item;
  const _CatalogTile({required this.brand, required this.item});

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JewelryCatalogItemDetailSheet(brand: brand, item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.white.withValues(alpha: 0.04),
                child: item.imageUrl.isEmpty
                    ? const Icon(Icons.diamond_outlined, color: Colors.white24)
                    : Image.network(item.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${item.karat} Ayar · ${item.weightGrams.toStringAsFixed(1)}gr",
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(item.discountedPrice ?? item.price).toStringAsFixed(0)} ${brand.currency}",
                    style: const TextStyle(
                      color: JewelryCatalogCardView.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
