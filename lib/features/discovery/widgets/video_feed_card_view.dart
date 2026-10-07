import 'dart:math';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../models/product_card/product_card.dart';
import 'nav_arrow_buttons.dart';

class VideoFeedCardView extends StatefulWidget {
  final VideoFeedCard card;
  final bool isActive;

  const VideoFeedCardView({
    super.key,
    required this.card,
    this.isActive = true,
  });

  @override
  State<VideoFeedCardView> createState() => _VideoFeedCardViewState();
}

class _VideoFeedCardViewState extends State<VideoFeedCardView> {
  late final PageController _innerController;
  late List<FeedVideoItem> _videos;
  int _innerIndex = 0;
  int _generatedCount = 0;

  @override
  void initState() {
    super.initState();
    _innerController = PageController();
    _videos = List.of(widget.card.seedVideos);
    _generatedCount = _videos.length;
    _ensureFilled();
  }

  @override
  void dispose() {
    _innerController.dispose();
    super.dispose();
  }

  /// "Sonsuz" akış illüzyonu — sosyal akış kartındaki aynı desen.
  void _ensureFilled() {
    if (_videos.length - _innerIndex < 3) {
      _videos.addAll(_generateMoreVideos(widget.card.id, _generatedCount, 5));
      _generatedCount += 5;
    }
  }

  void _onInnerPageChanged(int index) {
    setState(() {
      _innerIndex = index;
      _ensureFilled();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _innerController,
          scrollDirection: Axis.vertical,
          itemCount: _videos.length,
          onPageChanged: _onInnerPageChanged,
          itemBuilder: (context, i) => _FeedVideoPage(
            item: _videos[i],
            // Dış kart isActive DEĞİLSE (başka tab'a geçildiyse) iç
            // video da kesinlikle duraklamalı — sadece iç index eşleşmesi
            // yetmez.
            isActive: widget.isActive && i == _innerIndex,
          ),
        ),
        const NavArrowOverlay(),
      ],
    );
  }
}

List<FeedVideoItem> _generateMoreVideos(
  String cardId,
  int startIndex,
  int count,
) {
  final rnd = Random(cardId.hashCode + startIndex);
  const usernames = [
    "kaan.y",
    "selin_",
    "mertcan",
    "deniz.k",
    "ayseozcan",
    "burak_d",
  ];
  const descriptions = [
    "Bugün bunu deniyorum 👀",
    "Kahkaha garantili 😂",
    "Bunu kaçırma!",
    "Mutfaktan bir deneme",
    "Günün en iyi anı",
  ];
  return List.generate(count, (i) {
    final n = startIndex + i;
    return FeedVideoItem(
      id: "vid_${cardId}_$n",
      videoUrl: "",
      username: usernames[rnd.nextInt(usernames.length)],
      description: descriptions[rnd.nextInt(descriptions.length)],
      likeCount: 50 + rnd.nextInt(8000),
      commentCount: rnd.nextInt(500),
    );
  });
}

/// `VideoCardView`'daki oynatma mantığının aynısı (media_kit Player,
/// isActive'e göre play/pause) — burada iç PageView'a gömülü tek bir
/// sayfa olarak kullanılıyor.
class _FeedVideoPage extends StatefulWidget {
  final FeedVideoItem item;
  final bool isActive;

  const _FeedVideoPage({required this.item, required this.isActive});

  @override
  State<_FeedVideoPage> createState() => _FeedVideoPageState();
}

class _FeedVideoPageState extends State<_FeedVideoPage> {
  Player? _player;
  VideoController? _controller;

  bool get _hasSource => widget.item.videoUrl.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_hasSource) {
      final player = Player();
      _player = player;
      _controller = VideoController(player);
      player
        ..setPlaylistMode(PlaylistMode.single)
        ..open(Media(widget.item.videoUrl), play: widget.isActive);
      if (!widget.isActive) player.pause();
    }
  }

  @override
  void didUpdateWidget(covariant _FeedVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final player = _player;
    if (player != null && widget.isActive != oldWidget.isActive) {
      widget.isActive ? player.play() : player.pause();
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    final player = _player;
    if (player == null) return;
    player.state.playing ? player.pause() : player.play();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _hasSource
              ? Video(
                  controller: _controller!,
                  fit: BoxFit.cover,
                  controls: NoVideoControls,
                )
              : Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.videocam_off,
                    color: Colors.white24,
                    size: 64,
                  ),
                ),
          Positioned(
            left: 16,
            right: 90,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${widget.item.username}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.item.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIcon(
                  icon: Icons.favorite,
                  label: "${widget.item.likeCount}",
                ),
                const SizedBox(height: 18),
                _ActionIcon(
                  icon: Icons.comment,
                  label: "${widget.item.commentCount}",
                ),
                const SizedBox(height: 18),
                const _ActionIcon(icon: Icons.share, label: "Paylaş"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
}
