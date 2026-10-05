import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../../models/cart.dart';
import '../../../models/product_card/jewelry_item_card.dart';
import '../../cart/application/cart_providers.dart';
import '../../collection/widgets/save_to_collection_button.dart';
import 'ecommerce_shared_widgets.dart';

class JewelryItemCardView extends ConsumerWidget {
  final JewelryItemCard card;

  const JewelryItemCardView({super.key, required this.card});

  static const _base = Color(0xFF1C1710);
  static const _baseEnd = Color(0xFF26200F);
  static const accent = Color(0xFFD4A947);

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    // NOT: CartType'da kuyumculuk için özel bir değer yok — diğer tek
    // ürün kartlarında olduğu gibi CartType.market kullanıldı.
    await ref.read(cartDetailProvider(CartType.market).notifier).addItem(
          CartItem(
            id: card.id,
            cartType: CartType.market,
            title: "${card.brandName} · ${card.itemName}",
            imageUrl: card.imageUrls.isNotEmpty ? card.imageUrls.first : "",
            price: card.discountedPrice ?? card.price,
            currency: card.currency,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${card.itemName} sepete eklendi"),
            duration: const Duration(seconds: 1)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.itemName,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                PriceRow(
                  price: card.price,
                  discountedPrice: card.discountedPrice,
                  currency: card.currency,
                  accentColor: accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(card.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AttributeBadge(
                    text: "${card.karat} Ayar", accentColor: accent, icon: Icons.verified_outlined),
                AttributeBadge(
                    text: "${card.weightGrams.toStringAsFixed(1)} gr",
                    accentColor: accent,
                    icon: Icons.scale_outlined),
                AttributeBadge(text: card.metalType.label, accentColor: accent),
                for (final gem in card.gemstones)
                  AttributeBadge(text: gem, accentColor: accent, icon: Icons.diamond_outlined),
              ],
            ),
          ),
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
  final JewelryItemCard card;
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
              Text(card.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(card.category.label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}