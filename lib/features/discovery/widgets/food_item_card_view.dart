import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../../models/cart.dart';
import '../../cart/application/cart_providers.dart';
import '../../collection/widgets/save_to_collection_button.dart';
import 'ecommerce_shared_widgets.dart'
    show StoreLogo, RatingBadge, ProductImageGallery;

class FoodItemCardView extends ConsumerWidget {
  final FoodItemCard card;

  const FoodItemCardView({super.key, required this.card});

  static const _base = Color(0xFF1A1208);
  static const _baseEnd = Color(0xFF221A0E);
  static const accent = Color(0xFFE08A3E);

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    // NOT: CartType'da yemek siparişi için özel bir değer göremedim —
    // diğer kartlarda olduğu gibi şimdilik CartType.market kullanıldı.
    await ref
        .read(cartDetailProvider(CartType.market).notifier)
        .addItem(
          CartItem(
            id: card.id,
            cartType: CartType.market,
            title: "${card.businessName} · ${card.itemName}",
            imageUrl: card.imageUrls.isNotEmpty ? card.imageUrls.first : "",
            price: card.effectivePrice,
            currency: card.currency,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${card.itemName} sepete eklendi"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: _TitleAndPrice(card: card),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              card.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          if (card.dietaryTags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: card.dietaryTags
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          t.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    onPressed: () => _addToCart(context, ref),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("Sepete ekle"),
                  ),
                ),
                const SizedBox(width: 10),
                SaveToCollectionButton(card: card),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final FoodItemCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                "${card.businessType} · ${card.category.label}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}

class _TitleAndPrice extends StatelessWidget {
  final FoodItemCard card;
  const _TitleAndPrice({required this.card});

  @override
  Widget build(BuildContext context) {
    final discountPercent = card.discountPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.itemName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              "${card.effectivePrice.toStringAsFixed(2)} ${card.currency}",
              style: const TextStyle(
                color: FoodItemCardView.accent,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (discountPercent != null) ...[
              const SizedBox(width: 8),
              Text(
                "${card.price.toStringAsFixed(2)} ${card.currency}",
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            const SizedBox(width: 10),
            const Icon(Icons.timer_outlined, color: Colors.white38, size: 14),
            const SizedBox(width: 2),
            Text(
              "${card.prepTimeMinutes} dk",
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
