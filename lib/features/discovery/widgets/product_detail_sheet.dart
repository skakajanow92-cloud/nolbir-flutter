import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_card/product_card.dart';
import '../application/product_selection_providers.dart';
import 'ecommerce_shared_widgets.dart';

/// Grid'deki bir ürüne dokunulunca açılan detay sayfası. Tam sayfa
/// `EcommerceProductCardView` ile aynı paylaşılan bileşenleri (galeri,
/// fiyat, varyant seçimi, teknik özellikler, sepete ekle) kullanır —
/// fark sadece sunum: tam sayfa yerine sürüklenebilir bir bottom sheet.
class ProductDetailSheet extends ConsumerWidget {
  final EcommerceProductCard product;

  const ProductDetailSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(productVariantSelectionProvider(product.id));
    final isOutOfStock = product.stockStatus == StockStatus.outOfStock;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF14181A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  StoreLogo(
                    logoUrl: product.storeLogoUrl,
                    name: product.storeName,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.storeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          product.category.label,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RatingBadge(
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (product.imageUrls.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ProductImageGallery(
                    imageUrls: product.imageUrls,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ProductTitleAndPrice(product: product),
              const SizedBox(height: 14),
              Text(
                product.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (product.variantGroups.isNotEmpty) ...[
                const SizedBox(height: 18),
                for (final group in product.variantGroups)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: VariantGroupPicker(
                      productId: product.id,
                      group: group,
                      selected: selections[group.name],
                    ),
                  ),
              ],
              if (product.specs.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Text(
                  "Teknik Özellikler",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ProductSpecsTable(specs: product.specs),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: isOutOfStock
                      ? Colors.white24
                      : productAccent,
                ),
                onPressed: isOutOfStock
                    ? null
                    : () => addProductToCart(context, ref, product, selections),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(isOutOfStock ? "Tükendi" : "Sepete ekle"),
              ),
            ],
          ),
        );
      },
    );
  }
}
