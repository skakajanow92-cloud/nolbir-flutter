/// FeedCard tipleri için "koleksiyona kaydedilebilir" opsiyonel yeteneği.
/// Bir kart türü koleksiyona eklenebilir olmak istiyorsa sadece bu arayüzü
/// implemente eder — merkezi bir switch'e dokunmasına gerek yoktur.
/// Implemente etmeyen kart türleri otomatik olarak generic bir önizleme
/// alır (bkz. collection_item_builder.dart).
abstract interface class Collectible {
  /// Koleksiyon listesinde gösterilecek başlık ve önizleme URL'i.
  (String title, String previewUrl) toCollectionPreview();
}

/// Tüm feed kartlarının ortak temeli.
///
/// BİLİNÇLİ TASARIM KARARI: Artık `sealed` DEĞİL — bilerek açık bırakıldı.
/// Yeni bir kart tipi eklemek için buraya yeni bir sınıf ekleyip
/// `CardViewRegistry.register<YeniKart>(...)` çağırman yeterli; merkezi
/// hiçbir switch'e dokunmana gerek yok (bkz. core/cards/card_view_registry.dart).
abstract class FeedCard {
  final String id;
  const FeedCard(this.id);
}
