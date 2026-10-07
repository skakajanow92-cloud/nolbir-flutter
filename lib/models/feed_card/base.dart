/// FeedCard tipleri için "koleksiyona kaydedilebilir" opsiyonel yeteneği.
/// Bir kart türü koleksiyona eklenebilir olmak istiyorsa sadece bu arayüzü
/// implemente eder — merkezi bir switch'e dokunmasına gerek yoktur.
/// Implemente etmeyen kart türleri otomatik olarak generic bir önizleme
/// alır (bkz. collection_item_builder.dart).
abstract interface class Collectible {
  /// Koleksiyon listesinde gösterilecek başlık ve önizleme URL'i.
  (String title, String previewUrl) toCollectionPreview();
}

/// Koleksiyona eklendiğinde statik bir önizleme yerine kartın KENDİSİNİN
/// (canlı, kendi içinde yenilenmeye devam eden haliyle) saklanmasını
/// isteyen kart türleri için işaretleyici arayüz. Bunu uygulayan bir kart
/// koleksiyona eklendiğinde, `collection_item_builder.dart` statik bir
/// `CollectionItemCard` önizlemesi ÜRETMEMELİ — orijinal `FeedCard`
/// örneğini doğrudan koleksiyon listesine eklemeli. Böylece Koleksiyon
/// tab'ı aynı `CardViewRegistry` üzerinden kartı birebir canlı haliyle
/// (burada: kendi hikaye şeridi ve sonsuz kaydırmasıyla) render eder.
abstract interface class LiveCollectible {}

/// Kullanıcıya pasif içerik olarak değil, bir "ihtiyacın var mı?" aracı
/// olarak sunulması gereken kart türleri için işaretleyici. Şu an
/// davranış eklemiyor — akış karıştırma mantığı ileride bunu görünce
/// farklı bir sunum (rozet, farklı sıklık) uygulayabilir.
abstract interface class ToolCard {}

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
