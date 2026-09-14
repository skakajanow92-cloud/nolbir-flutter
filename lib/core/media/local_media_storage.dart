import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'media_pick_result.dart';

/// Seçilen bir medyayı cihazda KALICI hale getirir.
///
/// NEDEN GEREKLİ: `image_picker`/`file_picker`'ın döndürdüğü path çoğu
/// zaman geçici bir önbellek (cache) konumudur — işletim sistemi bunu
/// istediği an temizleyebilir. Bir gönderi/kart bu path'i doğrudan
/// saklarsa, uygulama yeniden açıldığında dosya kaybolmuş olabilir. Bu
/// sınıf dosyayı uygulamanın kalıcı belge dizinine kopyalayıp yeni,
/// güvenilir path'i döner.
class LocalMediaStorage {
  LocalMediaStorage._();

  static Future<String> saveLocally(MediaPickResult media) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${docsDir.path}/media');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final uniqueName =
        "${DateTime.now().millisecondsSinceEpoch}_${media.fileName}";
    final targetFile = File('${targetDir.path}/$uniqueName');
    await File(media.path).copy(targetFile.path);
    return targetFile.path;
  }

  static Future<void> delete(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) await file.delete();
  }
}
