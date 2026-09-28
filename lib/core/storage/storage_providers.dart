import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'local_store.dart';

part 'storage_providers.g.dart';

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
@Riverpod(keepAlive: true)
Future<LocalStore> localStore(Ref ref, String boxName) =>
    LocalStore.open(boxName);
