// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `cartRepositoryProvider`/`profileRepositoryProvider` ile aynı desen:
/// bugün mock, backend gelince tek satır değişir.

@ProviderFor(mediaUploader)
final mediaUploaderProvider = MediaUploaderProvider._();

/// `cartRepositoryProvider`/`profileRepositoryProvider` ile aynı desen:
/// bugün mock, backend gelince tek satır değişir.

final class MediaUploaderProvider
    extends $FunctionalProvider<MediaUploader, MediaUploader, MediaUploader>
    with $Provider<MediaUploader> {
  /// `cartRepositoryProvider`/`profileRepositoryProvider` ile aynı desen:
  /// bugün mock, backend gelince tek satır değişir.
  MediaUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaUploaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaUploaderHash();

  @$internal
  @override
  $ProviderElement<MediaUploader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaUploader create(Ref ref) {
    return mediaUploader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaUploader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaUploader>(value),
    );
  }
}

String _$mediaUploaderHash() => r'3460f7a0eaa25435d5fe7940cd7fe274330ba9db';

@ProviderFor(mediaService)
final mediaServiceProvider = MediaServiceProvider._();

final class MediaServiceProvider
    extends $FunctionalProvider<MediaService, MediaService, MediaService>
    with $Provider<MediaService> {
  MediaServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaServiceHash();

  @$internal
  @override
  $ProviderElement<MediaService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaService create(Ref ref) {
    return mediaService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaService>(value),
    );
  }
}

String _$mediaServiceHash() => r'6dd8359b96e974548c93a14f0563945ac2ccc33f';
