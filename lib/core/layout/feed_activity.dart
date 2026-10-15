import 'package:flutter/widgets.dart';
import '../../models/feed_card/feed_card.dart';

/// Her tab'ın feed'inde ŞU AN ekranda olan kartı tutar. Detay paneli (ve
/// ileride aktif karta bağlı başka her şey) buradan beslenir.
///
/// Tab başına ayrı tutulur çünkü IndexedStack üç feed'i de canlı tutar —
/// tek bir "aktif kart" olsaydı gizli tab'lar görünür tab'ın kartının
/// üzerine yazardı.
class FeedActivityTracker extends ChangeNotifier {
  final Map<int, FeedCard> _active = {};

  FeedCard? activeFor(int tabIndex) => _active[tabIndex];

  void report(int tabIndex, FeedCard? card) {
    if (card == null) {
      if (_active.remove(tabIndex) != null) notifyListeners();
      return;
    }
    if (identical(_active[tabIndex], card)) return;
    _active[tabIndex] = card;
    notifyListeners();
  }
}

/// Bir tab'ın alt ağacına "sen şu numaralı tab'sın ve aktif kartını şu
/// tracker'a bildir" bilgisini taşır. `VerticalCardFeed` bunu OPSİYONEL
/// olarak okur — scope yoksa (başka bir yerde kullanılıyorsa) hiçbir şey
/// yapmaz, yani feed'i kullanan mevcut kod değişmeden çalışır.
class FeedTabScope extends InheritedWidget {
  final int tabIndex;
  final FeedActivityTracker tracker;

  const FeedTabScope({
    super.key,
    required this.tabIndex,
    required this.tracker,
    required super.child,
  });

  static FeedTabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FeedTabScope>();
  }

  @override
  bool updateShouldNotify(FeedTabScope oldWidget) =>
      tabIndex != oldWidget.tabIndex || tracker != oldWidget.tracker;
}
