import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/channel.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/channels_profile_card_view.dart';
import 'profile_detail_common.dart';

const _pendingColor = Color(0xFFE0A030);

/// Kanallar modülünün masaüstü detay paneli görünümü: her kanalın bilgisi,
/// ardından o kanalın videoları ve yorumları — mobildeki kanal detay
/// sayfasının kalıcı hâli.
Widget buildChannelsDetail(BuildContext context, ChannelsProfileCard card) {
  const accent = ChannelsProfileCardView.moduleAccent;

  return DetailPage(
    title: 'Kanallar',
    subtitle:
        '${formatInt(card.totalSubscribers)} abone · ${card.channels.length} kanal',
    icon: Icons.ondemand_video_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Özet',
        spacing: 0,
        children: [
          DetailRow(label: 'Toplam abone', value: formatInt(card.totalSubscribers)),
          DetailRow(label: 'Toplam izlenme', value: formatInt(card.totalViews)),
          DetailRow(label: 'Toplam video', value: formatInt(card.totalVideos)),
          DetailRow(
              label: 'İncelenmemiş yorum',
              value: formatInt(card.totalUnreviewedComments)),
        ],
      ),
      DetailSection(
        title: 'Kanallarım (${card.channels.length})',
        children: [
          if (card.channels.isEmpty) const DetailEmpty('Henüz kanal oluşturulmadı'),
          for (final c in card.channels) _channelItem(c, accent),
        ],
      ),
      for (final c in card.channels) ...[
        if (c.videos.isNotEmpty)
          DetailSection(
            title: '${c.name} · Videolar (${c.videoCount})',
            children: [for (final v in c.videosByRecency) _videoItem(v, accent)],
          ),
        if (c.pendingComments.isNotEmpty)
          DetailSection(
            title: '${c.name} · Yorumlar (${c.pendingComments.length})',
            children: [for (final cm in c.pendingComments) _commentItem(cm, accent)],
          ),
      ],
    ],
  );
}

Widget _channelItem(Channel c, Color accent) {
  final unreviewed = c.unreviewedCommentCount;
  return DetailItem(
    accent: accent,
    icon: Icons.ondemand_video_outlined,
    title: c.name,
    subtitle: c.category.isEmpty ? null : c.category,
    badge: unreviewed > 0
        ? DetailBadge(label: '$unreviewed yorum bekliyor', color: _pendingColor)
        : null,
    rows: [
      DetailRow(label: 'Abone', value: formatInt(c.subscriberCount)),
      DetailRow(label: 'İzlenme', value: formatInt(c.totalViews)),
      DetailRow(label: 'Video', value: formatInt(c.videoCount)),
      DetailRow(label: 'Oluşturulma', value: formatDate(c.createdDate)),
      if (c.description.isNotEmpty) DetailParagraph(c.description),
    ],
  );
}

Widget _videoItem(ChannelVideo v, Color accent) {
  return DetailItem(
    accent: accent,
    icon: Icons.play_circle_outline,
    title: v.title,
    subtitle: '${formatClock(v.duration)} · ${formatDate(v.publishedDate)}',
    rows: [
      DetailRow(label: 'İzlenme', value: formatInt(v.viewCount)),
      DetailRow(
          label: 'Yorum / Beğeni',
          value: '${formatInt(v.commentCount)} / ${formatInt(v.likeCount)}'),
    ],
  );
}

Widget _commentItem(ChannelComment c, Color accent) {
  return DetailItem(
    accent: accent,
    icon: c.isReviewed ? Icons.check_circle_outline : Icons.flag_outlined,
    title: '@${c.authorUsername}',
    subtitle: c.videoTitle,
    badge: c.isReviewed
        ? const DetailBadge(label: 'İncelendi', color: detailOk)
        : const DetailBadge(label: 'Bekliyor', color: _pendingColor),
    rows: [
      DetailParagraph(c.text),
      DetailRow(label: 'Tarih', value: formatDate(c.date)),
    ],
  );
}
