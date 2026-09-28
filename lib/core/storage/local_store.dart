import 'package:hive_ce_flutter/hive_flutter.dart';

/// Uygulama genelinde TÜM yerel key-value depolamanın (Hive) TEK giriş noktası.
///
/// `ApiClient` ile aynı ilke: her modül kendi `Hive.openBox` çağrısını
/// yazmaz. Aynı box adı için TEK bir `LocalStore` (multiton) paylaşılır.
///
/// PLATFORM: `hive_flutter` native'de dosyaya, web'de IndexedDB'ye yazar;
/// bu dosyada `dart:io` YOK, dolayısıyla platform bölmesine gerek yok.
/// (Web'de veri tarayıcıya bağlıdır, kullanıcı site verisini silerse gider.)
///
/// KULLANIM:
/// ```dart
/// await LocalStore.init();                    // main()'de BİR kez
/// final store = await LocalStore.open(StorageBoxes.settings);
/// await store.write('dark_mode', true);
/// final dark = store.read<bool>('dark_mode', defaultValue: false);
/// ```
///
/// `.SAN` SANDBOX İZOLASYONU: [isolationKey] verilirse box adı o modüle
/// özel bir isim alanına taşınır (ana uygulamanın box'larıyla asla
/// çakışmaz) ve [encryptionKey] ZORUNLU olur (AES-256, 32 byte). Not:
/// isim alanı tek başına güvenlik sınırı değildir — sandbox modüllerine
/// Hive'a doğrudan erişim değil, sadece bu sınıftan alınmış kendi
/// `LocalStore` handle'ı verilmelidir.
class LocalStore {
  static final Map<String, LocalStore> _instances = {};
  static final Map<String, Future<LocalStore>> _opening = {};
  static bool _initialized = false;

  final Box _box;
  final String boxName;
  final bool isSandboxed;
  final String _instanceKey;

  LocalStore._(this._box, this.boxName, this._instanceKey, this.isSandboxed);

  /// Hive motorunu başlatır. `main()`'de, `runApp`'ten önce BİR kez çağrılır;
  /// tekrar çağrılması zararsızdır.
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  /// [boxName] için ilgili `LocalStore`'u açar (zaten açıksa aynısını döner).
  static Future<LocalStore> open(
    String boxName, {
    List<int>? encryptionKey,
    String? isolationKey,
  }) {
    assert(_initialized, 'LocalStore.init() main()\'de çağrılmadı.');

    final sandboxed = isolationKey != null && isolationKey.isNotEmpty;
    if (sandboxed && encryptionKey == null) {
      throw ArgumentError(
        'Sandbox (isolationKey) box\'ları için encryptionKey zorunludur.',
      );
    }

    final realName = sandboxed ? _sandboxName(isolationKey, boxName) : boxName;
    final key = encryptionKey != null ? '$realName::enc' : realName;

    final cached = _instances[key];
    if (cached != null) return Future.value(cached);

    // Aynı box'ın eşzamanlı iki açılışı tek Future'a bağlanır.
    return _opening[key] ??= _openInternal(
      realName,
      key,
      encryptionKey,
      sandboxed,
    ).whenComplete(() {
      _opening.remove(key);
    });
  }

  static Future<LocalStore> _openInternal(
    String realName,
    String key,
    List<int>? encryptionKey,
    bool sandboxed,
  ) async {
    final box = await Hive.openBox(
      realName,
      encryptionCipher:
          encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
    );
    final store = LocalStore._(box, realName, key, sandboxed);
    _instances[key] = store;
    return store;
  }

  static String _sandboxName(String isolationKey, String boxName) {
    final safe = isolationKey.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return 'san_${safe}__$boxName';
  }

  // --- TEMEL İŞLEMLER ---

  Future<void> write(String key, dynamic value) => _box.put(key, value);

  /// Basit tipler (bool/int/double/String/List) için. Map okumak için
  /// [readMap] kullan — Hive Map'leri `Map<dynamic, dynamic>` döner ve
  /// doğrudan `read<Map<String, dynamic>>` cast'i hata verir.
  T? read<T>(String key, {T? defaultValue}) =>
      _box.get(key, defaultValue: defaultValue) as T?;

  /// Map'i `Map<String, dynamic>` olarak okur. Dikkat: cast SADECE en üst
  /// seviye içindir, iç içe Map'ler `Map<dynamic, dynamic>` kalır.
  Map<String, dynamic>? readMap(String key) {
    final value = _box.get(key);
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  Future<void> delete(String key) => _box.delete(key);

  bool hasKey(String key) => _box.containsKey(key);

  List<dynamic> get keys => _box.keys.toList();

  /// Bir anahtar değişince olay üretir (Riverpod/StreamBuilder ile reaktif UI).
  Stream<dynamic> watch(String key) => _box.watch(key: key).map((e) => e.value);

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> close() async {
    await _box.close();
    _instances.remove(_instanceKey);
  }
}
