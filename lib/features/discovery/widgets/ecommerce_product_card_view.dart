import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../../models/cart.dart';
import '../../cart/application/cart_providers.dart';
import '../../collection/widgets/save_to_collection_button.dart';
import '../application/product_selection_providers.dart';

class EcommerceProductCardView extends ConsumerWidget {
  final EcommerceProductCard card;

  const EcommerceProductCardView({super.key, required this.card});

  static const _base = Color(0xFF101410);
  static const _baseEnd = Color(0xFF161C16);
  static const accent = Color(0xFF4CAF7D);

  /// Tüm varyant grupları seçilmeden sepete eklenemez. Her grup için
  /// seçim yoksa eksik gruplar döner (boş liste = tamamı seçili).
  List<String> _missingGroups(Map<String, String> selections) {
    return [
      for (final group in card.variantGroups)
        if (!selections.containsKey(group.name)) group.name,
    ];
  }

  Future<void> _addToCart(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> selections,
  ) async {
    final missing = _missingGroups(selections);
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen seçin: ${missing.join(', ')}")),
      );
      return;
    }

    await ref.read(cartDetailProvider(card.cartType).notifier).addItem(
          CartItem(
            id: card.id,
            cartType: card.cartType,
            title: card.title,
            imageUrl: card.imageUrls.isNotEmpty ? card.imageUrls.first : "",
            price: card.effectivePrice,
            currency: card.currency,
            metadata: selections,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${card.title} sepete eklendi"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

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
          if (card.imageUrls.isNotEmpty) _ImageGallery(imageUrls: card.imageUrls),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TitleAndPrice(card: card),
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
                child: _VariantGroupPicker(
                  cardId: card.id,
                  group: group,
                  selected: selections[group.name],
                ),
              ),
          ],
          if (card.specs.isNotEmpty) ...[
            const SizedBox(height: 6),
            const CardSectionLabel(text: "Teknik Özellikler"),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SpecsTable(specs: card.specs),
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
                      backgroundColor: isOutOfStock ? Colors.white24 : accent,
                    ),
                    onPressed: isOutOfStock
                        ? null
                        : () => _addToCart(context, ref, selections),
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
  final EcommerceProductCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StoreLogo(logoUrl: card.storeLogoUrl, name: card.storeName),
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
              Row(
                children: [
                  Flexible(
                    child: Text(card.category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                  if (card.brandName != null) ...[
                    const Text(" · ",
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Flexible(
                      child: Text(card.brandName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        _RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}

class _StoreLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  const _StoreLogo({required this.logoUrl, required this.name});

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
                    const Icon(Icons.storefront, color: Colors.white54),
              ),
            ),
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
      height: 220,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (_, i) => Container(
          color: Colors.white.withValues(alpha: 0.05),
          child: Image.network(
            imageUrls[i],
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_outlined, color: Colors.white24, size: 48),
          ),
        ),
      ),
    );
  }
}

class _TitleAndPrice extends StatelessWidget {
  final EcommerceProductCard card;
  const _TitleAndPrice({required this.card});

  @override
  Widget build(BuildContext context) {
    final discountPercent = card.discountPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(card.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              "${card.effectivePrice.toStringAsFixed(2)} ${card.currency}",
              style: const TextStyle(
                  color: EcommerceProductCardView.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            if (discountPercent != null) ...[
              const SizedBox(width: 8),
              Text(
                "${card.price.toStringAsFixed(2)} ${card.currency}",
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("-%$discountPercent",
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        _StockBadge(status: card.stockStatus),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  final StockStatus status;
  const _StockBadge({required this.status});

  Color get _color {
    switch (status) {
      case StockStatus.inStock:
        return Colors.greenAccent;
      case StockStatus.lowStock:
        return Colors.amberAccent;
      case StockStatus.outOfStock:
        return Colors.redAccent;
      case StockStatus.preOrder:
        return Colors.lightBlueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(status.label,
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600));
  }
}

class _VariantGroupPicker extends ConsumerWidget {
  final String cardId;
  final ProductVariantGroup group;
  final String? selected;

  const _VariantGroupPicker({
    required this.cardId,
    required this.group,
    required this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(group.name,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.options.map((option) {
              final isSelected = option == selected;
              return GestureDetector(
                onTap: () {
                  final notifier =
                      ref.read(productVariantSelectionProvider(cardId).notifier);
                  notifier.update((state) => {...state, group.name: option});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? EcommerceProductCardView.accent.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? EcommerceProductCardView.accent
                          : Colors.white24,
                    ),
                  ),
                  child: Text(option,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 13)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SpecsTable extends StatelessWidget {
  final List<ProductSpec> specs;
  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final spec in specs)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(spec.label,
                      style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ),
                Expanded(
                  child: Text(spec.value,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}