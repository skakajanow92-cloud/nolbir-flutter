import 'media_pick_result.dart';

/// Web'de kalıcı bir dosya sistemi yok — seçilen medya zaten `bytes`
/// olarak bellekte duruyor (bkz. `MediaPicker`), bu yüzden yapılacak bir
/// şey yok, medya olduğu gibi geri döner.
///
/// TODO: oturumlar arası kalıcılık gerekirse (ör. offline taslak) buraya
/// IndexedDB tabanlı bir implementasyon eklenir — SADECE bu dosya değişir,
/// çağıran hiçbir kod (MediaService, kartlar) etkilenmez.
Future<MediaPickResult> persist(MediaPickResult media) async => media;

Future<void> deleteAt(String path) async {}
