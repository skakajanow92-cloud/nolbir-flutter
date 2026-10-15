import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_service.dart';
import 'firebase_auth_service.dart';

part 'auth_service_providers.g.dart';

/// Production'da tek satır değişir:
/// Yol A: aynı kalır. Yol B: BackendAuthService(...) döner.
@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => FirebaseAuthService(FirebaseAuth.instance);