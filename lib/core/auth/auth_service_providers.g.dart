// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Production'da tek satır değişir:
/// Yol A: aynı kalır. Yol B: BackendAuthService(...) döner.

@ProviderFor(authService)
final authServiceProvider = AuthServiceProvider._();

/// Production'da tek satır değişir:
/// Yol A: aynı kalır. Yol B: BackendAuthService(...) döner.

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// Production'da tek satır değişir:
  /// Yol A: aynı kalır. Yol B: BackendAuthService(...) döner.
  AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'960b48699c72583ce022920a6488b60aa62704e3';
