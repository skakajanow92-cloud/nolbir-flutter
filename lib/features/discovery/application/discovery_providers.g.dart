// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repository'yi enjekte eden provider. Test ederken veya gerçek API'ye
/// geçerken burada `overrideWithValue` ile mock/gerçek repository'yi
/// değiştirebilirsin — geri kalan hiçbir şeye dokunmadan.

@ProviderFor(discoveryRepository)
final discoveryRepositoryProvider = DiscoveryRepositoryProvider._();

/// Repository'yi enjekte eden provider. Test ederken veya gerçek API'ye
/// geçerken burada `overrideWithValue` ile mock/gerçek repository'yi
/// değiştirebilirsin — geri kalan hiçbir şeye dokunmadan.

final class DiscoveryRepositoryProvider extends $FunctionalProvider<
    DiscoveryRepository,
    DiscoveryRepository,
    DiscoveryRepository> with $Provider<DiscoveryRepository> {
  /// Repository'yi enjekte eden provider. Test ederken veya gerçek API'ye
  /// geçerken burada `overrideWithValue` ile mock/gerçek repository'yi
  /// değiştirebilirsin — geri kalan hiçbir şeye dokunmadan.
  DiscoveryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'discoveryRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$discoveryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DiscoveryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DiscoveryRepository create(Ref ref) {
    return discoveryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryRepository>(value),
    );
  }
}

String _$discoveryRepositoryHash() =>
    r'3da4ccb0e28b9bb418dcea9a8fc8c3cd7cd4ac21';

/// Orta tab'ın state'i: kart listesi + sayfalama.
/// `VerticalCardFeed.onReachEnd` bu notifier'ın `loadMore()` metodunu çağırır.

@ProviderFor(DiscoveryFeed)
final discoveryFeedProvider = DiscoveryFeedProvider._();

/// Orta tab'ın state'i: kart listesi + sayfalama.
/// `VerticalCardFeed.onReachEnd` bu notifier'ın `loadMore()` metodunu çağırır.
final class DiscoveryFeedProvider
    extends $AsyncNotifierProvider<DiscoveryFeed, List<FeedCard>> {
  /// Orta tab'ın state'i: kart listesi + sayfalama.
  /// `VerticalCardFeed.onReachEnd` bu notifier'ın `loadMore()` metodunu çağırır.
  DiscoveryFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'discoveryFeedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$discoveryFeedHash();

  @$internal
  @override
  DiscoveryFeed create() => DiscoveryFeed();
}

String _$discoveryFeedHash() => r'0d3d2c845190f7e143eb5eb78b06eb7eb14563dd';

/// Orta tab'ın state'i: kart listesi + sayfalama.
/// `VerticalCardFeed.onReachEnd` bu notifier'ın `loadMore()` metodunu çağırır.

abstract class _$DiscoveryFeed extends $AsyncNotifier<List<FeedCard>> {
  FutureOr<List<FeedCard>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FeedCard>>, List<FeedCard>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<FeedCard>>, List<FeedCard>>,
        AsyncValue<List<FeedCard>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
