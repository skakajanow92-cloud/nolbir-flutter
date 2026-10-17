// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Admin başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
/// state korunur.

@ProviderFor(AdminApplicationDraft)
final adminApplicationDraftProvider = AdminApplicationDraftProvider._();

/// Admin başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
/// state korunur.
final class AdminApplicationDraftProvider
    extends $NotifierProvider<AdminApplicationDraft, AdminApplication> {
  /// Admin başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
  /// state korunur.
  AdminApplicationDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminApplicationDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminApplicationDraftHash();

  @$internal
  @override
  AdminApplicationDraft create() => AdminApplicationDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminApplication value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminApplication>(value),
    );
  }
}

String _$adminApplicationDraftHash() =>
    r'f3b5be773002e9c7494f1ca169974505fe1fbd64';

/// Admin başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
/// state korunur.

abstract class _$AdminApplicationDraft extends $Notifier<AdminApplication> {
  AdminApplication build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AdminApplication, AdminApplication>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminApplication, AdminApplication>,
              AdminApplication,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// `isAdmin` — SADECE başvuru onaylandığında true olur.

@ProviderFor(isAdmin)
final isAdminProvider = IsAdminProvider._();

/// `isAdmin` — SADECE başvuru onaylandığında true olur.

final class IsAdminProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// `isAdmin` — SADECE başvuru onaylandığında true olur.
  IsAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAdminHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAdmin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAdminHash() => r'0bc1582fca10a3bb516f9e8b92442621cb24ef79';
