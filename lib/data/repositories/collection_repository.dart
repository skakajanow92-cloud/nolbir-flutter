import '../../models/feed_card.dart';

/// Sağ tab (Koleksiyon) veri kaynağı sözleşmesi.
/// Koleksiyon kullanıcı tarafından değiştirilebilir olduğu için
/// add/remove metotları da burada.
abstract class CollectionRepository {
  Future<List<CollectionItemCard>> fetchCollection();
  Future<void> addToCollection(CollectionItemCard item);
  Future<void> removeFromCollection(String itemId);
}

class MockCollectionRepository implements CollectionRepository {
  // Gerçek uygulamada bu bir local db (hive/sqlite) veya API olurdu.
  final List<CollectionItemCard> _items = [
    CollectionItemCard(
      id: "c1",
      title: "Kaydedilen video",
      previewUrl: "",
      originalCard: const VideoCard(
        id: "v1",
        videoUrl: "",
        username: "ahmet",
        description: "Örnek video açıklaması",
      ),
    ),
  ];

  @override
  Future<List<CollectionItemCard>> fetchCollection() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_items);
  }

  @override
  Future<void> addToCollection(CollectionItemCard item) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _items.add(item);
  }

  @override
  Future<void> removeFromCollection(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _items.removeWhere((e) => e.id == itemId);
  }
}
