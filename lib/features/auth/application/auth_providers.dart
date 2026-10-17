import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_auth_context.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// Hangi `AuthRepository` implementasyonunun kullanılacağı — bugün mock,
/// gerçek backend'e geçerken TEK satır: `MockAuthRepository()` ->
/// `DioAuthRepository()`. Diğer tüm repository provider'larıyla
/// (`cartRepositoryProvider`, `collectionRepositoryProvider`,
/// `mediaUploaderProvider`) AYNI desen.
@riverpod
AuthRepository authRepository(Ref ref) => MockAuthRepository();

/// Kullanıcının oturum durumu.
///
/// Artık GERÇEK bir akış: `login`/`register` `AuthRepository`'yi çağırır,
/// başarılı olursa token'ı `SecureTokenStorage`'a kalıcı olarak yazar ve
/// `ApiAuthContext.token`'ı günceller (böylece `ApiClient`'ın sonraki TÜM
/// istekleri otomatik olarak yetkilendirilmiş olur). `build()` açılışta
/// `SecureTokenStorage`'da kayıtlı bir token olup olmadığını kontrol eder —
/// varsa oturum otomatik geri yüklenir, kullanıcı her uygulama açılışında
/// yeniden giriş yapmak zorunda kalmaz.
///
/// NOT: appNo gibi hassas olmayan oturum verisi kasıtlı olarak burada
/// tutulmuyor — `SecureTokenStorage`'ın sorumluluğu sadece token/refresh
/// token (bkz. o dosyadaki doc comment). appNo şimdilik sadece
/// `ApiAuthContext.extraHeaders`'a yazılıyor, kalıcı saklanması gerekirse
/// bu iş `LocalStore` (Hive) tarafına taşınır.
@riverpod
class IsUser extends _$IsUser {
  @override
  bool build() {
    _restoreSession();
    return false; // ilk render'da senkron dönüş — kurtarma bitince state güncellenir
  }

  Future<void> _restoreSession() async {
    final token = await SecureTokenStorage.readToken();
    if (token == null || token.isEmpty) return;
    ApiAuthContext.token = token;
    state = true;
  }

  /// Giriş formunun "Giriş Yap" butonundan çağrılır.
  /// identifier: T.C. kimlik no / e-posta / telefondan biri olabilir.
  ///
  /// Hata durumunda `ApiException` (veya mock'taki validasyon hatası)
  /// fırlatılır — çağıran widget (`LoginRegisterCardView`) bunu
  /// try/catch ile yakalayıp kullanıcıya gösterir, state DEĞİŞMEZ.
  Future<void> login({required String identifier, required String password}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(identifier: identifier, password: password);
    await _applySession(result);
  }

  /// Kayıt formunun "Kayıt Ol" butonundan çağrılır.
  ///
  /// VARSAYIM: Kayıt sonrası otomatik giriş yapılmış sayılıyor (yaygın bir
  /// UX tercihi, mock'taki önceki davranışla aynı) — backend bağlanırken
  /// bu davranış değişebilir, örneğin e-posta doğrulaması beklenen bir ara
  /// adım eklenebilir (bkz. `models/form_card/email_verification_form_card.dart`,
  /// henüz bağlanmadı).
  Future<void> register({
    required String email,
    required String password,
    required String pin,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .register(email: email, password: password, pin: pin);
    await _applySession(result);
  }

  Future<void> _applySession(AuthResult result) async {
    await SecureTokenStorage.saveToken(result.token);
    if (result.refreshToken != null) {
      await SecureTokenStorage.saveRefreshToken(result.refreshToken!);
    }
    ApiAuthContext.token = result.token;
    if (result.appNo != null) {
      ApiAuthContext.extraHeaders["x-app-no"] = result.appNo!;
    }
    state = true;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await SecureTokenStorage.clear();
    ApiAuthContext.clear();
    state = false;
  }
}
