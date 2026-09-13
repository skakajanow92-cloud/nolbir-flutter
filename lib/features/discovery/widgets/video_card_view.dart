import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../models/feed_card.dart';
import '../../collection/widgets/save_to_collection_button.dart';

/// Video kartı görünümü — media_kit ile gerçek video oynatma.
///
/// `isActive` (VerticalCardFeed'den gelir, kullanıcı bu kartta duruyor mu):
///  true  -> oynat
///  false -> duraklat (ekran dışına kaydırılan videolar arka planda çalmasın)
///
/// Kartın kendi Player'ı var; widget dispose olunca (yani karttan tamamen
/// uzaklaşılınca) Player de dispose ediliyor, kaynak sızıntısı olmuyor.
class VideoCardView extends StatefulWidget {
  final VideoCard card;
  final bool isActive;

  const VideoCardView({super.key, required this.card, required this.isActive});

  @override
  State<VideoCardView> createState() => _VideoCardViewState();
}

class _VideoCardViewState extends State<VideoCardView> {
  Player? _player;
  VideoController? _controller;

  bool get _hasSource => widget.card.videoUrl.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_hasSource) {
      final player = Player();
      _player = player;
      _controller = VideoController(player);
      player
        ..setPlaylistMode(PlaylistMode.single) // tek video, bitince tekrar başa sarılabilir
        ..open(Media(widget.card.videoUrl), play: widget.isActive);
      if (!widget.isActive) player.pause();
    }
  }

  @override
  void didUpdateWidget(covariant VideoCardView oldWidget) {
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
    return CardShell(
      background: GestureDetector(
        onTap: _togglePlayPause,
        child: _hasSource
            ? Video(
                controller: _controller!,
                fit: BoxFit.cover,
                controls: NoVideoControls, // kendi CardShell/actions arayüzümüzü kullanıyoruz
              )
            : Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: const Icon(Icons.videocam_off, color: Colors.white24, size: 64),
              ),
      ),
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("@${widget.card.username}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 6),
          Text(widget.card.description,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
      actions: [
        CardActionButton(
          icon: Icons.favorite,
          label: "${widget.card.likeCount}",
          onTap: () {},
        ),
        CardActionButton(icon: Icons.comment, label: "Yorum", onTap: () {}),
        CardActionButton(icon: Icons.share, label: "Paylaş", onTap: () {}),
        SaveToCollectionButton(card: widget.card),
      ],
    );
  }
}
