import 'media_pick_result.dart';
import 'local_media_storage_io.dart'
    if (dart.library.html) 'platform/local_media_storage_web.dart' as platform;

/// Seçilen bir medyayı KALICI hale getirir — native'de gerçek bir dosyaya
/// yazar, web'de zaten bellekteki `bytes`'ı olduğu gibi geri döner.
///
/// Gerçek implementasyon burada DEĞİL: `platform/local_media_storage_io.dart`
/// (dart:io) ile `platform/local_media_storage_web.dart` (no-op) arasında
/// conditional import ile seçiliyor — çağıran kod (`MediaService`, kartlar)
/// hangi platformda çalıştığını hiç bilmiyor.
class LocalMediaStorage {
  LocalMediaStorage._();

  static Future<MediaPickResult> saveLocally(MediaPickResult media) =>
      platform.persist(media);

  static Future<void> delete(String path) => platform.deleteAt(path);
}
