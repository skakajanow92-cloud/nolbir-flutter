import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'constrained_feed_column.dart';
import 'detail_panel.dart';
import 'feed_activity.dart';

/// Alt çubuk / yan rail'deki tek bir hedef.
class ShellDestination {
  final IconData icon;
  final String label;

  const ShellDestination({required this.icon, required this.label});
}

/// Ekran genişliğine göre yerleşimi seçen kabuk:
///  - compact:        tam ekran feed + alt tab çubuğu (telefon, eski davranış)
///  - rail:           yan NavigationRail + 430px'lik ortalanmış feed sütunu
///  - railWithDetail: rail + feed sütunu + aktif karta bağlı detay paneli
///
/// Tab'lar ve tab seçimi dışarıdan verilir; bu widget sadece yerleşimden
/// sorumludur.
class AdaptiveShell extends StatefulWidget {
  final List<Widget> tabs;
  final List<ShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const AdaptiveShell({
    super.key,
    required this.tabs,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  final FeedActivityTracker _tracker = FeedActivityTracker();

  // Sabit GlobalKey: pencere bir kırılım noktasını geçip yerleşim modu
  // değiştiğinde tab yığını (ve içindeki her feed'in sayfa konumu, video
  // durumu) yeni yerine TAŞINIR; sıfırdan kurulup state kaybedilmez.
  final GlobalKey _tabStackKey = GlobalKey(debugLabel: 'shell_tab_stack');

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  Widget _buildTabStack() {
    return IndexedStack(
      key: _tabStackKey,
      index: widget.currentIndex,
      children: [
        for (var i = 0; i < widget.tabs.length; i++)
          FeedTabScope(tabIndex: i, tracker: _tracker, child: widget.tabs[i]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = AppLayout.modeFor(constraints.biggest);
        return mode == ShellMode.compact
            ? _buildCompact()
            : _buildWide(showDetail: mode == ShellMode.railWithDetail);
      },
    );
  }

  Widget _buildCompact() {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: _buildTabStack(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: widget.currentIndex,
        onTap: widget.onSelected,
        items: [
          for (final d in widget.destinations)
            BottomNavigationBarItem(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }

  Widget _buildWide({required bool showDetail}) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            backgroundColor: Colors.black,
            selectedIndex: widget.currentIndex,
            onDestinationSelected: widget.onSelected,
            labelType: NavigationRailLabelType.all,
            indicatorColor: Colors.white12,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedIconTheme: const IconThemeData(color: Colors.white38),
            selectedLabelTextStyle: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelTextStyle:
                const TextStyle(color: Colors.white38, fontSize: 12),
            destinations: [
              for (final d in widget.destinations)
                NavigationRailDestination(
                    icon: Icon(d.icon), label: Text(d.label)),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1, color: Colors.white10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, area) {
                final feedWidth =
                    math.min(AppLayout.feedColumnWidth, area.maxWidth);
                var groupWidth = feedWidth;
                if (showDetail) {
                  final room = area.maxWidth -
                      feedWidth -
                      AppLayout.panelGap -
                      2 * AppLayout.outerPadding;
                  final detailWidth = math.max(
                    AppLayout.detailMinWidth,
                    math.min(AppLayout.detailMaxWidth, room),
                  );
                  groupWidth = feedWidth + AppLayout.panelGap + detailWidth;
                }

                return Center(
                  child: SizedBox(
                    width: groupWidth,
                    height: area.maxHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: feedWidth,
                          child: ConstrainedFeedColumn(child: _buildTabStack()),
                        ),
                        if (showDetail) ...[
                          const SizedBox(width: AppLayout.panelGap),
                          Expanded(
                            child: DetailPanel(
                              tracker: _tracker,
                              tabIndex: widget.currentIndex,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
