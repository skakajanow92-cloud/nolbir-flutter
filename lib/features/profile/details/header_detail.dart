import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/profile_header_card_view.dart';

String _orDash(String s) => s.isEmpty ? '—' : s;

/// Temel Bilgiler kartının masaüstü detay paneli görünümü.
Widget buildProfileHeaderDetail(BuildContext context, ProfileHeaderCard card) {
  return DetailPage(
    title: card.fullName.isEmpty ? '@${card.username}' : card.fullName,
    subtitle: '@${card.username}',
    icon: Icons.person_outline,
    accent: ProfileHeaderCardView.accent,
    children: [
      DetailSection(
        title: 'Temel Bilgiler',
        spacing: 0,
        children: [
          DetailRow(label: 'Ülke', value: _orDash(card.country)),
          DetailRow(label: 'Cinsiyet', value: _orDash(card.gender)),
          DetailRow(label: 'Takipçi', value: formatInt(card.followerCount)),
        ],
      ),
      DetailSection(
        title: 'Biyografi',
        children: [
          card.bio.isEmpty
              ? const DetailEmpty('Henüz biyografi eklenmedi')
              : DetailParagraph(card.bio),
        ],
      ),
    ],
  );
}
