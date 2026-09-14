import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'media_service.dart';
import 'media_uploader.dart';

part 'media_providers.g.dart';

/// `cartRepositoryProvider`/`profileRepositoryProvider` ile aynı desen:
/// bugün mock, backend gelince tek satır değişir.
@riverpod
MediaUploader mediaUploader(Ref ref) => MockApiMediaUploader();

@riverpod
MediaService mediaService(Ref ref) {
  return MediaService(uploader: ref.watch(mediaUploaderProvider));
}
