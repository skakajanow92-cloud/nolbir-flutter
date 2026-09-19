/// Form kartları için ortak temel — `FeedCard`'ın form karşılığı.
///
/// BİLİNÇLİ OLARAK AYRI bir hiyerarşi: form kartları içerik GÖSTERMEZ,
/// veri TOPLAR — `Collectible` gibi feed'e özel davranışlara ihtiyaçları
/// yok. Profil klasörü kalabalıklaşmasın diye `models/form_card/` altında,
/// `models/feed_card/`'dan tamamen bağımsız tutuluyor.
///
/// Yeni bir form eklerken: bu klasöre yeni dosyayı ekle, `form_card.dart`
/// barrel'ına bir `export` satırı ekle, `FormViewRegistry.register<T>()`
/// ile görünümünü kaydet — `FeedCard` sistemindeki akışın birebir aynısı.
abstract class FormCard {
  final String id;
  const FormCard(this.id);
}
