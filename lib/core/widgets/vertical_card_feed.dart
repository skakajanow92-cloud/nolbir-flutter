import 'package:flutter/material.dart';
import '../../models/feed_card.dart';

/// TikTok tarzı dikey kaydırılan kart motoru.
/// Üç tab da bu widget'ı kullanır; fark sadece verilen `cards` listesi
/// ve `cardBuilder` fonksiyonunun ürettiği görünümdür.
///
/// Kullanım:
/// ```dart
/// VerticalCardFeed(
///   cards: discoveryCards,
///   cardBuilder: buildFeedCard,
///   onPageChanged: (index) => ...,
/// )
/// ```
class VerticalCardFeed extends StatefulWidget {
  final List<FeedCard> cards;
  final Widget Function(BuildContext context, FeedCard card, bool isActive) cardBuilder;
  final void Function(int index)? onPageChanged;
  final VoidCallback? onReachEnd; // sonsuz kaydırma / pagination tetikleyici
  final int loadMoreThreshold;

  const VerticalCardFeed({
    super.key,
    required this.cards,
    required this.cardBuilder,
    this.onPageChanged,
    this.onReachEnd,
    this.loadMoreThreshold = 3,
  });

  @override
  State<VerticalCardFeed> createState() => _VerticalCardFeedState();
}

class _VerticalCardFeedState extends State<VerticalCardFeed>
    with AutomaticKeepAliveClientMixin {
  late final PageController _controller;
  int _activeIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    setState(() => _activeIndex = index);
    widget.onPageChanged?.call(index);

    // Sona yaklaşınca yeni veri çekme sinyali ver (pagination)
    if (widget.onReachEnd != null &&
        index >= widget.cards.length - widget.loadMoreThreshold) {
      widget.onReachEnd!();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
      controller: _controller,
      scrollDirection: Axis.vertical,
      itemCount: widget.cards.length,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        final isActive = index == _activeIndex;
        return widget.cardBuilder(context, widget.cards[index], isActive);
      },
    );
  }
}
