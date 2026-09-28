// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Box adına göre `LocalStore` verir (family). `apiClientProvider` /
/// `mediaServiceProvider` ile aynı desen: widget'lar ve notifier'lar
/// `LocalStore.open`'ı doğrudan çağırmak yerine bunu izler — testte
/// `overrideWith` ile sahte bir store enjekte edilebilir.
///
/// Kullanım:
/// ```dart
/// final store = await ref.watch(
///   localStoreProvider(StorageBoxes.settings).future,
/// );
/// ```

@ProviderFor(localStore)
final localStoreProvider = LocalStoreFamily._();

/// Box adına göre `LocalStore` verir (family). `apiClientProvider` /
/// `mediaServiceProvider` ile aynı desen: widget'lar ve notifier'lar
/// `LocalStore.open`'ı doğrudan çağırmak yerine bunu izler — testte
/// `overrideWith` ile sahte bir store enjekte edilebilir.
///
/// Kullanım:
/// ```dart
/// final store = await ref.watch(
///   localStoreProvider(StorageBoxes.settings).future,
/// );
/// ```

final class LocalStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocalStore>,
          LocalStore,
          FutureOr<LocalStore>
        >
    with $FutureModifier<LocalStore>, $FutureProvider<LocalStore> {
  /// Box adına göre `LocalStore` verir (family). `apiClientProvider` /
  /// `mediaServiceProvider` ile aynı desen: widget'lar ve notifier'lar
  /// `LocalStore.open`'ı doğrudan çağırmak yerine bunu izler — testte
  /// `overrideWith` ile sahte bir store enjekte edilebilir.
  ///
  /// Kullanım:
  /// ```dart
  /// final store = await ref.watch(
  ///   localStoreProvider(StorageBoxes.settings).future,
  /// );
  /// ```
  LocalStoreProvider._({
    required LocalStoreFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'localStoreProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localStoreHash();

  @override
  String toString() {
    return r'localStoreProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LocalStore> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LocalStore> create(Ref ref) {
    final argument = this.argument as String;
    return localStore(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalStoreProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localStoreHash() => r'34f170df1adcd593cc89d5f0b6c2cfb872c50590';

/// Box adına göre `LocalStore` verir (family). `apiClientProvider` /
/// `mediaServiceProvider` ile aynı desen: widget'lar ve notifier'lar
/// `LocalStore.open`'ı doğrudan çağırmak yerine bunu izler — testte
/// `overrideWith` ile sahte bir store enjekte edilebilir.
///
/// Kullanım:
/// ```dart
/// final store = await ref.watch(
///   localStoreProvider(StorageBoxes.settings).future,
/// );
/// ```

final class LocalStoreFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LocalStore>, String> {
  LocalStoreFamily._()
    : super(
        retry: null,
        name: r'localStoreProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Box adına göre `LocalStore` verir (family). `apiClientProvider` /
  /// `mediaServiceProvider` ile aynı desen: widget'lar ve notifier'lar
  /// `LocalStore.open`'ı doğrudan çağırmak yerine bunu izler — testte
  /// `overrideWith` ile sahte bir store enjekte edilebilir.
  ///
  /// Kullanım:
  /// ```dart
  /// final store = await ref.watch(
  ///   localStoreProvider(StorageBoxes.settings).future,
  /// );
  /// ```

  LocalStoreProvider call(String boxName) =>
      LocalStoreProvider._(argument: boxName, from: this);

  @override
  String toString() => r'localStoreProvider';
}
