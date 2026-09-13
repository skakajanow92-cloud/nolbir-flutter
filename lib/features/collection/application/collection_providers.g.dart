// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(collectionRepository)
final collectionRepositoryProvider = CollectionRepositoryProvider._();

final class CollectionRepositoryProvider extends $FunctionalProvider<
    CollectionRepository,
    CollectionRepository,
    CollectionRepository> with $Provider<CollectionRepository> {
  CollectionRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'collectionRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$collectionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CollectionRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CollectionRepository create(Ref ref) {
    return collectionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionRepository>(value),
    );
  }
}

String _$collectionRepositoryHash() =>
    r'1ddb66a2a23282deb0e2d77a541be024828b6878';

/// Sağ tab'ın state'i. Diğer tab'lardan farkı: kullanıcı burada
/// veriyi değiştirebiliyor (ekle/çıkar), sadece okumuyor.

@ProviderFor(CollectionFeed)
final collectionFeedProvider = CollectionFeedProvider._();

/// Sağ tab'ın state'i. Diğer tab'lardan farkı: kullanıcı burada
/// veriyi değiştirebiliyor (ekle/çıkar), sadece okumuyor.
final class CollectionFeedProvider
    extends $AsyncNotifierProvider<CollectionFeed, List<CollectionItemCard>> {
  /// Sağ tab'ın state'i. Diğer tab'lardan farkı: kullanıcı burada
  /// veriyi değiştirebiliyor (ekle/çıkar), sadece okumuyor.
  CollectionFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'collectionFeedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$collectionFeedHash();

  @$internal
  @override
  CollectionFeed create() => CollectionFeed();
}

String _$collectionFeedHash() => r'ebe9563e43d57583f52dbdb2c8c569e996c1a388';

/// Sağ tab'ın state'i. Diğer tab'lardan farkı: kullanıcı burada
/// veriyi değiştirebiliyor (ekle/çıkar), sadece okumuyor.

abstract class _$CollectionFeed
    extends $AsyncNotifier<List<CollectionItemCard>> {
  FutureOr<List<CollectionItemCard>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<CollectionItemCard>>, List<CollectionItemCard>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<CollectionItemCard>>,
            List<CollectionItemCard>>,
        AsyncValue<List<CollectionItemCard>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
