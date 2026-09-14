import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../core/cart/cart_visuals.dart';
import '../../../core/cart/cart_item_registry.dart';
import '../../../models/cart.dart';
import '../../../models/feed_card/feed_card.dart';
import '../application/cart_providers.dart';

/// Profil akışındaki tam ekran sepet özeti.
/// Hiçbir yerinde `if (cartType == CartType.market)` gibi bir dallanma YOK —
/// ikon/renk/başlık `CartVisuals.of()`'tan geliyor, bu sayede kayıt
/// listesinde olmayan (gelecekte eklenecek) bir sepet türü bile otomatik
/// olarak makul bir görünümle çalışır.
class CartSummaryCardView extends StatelessWidget {
  final CartSummaryCard card;

  const CartSummaryCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final meta = CartVisuals.of(card.cartType);

    return CardShell(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [meta.color.withOpacity(0.45), Colors.black],
          ),
        ),
        alignment: Alignment.center,
        child: Icon(meta.icon, color: Colors.white38, size: 88),
      ),
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meta.displayName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          Text("${card.itemCount} ürün · ${card.subtotal.toStringAsFixed(2)} ${card.currency}",
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
      actions: [
        CardActionButton(
          icon: Icons.shopping_cart_checkout,
          label: "Sepeti aç",
          onTap: () => _openCartDetail(context),
        ),
      ],
    );
  }

  void _openCartDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CartDetailSheet(cartType: card.cartType),
    );
  }
}

/// Sepet detayı: kalemleri listeler, her kalem için tür-agnostik
/// `CartItemRegistry.build()` çağrılır — özel builder kayıtlıysa o kullanılır,
/// yoksa `DefaultCartItemTile` devreye girer.
class _CartDetailSheet extends ConsumerWidget {
  final CartType cartType;

  const _CartDetailSheet({required this.cartType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartDetailProvider(cartType));
    final meta = CartVisuals.of(cartType);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return cartAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const Center(
            child: Text("Sepet yüklenemedi", style: TextStyle(color: Colors.white70)),
          ),
          data: (cart) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(meta.icon, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(meta.displayName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              Expanded(
                child: cart.items.isEmpty
                    ? const Center(
                        child: Text("Sepet boş", style: TextStyle(color: Colors.white54)),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: cart.items.length,
                        itemBuilder: (context, i) =>
                            CartItemRegistry.build(context, cart.items[i]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Toplam: ${cart.subtotal.toStringAsFixed(2)} TRY",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ElevatedButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              // TODO: cartType'a göre checkout/ödeme akışı
                            },
                      child: const Text("Öde"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
