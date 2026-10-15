import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth);
  final FirebaseAuth _auth;

  AuthUser? _map(User? u) => u == null
      ? null
      : AuthUser(uid: u.uid, email: u.email, emailVerified: u.emailVerified);

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(_map);

  @override
  Future<void> signInWithEmail(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<void> registerWithEmail(String email, String password) => _guard(
    () =>
        _auth.createUserWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<void> sendEmailVerification() =>
      _guard(() async => _auth.currentUser?.sendEmailVerification());

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async =>
      _auth.currentUser?.getIdToken(forceRefresh);

  Future<void> _guard(Future<dynamic> Function() run) async {
    try {
      await run();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, _message(e.code));
    }
  }

  String _message(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'E-posta veya şifre hatalı.',
    'email-already-in-use' => 'Bu e-posta zaten kayıtlı.',
    'weak-password' => 'Şifre çok zayıf.',
    'invalid-email' => 'Geçersiz e-posta adresi.',
    'too-many-requests' => 'Çok fazla deneme yapıldı, biraz bekle.',
    'network-request-failed' => 'İnternet bağlantınızı kontrol edin.',
    _ => 'İşlem başarısız ($code).',
  };
}
