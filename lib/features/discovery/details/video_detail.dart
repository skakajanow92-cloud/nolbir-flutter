import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';

const _accent = Color(0xFF7A3E5C);

/// Video kartının masaüstü detay paneli görünümü.
Widget buildVideoDetail(BuildContext context, VideoCard card) {
  return DetailPage(
    title: '@${card.username}',
    subtitle: 'Video',
    icon: Icons.play_circle_outline,
    accent: _accent,
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
