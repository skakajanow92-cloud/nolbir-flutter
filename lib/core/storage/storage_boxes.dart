/// Uygulamadaki tüm Hive box adlarının TEK kaynağı.
///
/// `LocalStore.open('auth_cache')` gibi elle yazılmış string'ler yerine
/// buradaki sabitler kullanılır — yazım hatası, iki modülün aynı box'ı
/// habersizce paylaşması gibi sorunlar tek dosyada görünür olur. Yeni bir
/// modül kendi box'ına ihtiyaç duyunca buraya BİR satır ekler.
///
/// Box adları küçük harf + rakam + alt çizgi olmalı (Hive native'de dosya
/// adı olarak, web'de IndexedDB adı olarak kullanır).
class StorageBoxes {
  StorageBoxes._();

  static const settings = 'app_settings'; // tema, dil, tercihler
  static const auth = 'auth_cache'; // oturum/kullanıcı önbelleği
  static const cache = 'general_cache'; // genel amaçlı geçici önbellek
  static const collection = 'collection_items'; // kullanıcının kaydettiği kartlar
}
