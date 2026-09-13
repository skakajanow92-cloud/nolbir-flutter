import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/cart.dart';
import '../../../features/cart/application/cart_providers.dart';

/// Hiçbir domain'e özel builder kaydedilmemiş `CartItem`'lar için
/// otomatik, genel amaçlı satır görünümü. Sistemin "her yeni sepet türü
/// sıfır ekstra kod ile çalışsın" garantisi bu widget sayesinde geçerli.
class DefaultCartItemTile extends ConsumerWidget {
  final CartItem item;

  const DefaultCartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartDetailProvider(item.cartType).notifier);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white10,
        child: item.imageUrl == null || item.imageUrl!.isEmpty
            ? const Icon(Icons.inventory_2_outlined, color: Colors.white54)
            : null,
      ),
      title: Text(item.title, style: const TextStyle(color: Colors.white)),
      subtitle: Text("${item.price.toStringAsFixed(2)} ${item.currency}",
          style: const TextStyle(color: Colors.white54)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
            onPressed: item.quantity > 1
                ? () => notifier.updateQuantity(item.id, item.quantity - 1)
                : () => notifier.removeItem(item.id),
          ),
          Text("${item.quantity}", style: const TextStyle(color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
            onPressed: () => notifier.updateQuantity(item.id, item.quantity + 1),
          ),
        ],
      ),
    );
  }
}
