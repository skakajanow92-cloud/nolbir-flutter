import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

/// Bir giriş/kayıt isteğinin başarılı sonucu.
///
/// `token` oturumun kendisi — `SecureTokenStorage`'a yazılacak ve
/// `ApiAuthContext.token`'a atanacak tek zorunlu alan. `refreshToken` ve
/// `appNo` backend'e göre olmayabilir; bu yüzden nullable bırakıldı.
///
/// VARSAYIM (backend sözleşmesi henüz doğrulanmadı): sunucunun
/// `{ "token": "...", "refreshToken": "...", "appNo": "..." }` şeklinde bir
/// gövdeyle döndüğü varsayıldı. Gerçek alan adları farklıysa sadece
/// [AuthResult.fromJson] güncellenir — geri kalan hiçbir kod etkilenmez.
class AuthResult {
  final String token;
  final String? refreshToken;
  final String? appNo;

  const AuthResult({required this.token, this.refreshToken, this.appNo});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      appNo: json['appNo'] as String?,
    );
  }
}

/// Kimlik doğrulama veri kaynağı sözleşmesi.
///
/// Diğer tüm repository'lerle (`CartRepository`, `CollectionRepository`,
/// `MediaUploader`) AYNI desen: soyut sözleşme + mock + gerçek (`Dio*`)
/// implementasyon, provider'da tek satır değişimiyle geçiş.
abstract class AuthRepository {
  Future<AuthResult> login({required String identifier, required String password});

  Future<AuthResult> register({
    required String email,
    required String password,
    required String pin,
  });

  /// Bazı backend'ler refresh token'ı geçersiz kılmak için sunucu tarafı bir
  /// çağrı ister (ör. oturumu diğer cihazlarda da sonlandırmak). Zorunlu
  /// değil — gerçek implementasyon bunu no-op bırakabilir.
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (identifier.trim().isEmpty || password.isEmpty) {
      throw const ApiException("Kimlik veya şifre boş olamaz");
    }
    return AuthResult(
      token: "mock_token_${identifier.hashCode}",
      refreshToken: "mock_refresh_${identifier.hashCode}",
      appNo: "mock_app_no",
    );
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String pin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AuthResult(
      token: "mock_token_${email.hashCode}",
      refreshToken: "mock_refresh_${email.hashCode}",
      appNo: "mock_app_no",
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Gerçek backend'e bağlı implementasyon.
///
/// VARSAYIM (backend sözleşmesi henüz doğrulanmadı, kullanıcıdan teyit
/// bekliyor):
/// - Uç noktalar: `POST /auth/login`, `POST /auth/register`.
/// - Giriş gövdesi: `{ "identifier": ..., "password": ... }`.
/// - Kayıt gövdesi: `{ "email": ..., "password": ..., "pin": ... }`.
/// - Cevap gövdesi: [AuthResult.fromJson] formatında.
/// Gerçek sözleşme farklıysa yalnızca bu sınıftaki endpoint string'leri ve
/// `AuthResult.fromJson` güncellenir.
class DioAuthRepository implements AuthRepository {
  final ApiClient _client;

  DioAuthRepository({ApiClient? client}) : _client = client ?? ApiClient.main;

  @override
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      "/auth/login",
      data: {"identifier": identifier, "password": password},
    );
    return AuthResult.fromJson(response.data!);
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String pin,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      "/auth/register",
      data: {"email": email, "password": password, "pin": pin},
    );
    return AuthResult.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post("/auth/logout");
    } on ApiException {
      // Sunucu tarafı logout başarısız olsa da yerel oturum temizliği
      // (token silme) devam etmeli — bu yüzden burada hatayı yutuyoruz.
      // Çağıran taraf (IsUser.logout) yerel temizliği her durumda yapar.
    }
  }
}
