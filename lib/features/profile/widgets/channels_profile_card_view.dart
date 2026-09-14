import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/channel.dart';

/// Kanallar Profili — onuncu profil modülü.
///
/// TASARIM NOTU: Bu modül Wallet'taki "birden fazla hesap" desenini
/// izliyor — kullanıcı birden fazla kanala sahip olabilir, her kanalın
/// kendi abone/izlenme/video/yorum verisi var. Kanal yönetimi (video
/// listesi + yorum moderasyonu) Insurance modülündeki
/// `PolicyDetailSheet` presedanıyla aynı mantıkla bir detay sheet'te
/// yapılıyor — mini karta dokununca açılıyor.
///
/// Modül vurgu rengi: kızıl-turuncu — Tanışma modülünün pembe-gülünden
/// (0xFFB23A56) bilerek farklı ton ailesi, "yayın/içerik" hissi.
class ChannelsProfileCardView extends StatelessWidget {
  final ChannelsProfileCard card;

  const ChannelsProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFFB8451F);
  static const _base = Color(0xFF150F0C);
  static const _baseEnd = Color(0xFF1E1612);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Header(card: card),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsGrid(card: card),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Kanallarım (${card.channels.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: card.channels.isEmpty
                    ? const _EmptyHint(text: "Henüz kanal oluşturulmadı")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: card.channels.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) =>
                            _ChannelMiniCard(channel: card.channels[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ChannelsProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.subscriptions_outlined,
                color: ChannelsProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Kanallar", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${card.channels.length} kanal",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ChannelsProfileCard card;
  const _StatsGrid({required this.card});

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String)>[
      ("Abone", _formatCompact(card.totalSubscribers)),
      ("İzlenme", _formatCompact(card.totalViews)),
      ("Video", "${card.totalVideos}"),
      ("İncelenmemiş", "${card.totalUnreviewedComments}"),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: stats.map((s) => _StatChip(label: s.$1, value: s.$2)).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: ChannelsProfileCardView.moduleAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ChannelsProfileCardView.moduleAccent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      ),
    );
  }
}

class _ChannelMiniCard extends StatelessWidget {
  final Channel channel;
  const _ChannelMiniCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    final color = _channelColor(channel.name);
    final unreviewed = channel.unreviewedCommentCount;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color,
                  child: Text(
                    channel.name.isNotEmpty ? channel.name[0].toUpperCase() : "?",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (channel.category.isNotEmpty)
              Text(channel.category,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const Spacer(),
            Text(
              "${_formatCompact(channel.subscriberCount)} abone",
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text("${channel.videoCount} video · ${_formatCompact(channel.totalViews)} izlenme",
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            if (unreviewed > 0) ...[
              const SizedBox(height: 8),
              _UnreviewedBadge(count: unreviewed),
            ],
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1612),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChannelDetailSheet(channel: channel),
    );
  }
}

class _UnreviewedBadge extends StatelessWidget {
  final int count;
  const _UnreviewedBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0A030).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$count yorum incelenmedi",
        style: const TextStyle(
            color: Color(0xFFE0A030), fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Kanal mini kartına dokununca açılan tam detay — video listesi ve
/// yorum moderasyonu (bkz. InsuranceProfileCardView'daki
/// PolicyDetailSheet presedanı).
class ChannelDetailSheet extends StatelessWidget {
  final Channel channel;
  const ChannelDetailSheet({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final videos = channel.videosByRecency;
    final comments = channel.pendingComments;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      channel.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              if (channel.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(channel.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
              const SizedBox(height: 20),
              Text("Videolar (${videos.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              if (videos.isEmpty)
                const Text("Henüz video paylaşılmadı",
                    style: TextStyle(color: Colors.white38, fontSize: 13))
              else
                ...videos.map((v) => _VideoRow(video: v)),
              const SizedBox(height: 24),
              Text("Yorumlar (${comments.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              if (comments.isEmpty)
                const Text("Henüz yorum yok",
                    style: TextStyle(color: Colors.white38, fontSize: 13))
              else
                ...comments.map((c) => _CommentRow(comment: c)),
            ],
          ),
        );
      },
    );
  }
}

class _VideoRow extends StatelessWidget {
  final ChannelVideo video;
  const _VideoRow({required this.video});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.play_arrow, color: Colors.white38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  "${_formatCompact(video.viewCount)} izlenme · "
                  "${video.commentCount} yorum · ${_formatDuration(video.duration)}",
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final ChannelComment comment;
  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("@${comment.authorUsername}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(comment.videoTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!comment.isReviewed)
            const Icon(Icons.flag_outlined, color: Color(0xFFE0A030), size: 16),
        ],
      ),
    );
  }
}

// Kanal başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _channelPalette = <Color>[
  Color(0xFF5A2E1F),
  Color(0xFF5A4E1F),
  Color(0xFF3E4A5A),
  Color(0xFF4A3E5A),
];

Color _channelColor(String name) {
  final index = name.hashCode.abs() % _channelPalette.length;
  return _channelPalette[index];
}

String _formatCompact(int value) {
  if (value >= 1000000) return "${(value / 1000000).toStringAsFixed(1)}M";
  if (value >= 1000) return "${(value / 1000).toStringAsFixed(1)}B";
  return "$value";
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return "$minutes:${seconds.toString().padLeft(2, '0')}";
}
