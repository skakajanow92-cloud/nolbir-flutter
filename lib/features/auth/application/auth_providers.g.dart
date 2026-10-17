// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Hangi `AuthRepository` implementasyonunun kullanılacağı — bugün mock,
/// gerçek backend'e geçerken TEK satır: `MockAuthRepository()` ->
/// `DioAuthRepository()`. Diğer tüm repository provider'larıyla
/// (`cartRepositoryProvider`, `collectionRepositoryProvider`,
/// `mediaUploaderProvider`) AYNI desen.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Hangi `AuthRepository` implementasyonunun kullanılacağı — bugün mock,
/// gerçek backend'e geçerken TEK satır: `MockAuthRepository()` ->
/// `DioAuthRepository()`. Diğer tüm repository provider'larıyla
/// (`cartRepositoryProvider`, `collectionRepositoryProvider`,
/// `mediaUploaderProvider`) AYNI desen.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Hangi `AuthRepository` implementasyonunun kullanılacağı — bugün mock,
  /// gerçek backend'e geçerken TEK satır: `MockAuthRepository()` ->
  /// `DioAuthRepository()`. Diğer tüm repository provider'larıyla
  /// (`cartRepositoryProvider`, `collectionRepositoryProvider`,
  /// `mediaUploaderProvider`) AYNI desen.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'387b6e9a78d246a81ba25c340fe035788819ea94';

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

@ProviderFor(IsUser)
final isUserProvider = IsUserProvider._();

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
final class IsUserProvider extends $NotifierProvider<IsUser, bool> {
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
  IsUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isUserHash();

  @$internal
  @override
  IsUser create() => IsUser();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isUserHash() => r'341276d8957dd05d4547dd5f436ed03a0b2bfe24';

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

abstract class _$IsUser extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
