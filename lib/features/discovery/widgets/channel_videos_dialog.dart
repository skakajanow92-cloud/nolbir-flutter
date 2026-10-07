import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'video_format_utils.dart';

List<LongVideoItem> generateChannelVideos(
  YoutubeChannel channel, {
  int count = 10,
}) {
  final rnd = Random(channel.id.hashCode);
  const titles = [
    "Bu hafta neler oldu?",
    "Adım adım anlatım",
    "İlk defa deniyorum",
    "Soru-cevap bölümü",
    "Kısa bir inceleme",
    "Arkada neler dönüyor?",
  ];
  return List.generate(count, (i) {
    return LongVideoItem(
      id: "${channel.id}_v$i",
      title: titles[rnd.nextInt(titles.length)],
      channel: channel,
      duration: Duration(
        minutes: 2 + rnd.nextInt(28),
        seconds: rnd.nextInt(60),
      ),
      viewCount: 100 + rnd.nextInt(500000),
      uploadedAt: DateTime.now().subtract(
        Duration(days: i * (1 + rnd.nextInt(4))),
      ),
    );
  })..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
}

class ChannelVideosDialog extends StatelessWidget {
  final YoutubeChannel channel;

  const ChannelVideosDialog({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final videos = generateChannelVideos(channel);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F0F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    child: channel.avatarUrl.isEmpty
                        ? Text(
                            channel.name.isNotEmpty
                                ? channel.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          )
                        : ClipOval(
                            child: Image.network(
                              channel.avatarUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "${formatCompactCount(channel.subscriberCount)} abone",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 8),
              for (final video in videos) _ChannelVideoRow(video: video),
            ],
          ),
        );
      },
    );
  }
}

class _ChannelVideoRow extends StatelessWidget {
  final LongVideoItem video;
  const _ChannelVideoRow({required this.video});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 140,
                  height: 79,
                  child: video.thumbnailUrl.isEmpty
                      ? Container(
                          color: Colors.white.withValues(alpha: 0.06),
                          child: const Icon(
                            Icons.play_circle_outline,
                            color: Colors.white24,
                          ),
                        )
                      : Image.network(video.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formatDuration(video.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${formatCompactCount(video.viewCount)} görüntülenme · ${formatTimeAgo(video.uploadedAt)}",
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
