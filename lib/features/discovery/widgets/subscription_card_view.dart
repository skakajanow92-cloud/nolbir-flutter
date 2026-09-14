import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/cart.dart';
import '../../cart/application/cart_providers.dart';
import '../../collection/widgets/save_to_collection_button.dart';

class SubscriptionCardView extends ConsumerWidget {
  final SubscriptionCard card;

  const SubscriptionCardView({super.key, required this.card});

  Future<void> _subscribe(BuildContext context, WidgetRef ref) async {
    // Abone olmak da aslında "subscriptions" sepetine eklemek — checkout
    // akışı diğer sepet türleriyle aynı motoru (CartDetail) kullanıyor.
    await ref.read(cartDetailProvider(CartType.subscription).notifier).addItem(
          CartItem(
            id: card.id,
            cartType: CartType.subscription,
            title: card.serviceName,
            price: card.monthlyPrice,
            metadata: {"billing": "monthly"},
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${card.serviceName} abonelik sepetine eklendi"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardShell(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade900, Colors.black],
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.workspace_premium, color: Colors.white38, size: 80),
      ),
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.serviceName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 6),
          Text(card.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 6),
          Text("${card.monthlyPrice} TRY / ay",
              style: const TextStyle(color: Colors.amberAccent, fontSize: 15)),
        ],
      ),
      actions: [
        CardActionButton(
          icon: Icons.workspace_premium,
          label: "Abone ol",
          onTap: () => _subscribe(context, ref),
        ),
        SaveToCollectionButton(card: card),
      ],
    );
  }
}
