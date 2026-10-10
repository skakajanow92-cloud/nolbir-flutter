import '../../core/storage/local_store.dart';
import '../../core/storage/storage_boxes.dart';
import '../../models/feed_card/feed_card.dart';
import 'collection_repository.dart';

/// `CollectionRepository`'nin KALICI (Hive tabanlı) implementasyonu.
/// `MockCollectionRepository`'nin yerini alır — provider'da TEK satır
/// değişir (bkz. `collection_providers.dart`), geri kalan hiçbir kod
/// etkilenmez. `ApiClient`/`MediaUploader`'daki "bugün mock, provider'da
/// tek satır değişince gerçek" deseniyle birebir aynı.
///
/// SINIRLAMA (bilinçli, geçici): `originalCard` şu an TAM olarak
/// serileştirilmiyor — sadece tipi ve id'si saklanıyor, uygulama yeniden
/// açıldığında `_RestoredOriginalCard` adında davranışsız bir yer
/// tutucuyla dolduruluyor. Neden: 30+ kart türünün her biri için
/// to/from-JSON yazmak ayrı, kapsamlı bir iş — muhtemelen
/// `CardViewRegistry` ile aynı ilkede bir "kart serileştirme registry'si"
/// gerektirecek. `collection_item_card_view.dart`'taki "Aç" aksiyonu
/// zaten TODO olduğu için bu sınırlama şu an hiçbir şeyi kırmıyor —
/// koleksiyon listesi (başlık/önizleme/silme) uygulama kapanıp açılsa
/// bile tam olarak çalışır.
class LocalCollectionRepository implements CollectionRepository {
  static const _listKey = 'items';

  Future<LocalStore> get _store => LocalStore.open(StorageBoxes.collection);

  @override
  Future<List<CollectionItemCard>> fetchCollection() async {
    final store = await _store;
    final raw = store.read<List>(_listKey) ?? const [];
    return raw
        .map((e) => _fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> addToCollection(CollectionItemCard item) async {
    final current = await fetchCollection();
    final next = [...current.where((e) => e.id != item.id), item];
    await _persist(next);
  }

  @override
  Future<void> removeFromCollection(String itemId) async {
    final current = await fetchCollection();
    final next = current.where((e) => e.id != itemId).toList();
    await _persist(next);
  }

  Future<void> _persist(List<CollectionItemCard> items) async {
    final store = await _store;
    // Hive Map/List'i doğrudan saklar — jsonEncode/Decode'a gerek yok
    // (bkz. referans projedeki Utils4/Hive kullanımıyla aynı yaklaşım).
    await store.write(_listKey, items.map(_toMap).toList());
  }

  Map<String, dynamic> _toMap(CollectionItemCard item) => {
        'id': item.id,
        'title': item.title,
        'previewUrl': item.previewUrl,
        'originalCardType': item.originalCard.runtimeType.toString(),
        'originalCardId': item.originalCard.id,
      };

  CollectionItemCard _fromMap(Map<String, dynamic> map) {
    return CollectionItemCard(
      id: map['id'] as String,
      title: map['title'] as String,
      previewUrl: map['previewUrl'] as String,
      originalCard: _RestoredOriginalCard(
        id: map['originalCardId'] as String,
        typeName: map['originalCardType'] as String,
      ),
    );
  }
}

/// `LocalCollectionRepository`'nin geri yüklerken `originalCard` alanını
/// doldurmak için kullandığı yer tutucu — gerçek tip bilgisini SADECE
/// isim olarak taşır, davranışı yoktur. Kart serileştirme registry'si
/// eklenince bu sınıf kaldırılacak.
class _RestoredOriginalCard extends FeedCard {
  final String typeName;
  const _RestoredOriginalCard({required String id, required this.typeName})
      : super(id);
}
