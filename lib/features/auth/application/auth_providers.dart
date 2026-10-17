import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_auth_context.dart';

part 'auth_providers.g.dart';

// ---------------------------------------------------------------------------
// Auth modeli ve arayüzü
//
// Şimdilik hiçbir backend yok: aşağıdaki [LocalAuthService] her şeyi bellekte
// tutar (uygulama kapanınca kullanıcılar silinir). Kendi backend'in hazır
// olunca yalnızca [AuthService] arayüzünü uygulayan yeni bir sınıf yazıp
// [authServiceProvider]'ı ona yönlendirmen yeterli; UI ve [IsUser] değişmez.
// ---------------------------------------------------------------------------

/// UI'nin yakalayıp kullanıcıya gösterdiği hata.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class AuthUser {
  const AuthUser({required this.uid, required this.email});

  final String uid;
  final String email;
}

abstract class AuthService {
  AuthUser? get currentUser;

  /// Oturum açıldığında/kapandığında yeni değer yayar (kapanınca null).
  Stream<AuthUser?> get authStateChanges;

  Future<void> signInWithEmail(String identifier, String password);

  /// Başarılı kayıt sonrası kullanıcı otomatik oturum açmış olur.
  Future<void> registerWithEmail(String email, String password);

  Future<void> signOut();

  /// API isteklerine eklenecek token. Backend yokken null döner.
  Future<String?> getIdToken();
}

/// Yalnızca geliştirme içindir: kullanıcılar bellekte, şifreler düz metin
/// tutulur. Üretimde KULLANMA.
class LocalAuthService implements AuthService {
  final Map<String, String> _passwordsByEmail = {};
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  String _normalize(String email) => email.trim().toLowerCase();

  // Gerçek ağ gecikmesini taklit eder; yükleniyor durumunun görünmesi için.
  Future<void> _fakeLatency() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  void _setUser(AuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<void> signInWithEmail(String identifier, String password) async {
    await _fakeLatency();
    final email = _normalize(identifier);
    final stored = _passwordsByEmail[email];
    if (stored == null || stored != password) {
      throw const AuthException('E-posta veya şifre hatalı');
    }
    _setUser(AuthUser(uid: email, email: email));
  }

  @override
  Future<void> registerWithEmail(String email, String password) async {
    await _fakeLatency();
    final normalized = _normalize(email);
    if (_passwordsByEmail.containsKey(normalized)) {
      throw const AuthException('Bu e-posta zaten kayıtlı');
    }
    _passwordsByEmail[normalized] = password;
    _setUser(AuthUser(uid: normalized, email: normalized));
  }

  @override
  Future<void> signOut() async {
    _setUser(null);
  }

  @override
  Future<String?> getIdToken() async => null;

  void dispose() => _controller.close();
}

/// Backend geldiğinde burada [LocalAuthService] yerine gerçek servisi ver.
final authServiceProvider = Provider<AuthService>((ref) {
  final service = LocalAuthService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// Giriş durumu
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class IsUser extends _$IsUser {
  @override
  bool build() {
    final service = ref.watch(authServiceProvider);

    ApiAuthContext.tokenProvider =
        service.currentUser != null ? service.getIdToken : null;

    final sub = service.authStateChanges.listen((u) {
      state = u != null;
      ApiAuthContext.tokenProvider = u != null ? service.getIdToken : null;
    });
    ref.onDispose(sub.cancel);
    return service.currentUser != null;
  }

  Future<void> login({required String identifier, required String password}) =>
      ref.read(authServiceProvider).signInWithEmail(identifier, password);

  Future<void> register({
    required String email,
    required String password,
    required String pin, // şimdilik kullanılmıyor, bkz. PIN notu
  }) =>
      ref.read(authServiceProvider).registerWithEmail(email, password);

  Future<void> logout() => ref.read(authServiceProvider).signOut();
}
