import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/auth/auth_service_providers.dart';
import '../../../core/network/api_auth_context.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
class IsUser extends _$IsUser {
  @override
  bool build() {
    final service = ref.watch(authServiceProvider);
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