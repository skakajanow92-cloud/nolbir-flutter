import 'dart:typed_data';

/// Seçilen bir medyanın türü.
enum MediaKind { image, video, file }

/// `image_picker` ya da `file_picker`'dan seçilen HERHANGİ bir medyayı
/// tek tip bir sonuca indirger.
///
/// PLATFORM NOTU: `bytes` HER ZAMAN dolu — hem web'de gerçek bir dosya
/// yolu olmadığı için, hem de upload/önizleme gibi işlemler bu sayede hiç
/// platform ayrımına ihtiyaç duymasın diye. `path` sadece native
/// platformlarda (dosya sistemi olduğunda) anlamlıdır, web'de `null`
/// olabilir.
class MediaPickResult {
  final String? path;
  final Uint8List bytes;
  final String fileName;
  final MediaKind kind;
  final int? sizeBytes;

  const MediaPickResult({
    this.path,
    required this.bytes,
    required this.fileName,
    required this.kind,
    this.sizeBytes,
  });

  MediaPickResult copyWith({String? path, Uint8List? bytes, String? fileName}) {
    return MediaPickResult(
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      fileName: fileName ?? this.fileName,
      kind: kind,
      sizeBytes: sizeBytes,
    );
  }
}
