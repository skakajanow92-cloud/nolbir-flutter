import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/cart.dart';
import '../../../models/product_card/product_card.dart';
import '../../cart/application/cart_providers.dart';
import 'ecommerce_shared_widgets.dart';

class GiftCatalogItemDetailSheet extends ConsumerWidget {
  final GiftCatalogCard business;
  final GiftCatalogItem item;

  const GiftCatalogItemDetailSheet({
    super.key,
    required this.business,
    required this.item,
  });

  static const accent = Color(0xFFE06C9F);

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    await ref
        .read(cartDetailProvider(CartType.market).notifier)
        .addItem(
          CartItem(
            id: "${business.id}_${item.id}",
            cartType: CartType.market,
            title: "${business.businessName} · ${item.name}",
            imageUrl: item.imageUrl,
            price: item.discountedPrice ?? item.price,
            currency: business.currency,
          ),
        );
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item.name} sepete eklendi"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1020),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              if (item.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    item.imageUrl,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 180,
                      color: Colors.white.withValues(alpha: 0.05),
                      child: const Icon(
                        Icons.card_giftcard_outlined,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              PriceRow(
                price: item.price,
                discountedPrice: item.discountedPrice,
                currency: business.currency,
                accentColor: accent,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AttributeBadge(
                    text: item.category.label,
                    accentColor: accent,
                  ),
                  if (item.sameDayDelivery)
                    AttributeBadge(
                      text: "Aynı Gün Teslimat",
                      accentColor: accent,
                      icon: Icons.local_shipping_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () => _addToCart(context, ref),
                  child: const Text("Sepete ekle"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
