import '../network/api_client.dart';
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
    for (var step = 1; step <= 5; step++) {
      await Future.delayed(const Duration(milliseconds: 120));
      onProgress?.call(step / 5);
    }
    return "https://cdn.example.com/uploads/${media.fileName}";
  }
}

/// `core/network/api_client.dart` hazır olduğu için artık gerçek —
/// kendi Dio'sunu kurmaz, tüm API çıkışlarının tek noktası olan
/// `ApiClient.uploadFile`'ı kullanır. `media.bytes` her platformda dolu
/// olduğundan (bkz. MediaPickResult) burada da platform ayrımına gerek
/// yok. Swap etmek için tek satır: `media_providers.dart`'taki
/// `mediaUploaderProvider` içinde `MockApiMediaUploader()` yerine
/// `DioMediaUploader(client: ref.watch(apiClientProvider))` yazılır.
class DioMediaUploader implements MediaUploader {
  final ApiClient client;
  final String endpoint;

  const DioMediaUploader({
    required this.client,
    this.endpoint = "/media/upload",
  });

  @override
  Future<String> upload(
    MediaPickResult media, {
    void Function(double progress)? onProgress,
  }) async {
    final response = await client.uploadFile(
      endpoint,
      bytes: media.bytes,
      fileName: media.fileName,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return response.data['url'] as String;
  }
}
