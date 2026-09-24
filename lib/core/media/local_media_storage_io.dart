import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'media_pick_result.dart';

/// SADECE bu dosya `dart:io`/`path_provider` içe aktarır — web derlemesi
/// bunu hiç görmez (bkz. local_media_storage.dart'taki conditional import).
Future<MediaPickResult> persist(MediaPickResult media) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final targetDir = Directory('${docsDir.path}/media');
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  final uniqueName = "${DateTime.now().millisecondsSinceEpoch}_${media.fileName}";
  final targetFile = File('${targetDir.path}/$uniqueName');
  await targetFile.writeAsBytes(media.bytes);
  return media.copyWith(path: targetFile.path);
}

Future<void> deleteAt(String path) async {
  final file = File(path);
  if (await file.exists()) await file.delete();
}
