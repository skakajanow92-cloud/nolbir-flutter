import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';

const _accent = Color(0xFF4A4A8A);

/// Abonelik kartının masaüstü detay paneli görünümü.
Widget buildSubscriptionDetail(BuildContext context, SubscriptionCard card) {
  return DetailPage(
    title: card.serviceName,
    subtitle: 'Abonelik',
    icon: Icons.workspace_premium_outlined,
    accent: _accent,
    children: [
      DetailSection(
        title: 'Abonelik Bilgileri',
        spacing: 0,
        children: [
          DetailRow(
            label: 'Aylık ücret',
            value: '${formatMoney(card.monthlyPrice, decimals: 2)} TRY',
            emphasize: true,
          ),
        ],
      ),
      DetailSection(
        title: 'Açıklama',
        children: [
          card.description.isEmpty
              ? const DetailEmpty('Açıklama yok')
              : DetailParagraph(card.description),
        ],
      ),
    ],
  );
}
