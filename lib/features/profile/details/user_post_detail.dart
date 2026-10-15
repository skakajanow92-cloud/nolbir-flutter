import 'package:flutter/material.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';

const _postAccent = Color(0xFF3E4A5A);

String _basename(String path) => path.split(RegExp(r'[\\/]')).last;

/// Kullanıcı gönderisinin masaüstü detay paneli görünümü.
Widget buildUserPostDetail(BuildContext context, UserPostCard card) {
  return DetailPage(
    title: 'Gönderi',
    subtitle: card.caption.isEmpty ? null : card.caption,
    icon: Icons.image_outlined,
    accent: _postAccent,
    children: [
      DetailSection(
        title: 'Açıklama',
        children: [
          card.caption.isEmpty
              ? const DetailEmpty('Açıklama yok')
              : DetailParagraph(card.caption),
        ],
      ),
      if (card.mediaUrl.isNotEmpty)
        DetailSection(
          title: 'Medya',
          spacing: 0,
          children: [
            DetailRow(label: 'Dosya', value: _basename(card.mediaUrl)),
          ],
        ),
    ],
  );
}
