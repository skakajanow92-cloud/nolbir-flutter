import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../collection/widgets/save_to_collection_button.dart';
import '../application/product_selection_providers.dart';
import 'ecommerce_shared_widgets.dart';

class EcommerceProductCardView extends ConsumerWidget {
  final EcommerceProductCard card;

  const EcommerceProductCardView({super.key, required this.card});

  static const _base = Color(0xFF101410);
  static const _baseEnd = Color(0xFF161C16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(productVariantSelectionProvider(card.id));
    final isOutOfStock = card.stockStatus == StockStatus.outOfStock;

    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(card: card),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageGallery(imageUrls: card.imageUrls),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProductTitleAndPrice(product: card),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(card.description,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.4)),
          ),
          if (card.variantGroups.isNotEmpty) ...[
            const SizedBox(height: 20),
            for (final group in card.variantGroups)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: VariantGroupPicker(
                    productId: card.id,
                    group: group,
                    selected: selections[group.name],
                  ),
                ),
              ),
          ],
          if (card.specs.isNotEmpty) ...[
            const SizedBox(height: 6),
            const CardSectionLabel(text: "Teknik Özellikler"),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProductSpecsTable(specs: card.specs),
            ),
          ],
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: isOutOfStock ? Colors.white24 : productAccent),
                    onPressed: isOutOfStock
                        ? null
                        : () => addProductToCart(context, ref, card, selections),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(isOutOfStock ? "Tükendi" : "Sepete ekle"),
                  ),
                ),
                const SizedBox(width: 10),
                SaveToCollectionButton(card: card),
              ],
            ),
          ),
          if (card.detailUrl != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Ürün detayları: ${card.detailUrl}",
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final EcommerceProductCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StoreLogo(logoUrl: card.storeLogoUrl, name: card.storeName),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(children: [
                Flexible(
                  child: Text(card.category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                if (card.brandName != null) ...[
                  const Text(" · ", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  Flexible(
                    child: Text(card.brandName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                ],
              ]),
            ],
          ),
        ),
        RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}