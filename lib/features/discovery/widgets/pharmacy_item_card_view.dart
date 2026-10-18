import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'ecommerce_shared_widgets.dart';
import 'pharmacy_shared.dart';

class PharmacyItemCardView extends StatelessWidget {
  final PharmacyItemCard card;
  const PharmacyItemCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: const Color(0xFF0E1A16),
      baseEndColor: const Color(0xFF14241C),
      header: _Header(card: card),
      body: PharmacyItemContent(item: card),
    );
  }
}

class _Header extends StatelessWidget {
  final PharmacyItemCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StoreLogo(logoUrl: card.pharmacyLogoUrl, name: card.pharmacyName),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            card.pharmacyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}
