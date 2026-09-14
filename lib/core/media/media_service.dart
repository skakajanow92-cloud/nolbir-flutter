import 'local_media_storage.dart';
import 'media_pick_result.dart';
import 'media_picker.dart';
import 'media_uploader.dart';

/// `MediaPicker` + `LocalMediaStorage` + `MediaUploader`'ı tek bir çağrı
/// arkasında birleştiren kolaylık katmanı.
///
/// Kartların/sheet'lerin yapması gereken tek şey: "kameradan fotoğraf al
/// ve kalıcı olarak sakla" gibi bir niyeti tek satırda ifade etmek.
/// Seçme/kaydetme sırasının nasıl işlediğiyle uğraşmamalılar — tıpkı
/// `CartDetail` provider'ının repository detaylarını kart görünümünden
/// gizlemesi gibi.
class MediaService {
  final MediaUploader uploader;

  const MediaService({required this.uploader});

  /// Seç + cihazda kalıcı olarak sakla. Kullanıcı iptal ederse `null`.
  Future<MediaPickResult?> captureImageAndPersist() =>
      _persist(MediaPicker.captureImage());

  Future<MediaPickResult?> captureVideoAndPersist() =>
      _persist(MediaPicker.captureVideo());

  Future<MediaPickResult?> pickFromGalleryAndPersist() =>
      _persist(MediaPicker.pickFromGallery());

  Future<MediaPickResult?> pickAnyFileAndPersist() =>
      _persist(MediaPicker.pickAnyFile());

  /// Zaten kalıcı diskte duran bir medyayı backend'e yükler.
  Future<String> upload(
    MediaPickResult media, {
    void Function(double progress)? onProgress,
  }) {
    return uploader.upload(media, onProgress: onProgress);
  }

  Future<MediaPickResult?> _persist(Future<MediaPickResult?> pick) async {
    final picked = await pick;
    if (picked == null) return null;
    final localPath = await LocalMediaStorage.saveLocally(picked);
    return picked.copyWith(path: localPath);
  }
}
