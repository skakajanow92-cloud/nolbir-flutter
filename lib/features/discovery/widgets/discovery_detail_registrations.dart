import 'package:flutter/material.dart';
import '../../../core/layout/card_detail_registry.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/detail_kit.dart';
import '../../../models/feed_card/feed_card.dart';

const _videoAccent = Color(0xFF7A3E5C);
const _productAccent = Color(0xFF2F5C4E);
const _subscriptionAccent = Color(0xFF4A4A8A);

/// Genel Akış (Discovery) kartlarının masaüstü detay paneli görünümleri.
void registerDiscoveryCardDetails() {
  CardDetailRegistry.register<VideoCard>(_videoDetail);
  CardDetailRegistry.register<ProductCard>(_productDetail);
  CardDetailRegistry.register<SubscriptionCard>(_subscriptionDetail);
}

Widget _videoDetail(BuildContext context, VideoCard card) {
  return DetailPage(
    title: '@${card.username}',
    subtitle: 'Video',
    icon: Icons.play_circle_outline,
    accent: _videoAccent,
    children: [
      DetailSection(
        title: 'Video',
        spacing: 0,
        children: [
          DetailRow(label: 'Paylaşan', value: '@${card.username}'),
          DetailRow(label: 'Beğeni', value: formatInt(card.likeCount)),
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

Widget _productDetail(BuildContext context, ProductCard card) {
  return DetailPage(
    title: card.title,
    subtitle: 'Ürün',
    icon: Icons.shopping_bag_outlined,
    accent: _productAccent,
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

Widget _subscriptionDetail(BuildContext context, SubscriptionCard card) {
  return DetailPage(
    title: card.serviceName,
    subtitle: 'Abonelik',
    icon: Icons.workspace_premium_outlined,
    accent: _subscriptionAccent,
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
