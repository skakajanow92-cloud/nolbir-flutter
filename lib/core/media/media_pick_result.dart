/// Seçilen bir medyanın türü.
enum MediaKind { image, video, file }

/// `image_picker` ya da `file_picker`'dan seçilen HERHANGİ bir medyayı
/// tek tip bir sonuca indirger. Çağıran kod (kartlar, sheet'ler) artık
/// `XFile` mı `PlatformFile` mı geldiğiyle uğraşmaz.
class MediaPickResult {
  final String path;
  final String fileName;
  final MediaKind kind;
  final int? sizeBytes;

  const MediaPickResult({
    required this.path,
    required this.fileName,
    required this.kind,
    this.sizeBytes,
  });

  MediaPickResult copyWith({String? path, String? fileName}) {
    return MediaPickResult(
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      kind: kind,
      sizeBytes: sizeBytes,
    );
  }
}
