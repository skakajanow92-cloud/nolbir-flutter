import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'media_pick_result.dart';

/// Uygulama genelinde TEK merkezi medya SEÇME noktası.
///
/// BİLİNÇLİ TASARIM KARARI: `image_picker`/`file_picker` çağrıları başta
/// sadece profil "+" ekranında (create_post_sheet) yazılmıştı — ama
/// kamera/galeri/dosya seçme ihtiyacı zamanla başka kartlarda da çıkacak
/// (ör. destek talebine dosya ekleme, ürün görseli yükleme, poliçe
/// taraması). Bu yüzden seçme mantığı `CartVisuals`/`CardViewRegistry`
/// ile aynı ilkeyle TEK bir yerde izole edildi: her modül bu sınıfı
/// çağırır, kimse kendi image_picker/file_picker kodunu tekrar yazmaz.
///
/// Bu sınıf SADECE seçme işini yapar (izinler paketler tarafından
/// otomatik istenir). Seçilen dosyayı kalıcı hale getirmek
/// `LocalMediaStorage`'ın, backend'e yüklemek `MediaUploader`'ın işi —
/// sorumluluklar bilerek ayrıldı.
class MediaPicker {
  MediaPicker._();

  static final ImagePicker _imagePicker = ImagePicker();

  /// Kameradan fotoğraf çeker. Kullanıcı iptal ederse `null` döner.
  static Future<MediaPickResult?> captureImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera);
    return _fromXFile(file, MediaKind.image);
  }

  /// Kameradan video çeker. Kullanıcı iptal ederse `null` döner.
  static Future<MediaPickResult?> captureVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.camera);
    return _fromXFile(file, MediaKind.video);
  }

  /// Galeriden tek bir fotoğraf/video seçer.
  static Future<MediaPickResult?> pickFromGallery() async {
    final file = await _imagePicker.pickMedia();
    if (file == null) return null;
    return _fromXFile(file, _guessKind(file.path));
  }

  /// Galeriden birden fazla fotoğraf/video seçer.
  static Future<List<MediaPickResult>> pickMultipleFromGallery() async {
    final files = await _imagePicker.pickMultipleMedia();
    return files.map((f) => _fromXFile(f, _guessKind(f.path))!).toList();
  }

  /// Kamera rulosu dışında herhangi bir dosya seçer (pdf, belge vb.).
  static Future<MediaPickResult?> pickAnyFile({FileType type = FileType.any}) async {
    final result = await FilePicker.pickFiles(type: type);
    final picked = result.single;
    if (picked.path == null) return null;
    return MediaPickResult(
      path: picked.path!,
      fileName: picked.name,
      kind: _guessKind(picked.path!),
      //sizeBytes: picked.,
    );
  }

  static MediaPickResult? _fromXFile(XFile? file, MediaKind kind) {
    if (file == null) return null;
    return MediaPickResult(path: file.path, fileName: file.name, kind: kind);
  }

  static MediaKind _guessKind(String path) {
    final ext = path.split('.').last.toLowerCase();
    const videoExt = {'mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'};
    const imageExt = {'jpg', 'jpeg', 'png', 'gif', 'heic', 'webp', 'bmp'};
    if (videoExt.contains(ext)) return MediaKind.video;
    if (imageExt.contains(ext)) return MediaKind.image;
    return MediaKind.file;
  }
}
