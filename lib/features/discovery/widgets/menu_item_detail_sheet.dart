import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/cart.dart';
import '../../../models/product_card/product_card.dart';
import '../../cart/application/cart_providers.dart';

class MenuItemDetailSheet extends ConsumerStatefulWidget {
  final BusinessMenuCard business;
  final MenuItem item;

  const MenuItemDetailSheet({
    super.key,
    required this.business,
    required this.item,
  });

  @override
  ConsumerState<MenuItemDetailSheet> createState() =>
      _MenuItemDetailSheetState();
}

class _MenuItemDetailSheetState extends ConsumerState<MenuItemDetailSheet> {
  int _quantity = 1;

  Future<void> _addToCart() async {
    final item = widget.item;
    await ref
        .read(cartDetailProvider(CartType.market).notifier)
        .addItem(
          CartItem(
            id: "${widget.business.id}_${item.id}",
            cartType: CartType.market,
            title: "${widget.business.businessName} · ${item.name}",
            imageUrl: item.imageUrl,
            price: item.effectivePrice,
            currency: widget.business.currency,
            metadata: {"quantity": _quantity.toString()},
          ),
        );
    if (mounted) {
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
  Widget build(BuildContext context) {
    final item = widget.item;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1208),
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
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: Colors.white.withValues(alpha: 0.05),
                      child: const Icon(
                        Icons.restaurant,
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
              const SizedBox(height: 6),
              Text(
                "${item.effectivePrice.toStringAsFixed(2)} ${widget.business.currency}",
                style: const TextStyle(
                  color: Color(0xFFE08A3E),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (item.dietaryTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: item.dietaryTags
                      .map(
                        (t) => Text(
                          "· ${t.label}",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white54,
                    ),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    "$_quantity",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white54,
                    ),
                    onPressed: () => setState(() => _quantity++),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE08A3E),
                    ),
                    onPressed: _addToCart,
                    child: const Text("Sepete ekle"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
