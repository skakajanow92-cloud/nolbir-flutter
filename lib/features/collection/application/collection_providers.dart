import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/collection_repository.dart';
import '../../../models/feed_card.dart';

part 'collection_providers.g.dart';

@riverpod
CollectionRepository collectionRepository(Ref ref) {
  return MockCollectionRepository();
}

/// Sağ tab'ın state'i. Diğer tab'lardan farkı: kullanıcı burada
/// veriyi değiştirebiliyor (ekle/çıkar), sadece okumuyor.
@riverpod
class CollectionFeed extends _$CollectionFeed {
  @override
  Future<List<CollectionItemCard>> build() async {
    final repo = ref.watch(collectionRepositoryProvider);
    return repo.fetchCollection();
  }

  /// Örn. discovery/profile tab'larındaki bir karta "kaydet" dendiğinde
  /// başka bir widget'tan `ref.read(collectionFeedProvider.notifier).add(...)`
  /// şeklinde çağrılır.
  Future<void> add(CollectionItemCard item) async {
    final repo = ref.read(collectionRepositoryProvider);
    await repo.addToCollection(item);
    final current = state.value ?? [];
    state = AsyncData([...current, item]);
  }

  Future<void> remove(String itemId) async {
    final repo = ref.read(collectionRepositoryProvider);
    await repo.removeFromCollection(itemId);
    final current = state.value ?? [];
    state = AsyncData(current.where((e) => e.id != itemId).toList());
  }
}
