import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Oturum token'ı için TEK, kalıcı ve güvenli depolama noktası.
///
/// NEDEN `LocalStore` (Hive) DEĞİL: Hive şifreli açılsa bile AES
/// anahtarını bir yerde tutman gerekir — bu döngüsel bir güvenlik sorunu
/// yaratır. Bu sınıf onun yerine işletim sisteminin kendi güvenli
/// deposunu kullanır (iOS/macOS Keychain, Android Keystore destekli
/// EncryptedSharedPreferences, Windows Credential Locker, Linux Secret
/// Service, web'de tarayıcının kendi güvenli depolama API'si) — anahtar
/// yönetimi işletim sistemine ait, bizim elimizde tutmamız gereken bir
/// sır yok.
///
/// Token DIŞINDA hiçbir şey burada saklanmaz — appIds, kullanıcı adı vb.
/// hassas olmayan oturum verisi `LocalStore` (Hive) tarafında kalır. Bu
/// sınıfın sorumluluğu tek: token + refresh token.
class SecureTokenStorage {
  SecureTokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> readToken() => _storage.read(key: _tokenKey);

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  static Future<String?> readRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
