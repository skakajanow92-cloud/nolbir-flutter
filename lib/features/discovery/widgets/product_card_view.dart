import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/cart.dart';
import '../../cart/application/cart_providers.dart';
import '../../collection/widgets/save_to_collection_button.dart';

class ProductCardView extends ConsumerWidget {
  final ProductCard card;

  const ProductCardView({super.key, required this.card});

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    await ref.read(cartDetailProvider(card.cartType).notifier).addItem(
          CartItem(
            id: card.id,
            cartType: card.cartType,
            title: card.title,
            imageUrl: card.imageUrl,
            price: card.price,
            currency: card.currency,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${card.title} sepete eklendi"), duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardShell(
      background: Container(
        color: Colors.grey.shade900,
        alignment: Alignment.center,
        child: const Icon(Icons.shopping_bag, color: Colors.white24, size: 80),
        // TODO: card.imageUrl ile gerçek ürün görseli (Image.network vb.)
      ),
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 6),
          Text("${card.price} ${card.currency}",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 15)),
        ],
      ),
      actions: [
        CardActionButton(
          icon: Icons.add_shopping_cart,
          label: "Sepete ekle",
          onTap: () => _addToCart(context, ref),
        ),
        SaveToCollectionButton(card: card),
      ],
    );
  }
}
