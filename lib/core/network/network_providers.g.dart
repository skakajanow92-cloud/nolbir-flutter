// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Diğer provider'larla (`cartRepositoryProvider` vb.) aynı desen:
/// repository'ler kendi Dio'sunu kurmak yerine bunu izler.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// Diğer provider'larla (`cartRepositoryProvider` vb.) aynı desen:
/// repository'ler kendi Dio'sunu kurmak yerine bunu izler.

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  /// Diğer provider'larla (`cartRepositoryProvider` vb.) aynı desen:
  /// repository'ler kendi Dio'sunu kurmak yerine bunu izler.
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'9fe23fe85bc82bfd56c0b4929faa99298660d1bd';
