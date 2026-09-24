import 'package:flutter/foundation.dart' show kIsWeb;
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
    if (file == null) return null;
    return _fromXFile(file, MediaKind.image);
  }

  /// Kameradan video çeker. Kullanıcı iptal ederse `null` döner.
  static Future<MediaPickResult?> captureVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.camera);
    if (file == null) return null;
    return _fromXFile(file, MediaKind.video);
  }

  /// Galeriden tek bir fotoğraf/video seçer.
  static Future<MediaPickResult?> pickFromGallery() async {
    final file = await _imagePicker.pickMedia();
    if (file == null) return null;
    return _fromXFile(file, _guessKind(file.name));
  }

  /// Galeriden birden fazla fotoğraf/video seçer.
  static Future<List<MediaPickResult>> pickMultipleFromGallery() async {
    final files = await _imagePicker.pickMultipleMedia();
    final results = <MediaPickResult>[];
    for (final f in files) {
      results.add(await _fromXFile(f, _guessKind(f.name)));
    }
    return results;
  }

  /// Kamera rulosu dışında herhangi bir dosya seçer (pdf, belge vb.).
  ///
  /// file_picker v12+ API NOTU: `FilePicker.platform` getter'ı ve
  /// `FilePickerResult` kaldırıldı — `pickFile()` artık doğrudan
  /// `PlatformFile?` döner. `withData`/`withReadStream` parametreleri de
  /// kaldırıldığı için bytes'ı ayrı bir adımda `readAsBytes()` ile
  /// okuyoruz; bu okuma web'de de native'de de aynı şekilde çalışır,
  /// platform ayrımına gerek yok. `PlatformFile.size` de kaldırıldığı
  /// için boyutu zaten okuduğumuz `bytes.length`'ten alıyoruz — ekstra
  /// bir disk/IO çağrısına gerek kalmıyor.
  static Future<MediaPickResult?> pickAnyFile({FileType type = FileType.any}) async {
    final file = await FilePicker.pickFile(type: type);
    if (file == null) return null; // kullanıcı iptal etti

    final bytes = await file.readAsBytes();
    return MediaPickResult(
      path: kIsWeb ? null : file.path,
      bytes: bytes,
      fileName: file.name,
      kind: _guessKind(file.name),
      sizeBytes: bytes.length,
    );
  }

  /// `XFile.readAsBytes()` web (blob URL) ve native (gerçek dosya) arasındaki
  /// farkı zaten kendi içinde soyutluyor (`cross_file` paketinin işi budur)
  /// — burada dart:io'ya hiç dokunmuyoruz.
  static Future<MediaPickResult> _fromXFile(XFile file, MediaKind kind) async {
    final bytes = await file.readAsBytes();
    return MediaPickResult(
      path: kIsWeb ? null : file.path,
      bytes: bytes,
      fileName: file.name,
      kind: kind,
    );
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
