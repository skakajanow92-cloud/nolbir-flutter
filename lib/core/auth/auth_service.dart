class AuthUser {
  final String uid;
  final String? email;
  final bool emailVerified;
  const AuthUser({required this.uid, this.email, this.emailVerified = false});
}

class AuthException implements Exception {
  final String code;
  final String message;
  const AuthException(this.code, this.message);
  @override
  String toString() => message;
}

abstract class AuthService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;
  Future<void> signInWithEmail(String email, String password);
  Future<void> registerWithEmail(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<String?> getIdToken({bool forceRefresh = false});
}
