import 'media_pick_result.dart';

/// Bir medyayı backend'e yükleme sözleşmesi.
///
/// `CartRepository`/`ProfileRepository` ile AYNI mantık: bugün gerçek bir
/// API yok, ama arayüz hazır olduğu için backend gelince sadece bu
/// sınıfın implementasyonu değişecek — hiçbir kart/sheet kodu değişmeyecek.
abstract class MediaUploader {
  /// Yükler ve dosyanın kalıcı, herkese açık URL'ini döner.
  /// `onProgress` 0.0–1.0 arası ilerleme bildirir (opsiyonel).
  Future<String> upload(
    MediaPickResult media, {
    void Function(double progress)? onProgress,
  });
}

class MockApiMediaUploader implements MediaUploader {
  @override
  Future<String> upload(
    MediaPickResult media, {
    void Function(double progress)? onProgress,
  }) async {
    // TODO: gerçek backend entegrasyonu (dio/http multipart request).
    for (var step = 1; step <= 5; step++) {
      await Future.delayed(const Duration(milliseconds: 120));
      onProgress?.call(step / 5);
    }
    return "https://cdn.example.com/uploads/${media.fileName}";
  }
}
