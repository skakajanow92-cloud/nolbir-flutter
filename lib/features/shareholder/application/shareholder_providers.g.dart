// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shareholder_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ortaklık başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
/// state korunur.

@ProviderFor(ShareholderApplicationDraft)
final shareholderApplicationDraftProvider =
    ShareholderApplicationDraftProvider._();

/// Ortaklık başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
/// state korunur.
final class ShareholderApplicationDraftProvider
    extends
        $NotifierProvider<ShareholderApplicationDraft, ShareholderApplication> {
  /// Ortaklık başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
  /// state korunur.
  ShareholderApplicationDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareholderApplicationDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareholderApplicationDraftHash();

  @$internal
  @override
  ShareholderApplicationDraft create() => ShareholderApplicationDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareholderApplication value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareholderApplication>(value),
    );
  }
}

String _$shareholderApplicationDraftHash() =>
    r'af1ae183f2cd751bbafdba3138a78752d971c713';

/// Ortaklık başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
/// state korunur.

abstract class _$ShareholderApplicationDraft
    extends $Notifier<ShareholderApplication> {
  ShareholderApplication build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ShareholderApplication, ShareholderApplication>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShareholderApplication, ShareholderApplication>,
              ShareholderApplication,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// `isShareholder` — SADECE başvuru onaylandığında true olur.

@ProviderFor(isShareholder)
final isShareholderProvider = IsShareholderProvider._();

/// `isShareholder` — SADECE başvuru onaylandığında true olur.

final class IsShareholderProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// `isShareholder` — SADECE başvuru onaylandığında true olur.
  IsShareholderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isShareholderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isShareholderHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isShareholder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isShareholderHash() => r'269ce1a34b6ba1f2c7aa2ea68a557ac941acac08';
