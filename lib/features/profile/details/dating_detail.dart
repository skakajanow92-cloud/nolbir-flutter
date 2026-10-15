import 'package:flutter/material.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/dating.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/dating_profile_card_view.dart';

/// Tanışma modülünün masaüstü detay paneli görünümü: tercihler ve kategoriye göre tüm ilgi alanları.
Widget buildDatingDetail(BuildContext context, DatingProfileCard card) {
  const accent = DatingProfileCardView.moduleAccent;

  // İlgi alanlarını kategoriye göre grupla (ilk görülme sırası korunur).
  final categories = <InterestCategory>[];
  for (final tag in card.interests) {
    if (!categories.contains(tag.category)) categories.add(tag.category);
  }

  return DetailPage(
    title: 'Tanışma Profili',
    subtitle: card.relationshipGoal.label,
    icon: Icons.favorite_outline,
    accent: accent,
    children: [
      DetailSection(
        title: 'Tercihler',
        spacing: 0,
        children: [
          DetailRow(label: 'Yönelim', value: card.sexualOrientation.label),
          DetailRow(label: 'Aranan ilişki', value: card.relationshipGoal.label),
          DetailRow(label: 'Fotoğraf', value: '${card.photoUrls.length}'),
        ],
      ),
      if (card.tagline.isNotEmpty)
        DetailSection(
          title: 'Tanıtım',
          children: [DetailParagraph(card.tagline)],
        ),
      if (categories.isEmpty)
        const DetailSection(
          title: 'İlgi Alanları',
          children: [DetailEmpty('Henüz ilgi alanı eklenmedi')],
        ),
      for (final c in categories)
        DetailSection(
          title: '${c.label} (${card.interestsOf(c).length})',
          children: [
            DetailChips(
              accent: accent,
              labels: [for (final t in card.interestsOf(c)) t.label],
            ),
          ],
        ),
    ],
  );
}
