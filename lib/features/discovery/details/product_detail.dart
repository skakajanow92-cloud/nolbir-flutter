import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';

const _accent = Color(0xFF2F5C4E);

/// Ürün kartının masaüstü detay paneli görünümü.
Widget buildProductDetail(BuildContext context, ProductCard card) {
  return DetailPage(
    title: card.title,
    subtitle: 'Ürün',
    icon: Icons.shopping_bag_outlined,
    accent: _accent,
    children: [
      DetailSection(
        title: 'Ürün Bilgileri',
        spacing: 0,
        children: [
          DetailRow(
            label: 'Fiyat',
            value: '${formatMoney(card.price, decimals: 2)} ${card.currency}',
            emphasize: true,
          ),
          DetailRow(label: 'Sepet türü', value: card.cartType.id),
        ],
      ),
    ],
  );
}
