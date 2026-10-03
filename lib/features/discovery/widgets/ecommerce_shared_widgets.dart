import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_card/product_card.dart';
import '../../../models/cart.dart';
import '../../cart/application/cart_providers.dart';
import '../application/product_selection_providers.dart';

/// E-ticaret ürün ailesinin (tam sayfa kart + grid detay sheet'i) ortak
/// rengi — iki farklı sunumun aynı aileye ait olduğunu belli eder.
const productAccent = Color(0xFF4CAF7D);

class StoreLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  const StoreLogo({super.key, required this.logoUrl, required this.name});

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
          ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.storefront, color: Colors.white54)),
            ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;
  const RatingBadge({super.key, required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 2),
          Text(rating.toStringAsFixed(1),
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        Text("$reviewCount değerlendirme",
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

class ProductImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  const ProductImageGallery({super.key, required this.imageUrls, this.height = 220});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (_, i) => Container(
          color: Colors.white.withValues(alpha: 0.05),
          child: Image.network(imageUrls[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_outlined, color: Colors.white24, size: 48)),
        ),
      ),
    );
  }
}

class StockBadge extends StatelessWidget {
  final StockStatus status;
  const StockBadge({super.key, required this.status});

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

class ProductTitleAndPrice extends StatelessWidget {
  final EcommerceProductCard product;
  const ProductTitleAndPrice({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountPercent = product.discountPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Row(children: [
          Text(
            "${product.effectivePrice.toStringAsFixed(2)} ${product.currency}",
            style: const TextStyle(
                color: productAccent, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          if (discountPercent != null) ...[
            const SizedBox(width: 8),
            Text(
              "${product.price.toStringAsFixed(2)} ${product.currency}",
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
                  borderRadius: BorderRadius.circular(6)),
              child: Text("-%$discountPercent",
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        const SizedBox(height: 6),
        StockBadge(status: product.stockStatus),
      ],
    );
  }
}

class VariantGroupPicker extends ConsumerWidget {
  final String productId;
  final ProductVariantGroup group;
  final String? selected;

  const VariantGroupPicker({
    super.key,
    required this.productId,
    required this.group,
    required this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.name,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: group.options.map((option) {
            final isSelected = option == selected;
            return GestureDetector(
              onTap: () {
                final notifier =
                    ref.read(productVariantSelectionProvider(productId).notifier);
                notifier.update((state) => {...state, group.name: option});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? productAccent.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? productAccent : Colors.white24),
                ),
                child: Text(option,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70, fontSize: 13)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ProductSpecsTable extends StatelessWidget {
  final List<ProductSpec> specs;
  const ProductSpecsTable({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final spec in specs)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: 120,
                  child: Text(spec.label,
                      style: const TextStyle(color: Colors.white54, fontSize: 13))),
              Expanded(
                  child: Text(spec.value,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
          ),
      ],
    );
  }
}

/// Eksik varyant seçimlerini döner; hepsi seçiliyse boş liste.
List<String> missingVariantGroups(
    EcommerceProductCard product, Map<String, String> selections) {
  return [
    for (final group in product.variantGroups)
      if (!selections.containsKey(group.name)) group.name,
  ];
}

Future<void> addProductToCart(
  BuildContext context,
  WidgetRef ref,
  EcommerceProductCard product,
  Map<String, String> selections,
) async {
  final missing = missingVariantGroups(product, selections);
  if (missing.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lütfen seçin: ${missing.join(', ')}")),
    );
    return;
  }
  await ref.read(cartDetailProvider(product.cartType).notifier).addItem(
        CartItem(
          id: product.id,
          cartType: product.cartType,
          title: product.title,
          imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : "",
          price: product.effectivePrice,
          currency: product.currency,
          metadata: selections,
        ),
      );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("${product.title} sepete eklendi"),
          duration: const Duration(seconds: 1)),
    );
  }
}