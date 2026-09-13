import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/discovery_repository.dart';
import '../../../models/feed_card.dart';

part 'discovery_providers.g.dart';

/// Repository'yi enjekte eden provider. Test ederken veya gerçek API'ye
/// geçerken burada `overrideWithValue` ile mock/gerçek repository'yi
/// değiştirebilirsin — geri kalan hiçbir şeye dokunmadan.
@riverpod
DiscoveryRepository discoveryRepository(Ref ref) {
  return MockDiscoveryRepository();
}

/// Orta tab'ın state'i: kart listesi + sayfalama.
/// `VerticalCardFeed.onReachEnd` bu notifier'ın `loadMore()` metodunu çağırır.
@riverpod
class DiscoveryFeed extends _$DiscoveryFeed {
  static const _pageSize = 10;

  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<FeedCard>> build() async {
    _page = 0;
    _hasMore = true;
    final repo = ref.watch(discoveryRepositoryProvider);
    return repo.fetchFeed(page: _page, pageSize: _pageSize);
  }

  /// Listenin sonuna yaklaşıldığında yeni sayfa çeker ve mevcut listeye ekler.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final current = state.value;
    if (current == null) return; // ilk yükleme bitmeden pagination tetiklenmesin

    _isLoadingMore = true;
    try {
      final repo = ref.read(discoveryRepositoryProvider);
      final nextPage = _page + 1;
      final newCards = await repo.fetchFeed(page: nextPage, pageSize: _pageSize);

      if (newCards.isEmpty) {
        _hasMore = false;
      } else {
        _page = nextPage;
        state = AsyncData([...current, ...newCards]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Aşağı çekince yenileme (pull-to-refresh) için.
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(discoveryRepositoryProvider).fetchFeed(page: 0, pageSize: _pageSize),
    );
  }
}
