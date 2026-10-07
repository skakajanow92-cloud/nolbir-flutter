import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'nav_arrow_buttons.dart';
import 'channel_videos_dialog.dart';
import 'video_format_utils.dart';

class YoutubeFeedCardView extends StatefulWidget {
  final YoutubeFeedCard card;

  const YoutubeFeedCardView({super.key, required this.card});

  @override
  State<YoutubeFeedCardView> createState() => _YoutubeFeedCardViewState();
}

class _YoutubeFeedCardViewState extends State<YoutubeFeedCardView> {
  late List<LongVideoItem> _videos;
  final ScrollController _scrollController = ScrollController();
  int _generatedCount = 0;

  @override
  void initState() {
    super.initState();
    _videos = List.of(widget.card.seedVideos);
    _generatedCount = _videos.length;
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_maybeLoadMore);
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 800;
    if (_scrollController.position.pixels >= threshold) {
      setState(() {
        _videos.addAll(_generateMoreVideos(widget.card, _generatedCount, 6));
        _generatedCount += 6;
      });
    }
  }

  void _openChannel(YoutubeChannel channel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChannelVideosDialog(channel: channel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: const Color(0xFF0F0F0F),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _SubscribedChannelsRow(
                    channels: widget.card.subscribedChannels,
                    onTapChannel: _openChannel,
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      itemCount: _videos.length,
                      itemBuilder: (context, i) => _VideoCard(
                        video: _videos[i],
                        onTapChannel: () => _openChannel(_videos[i].channel),
                      ),
                    ),
                  ),
                ],
              ),
              const NavArrowOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

List<LongVideoItem> _generateMoreVideos(
  YoutubeFeedCard card,
  int startIndex,
  int count,
) {
  final rnd = Random(card.id.hashCode + startIndex);
  const titles = [
    "Bunu izlemeden geçme",
    "15 dakikada her şey",
    "Deneyim paylaşımı",
    "Günün özeti",
    "Baştan sona anlatım",
    "Kısa bir belgesel",
  ];
  final channels = card.subscribedChannels.isNotEmpty
      ? card.subscribedChannels
      : const [YoutubeChannel(id: "ch0", name: "Kanal")];

  return List.generate(count, (i) {
    final n = startIndex + i;
    final channel = channels[rnd.nextInt(channels.length)];
    return LongVideoItem(
      id: "feedvid_${card.id}_$n",
      title: titles[rnd.nextInt(titles.length)],
      channel: channel,
      duration: Duration(
        minutes: 1 + rnd.nextInt(40),
        seconds: rnd.nextInt(60),
      ),
      viewCount: 50 + rnd.nextInt(2000000),
      uploadedAt: DateTime.now().subtract(
        Duration(hours: rnd.nextInt(24 * 30)),
      ),
    );
  });
}

class _SubscribedChannelsRow extends StatelessWidget {
  final List<YoutubeChannel> channels;
  final ValueChanged<YoutubeChannel> onTapChannel;
  const _SubscribedChannelsRow({
    required this.channels,
    required this.onTapChannel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final channel = channels[i];
          return GestureDetector(
            onTap: () => onTapChannel(channel),
            child: SizedBox(
              width: 56,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    child: channel.avatarUrl.isEmpty
                        ? Text(
                            channel.name.isNotEmpty
                                ? channel.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(color: Colors.white),
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
                  const SizedBox(height: 4),
                  Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final LongVideoItem video;
  final VoidCallback onTapChannel;
  const _VideoCard({required this.video, required this.onTapChannel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.white.withValues(alpha: 0.05),
                  child: video.thumbnailUrl.isEmpty
                      ? const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white24,
                          size: 48,
                        )
                      : Image.network(video.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formatDuration(video.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTapChannel,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    child: video.channel.avatarUrl.isEmpty
                        ? Text(
                            video.channel.name.isNotEmpty
                                ? video.channel.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          )
                        : ClipOval(
                            child: Image.network(
                              video.channel.avatarUrl,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onTapChannel,
                        child: Text(
                          video.channel.name,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        "${formatCompactCount(video.viewCount)} görüntülenme · ${formatTimeAgo(video.uploadedAt)}",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white38, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
