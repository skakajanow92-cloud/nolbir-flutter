import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/engagement.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/engagement_profile_card_view.dart';

/// Etkileşim modülünün masaüstü detay paneli görünümü: tam sayılarla özet, referanslar, tartışmalar.
Widget buildEngagementDetail(BuildContext context, EngagementProfileCard card) {
  const accent = EngagementProfileCardView.moduleAccent;
  final s = card.summary;
  return DetailPage(
    title: 'Etkileşim',
    subtitle:
        '${formatInt(s.followerCount)} takipçi · ${formatInt(s.followingCount)} takip',
    icon: Icons.insights_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Özet',
        spacing: 0,
        children: [
          DetailRow(label: 'Gönderi', value: formatInt(s.totalPosts)),
          DetailRow(label: 'İzlenim', value: formatInt(s.totalImpressions)),
          DetailRow(label: 'Yorum', value: formatInt(s.totalComments)),
          DetailRow(label: 'Tartışma', value: formatInt(s.totalReplies)),
          DetailRow(label: 'Referans', value: formatInt(s.totalReferrals)),
        ],
      ),
      DetailSection(
        title: 'Referanslar & Tavsiyeler (${card.referrals.length})',
        children: [
          if (card.referrals.isEmpty)
            const DetailEmpty('Henüz referans/tavsiye yok'),
          for (final r in card.referrals)
            DetailItem(
              accent: accent,
              icon: Icons.alternate_email,
              title: '@${r.fromUsername}',
              subtitle: r.type.label,
              rows: [
                if (r.note != null) DetailParagraph(r.note!),
                DetailRow(label: 'Tarih', value: formatDate(r.date)),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'En Çok Tartışılan Gönderiler (${card.topDiscussions.length})',
        children: [
          if (card.topDiscussions.isEmpty)
            const DetailEmpty('Henüz yorum/tartışma yok'),
          for (final d in card.topDiscussions)
            DetailItem(
              accent: accent,
              icon: Icons.forum_outlined,
              title: d.postCaption,
              rows: [
                DetailRow(label: 'Yorum', value: formatInt(d.commentCount)),
                DetailRow(label: 'Tartışma', value: formatInt(d.replyCount)),
                DetailRow(
                  label: 'İzlenim',
                  value: formatInt(d.impressionCount),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}
