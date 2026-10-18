import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'pharmacy_shared.dart';

class PharmacyGridCardView extends StatelessWidget {
  final PharmacyGridCard card;
  const PharmacyGridCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: const Color(0xFF0E1A16),
      baseEndColor: const Color(0xFF14241C),
      header: _Header(card: card),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: card.items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, i) => _GridTile(item: card.items[i]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PharmacyGridCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_pharmacy_outlined,
              color: PharmacyColors.accent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "${card.items.length} ürün",
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          card.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        if (card.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            card.subtitle!,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _GridTile extends StatelessWidget {
  final PharmacyItemCard item;
  const _GridTile({required this.item});

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PharmacyItemDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.white.withValues(alpha: 0.04),
                    child: item.imageUrls.isNotEmpty
                        ? Image.network(item.imageUrls.first, fit: BoxFit.cover)
                        : const Icon(
                            Icons.medication_outlined,
                            color: Colors.white24,
                          ),
                  ),
                  if (item.requiresPrescription)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Reçeteli",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.pharmacyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.itemName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.effectivePrice.toStringAsFixed(0)} ${item.currency}",
                    style: const TextStyle(
                      color: PharmacyColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacyItemDetailSheet extends StatelessWidget {
  final PharmacyItemCard item;
  const _PharmacyItemDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E1A16),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: PharmacyItemContent(item: item),
          ),
        );
      },
    );
  }
}
