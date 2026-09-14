import 'package:flutter/material.dart';
import '../../models/feed_card/feed_card.dart';

/// `VerticalCardFeed`'in dışarıdaki `PageController`'ını, kart içeriğinin
/// derinliklerindeki widget'lara (ör. `PageAwareScrollView`) açan
/// InheritedWidget. Amaç: bir kartın içindeki iç dikey kaydırma alanı,
/// kendi sınırına (en üst/en alt) ulaştığında "bir sonraki/önceki karta
/// geç" komutunu buradan tetikleyebilsin — kart görünümlerinin PageView'ın
/// nasıl kurulduğuyla hiç ilgilenmesine gerek kalmadan (bkz.
/// page_aware_scroll_view.dart).
class VerticalFeedController extends InheritedWidget {
  final PageController pageController;
  final int itemCount;

  const VerticalFeedController({
    super.key,
    required this.pageController,
    required this.itemCount,
    required super.child,
  });

  static VerticalFeedController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VerticalFeedController>();
  }

  /// Aktif karttan bir sonrakine, sayfa kaydırma jestiyle aynı animasyon
  /// hissini veren yumuşak bir geçişle atlar. Son karttaysa hiçbir şey
  /// yapmaz (döngü/sıçrama yok).
  void nextPage({
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
  }) {
    final current = pageController.page?.round() ?? 0;
    if (current >= itemCount - 1) return;
    pageController.animateToPage(current + 1, duration: duration, curve: curve);
  }

  /// Aktif karttan bir öncekine yumuşak geçiş yapar. İlk karttaysa
  /// hiçbir şey yapmaz.
  void previousPage({
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
  }) {
    final current = pageController.page?.round() ?? 0;
    if (current <= 0) return;
    pageController.animateToPage(current - 1, duration: duration, curve: curve);
  }

  @override
  bool updateShouldNotify(covariant VerticalFeedController oldWidget) {
    return pageController != oldWidget.pageController ||
        itemCount != oldWidget.itemCount;
  }
}

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

    return VerticalFeedController(
      pageController: _controller,
      itemCount: widget.cards.length,
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemCount: widget.cards.length,
        onPageChanged: _handlePageChanged,
        itemBuilder: (context, index) {
          final isActive = index == _activeIndex;
          return widget.cardBuilder(context, widget.cards[index], isActive);
        },
      ),
    );
  }
}