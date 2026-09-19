// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kullanıcının oturum durumu.
///
/// NOT (bilinçli, geçici tasarım kararı): Şu an gerçek kimlik doğrulama
/// YOK — `login`/`register` çağrıları boş/geçersiz olmadığı sürece
/// başarılı sayılır ve state'i `true` yapar. Gerçek backend'e bağlanınca
/// (JWT/token, secure storage, sunucu tarafı e-posta unique kontrolü vb.)
/// burası değişecek — ama ProfileTab'ın gate mantığı (isUserProvider'ı
/// izleyip true/false'a göre dallanma) AYNI kalacak.

@ProviderFor(IsUser)
final isUserProvider = IsUserProvider._();

/// Kullanıcının oturum durumu.
///
/// NOT (bilinçli, geçici tasarım kararı): Şu an gerçek kimlik doğrulama
/// YOK — `login`/`register` çağrıları boş/geçersiz olmadığı sürece
/// başarılı sayılır ve state'i `true` yapar. Gerçek backend'e bağlanınca
/// (JWT/token, secure storage, sunucu tarafı e-posta unique kontrolü vb.)
/// burası değişecek — ama ProfileTab'ın gate mantığı (isUserProvider'ı
/// izleyip true/false'a göre dallanma) AYNI kalacak.
final class IsUserProvider extends $NotifierProvider<IsUser, bool> {
  /// Kullanıcının oturum durumu.
  ///
  /// NOT (bilinçli, geçici tasarım kararı): Şu an gerçek kimlik doğrulama
  /// YOK — `login`/`register` çağrıları boş/geçersiz olmadığı sürece
  /// başarılı sayılır ve state'i `true` yapar. Gerçek backend'e bağlanınca
  /// (JWT/token, secure storage, sunucu tarafı e-posta unique kontrolü vb.)
  /// burası değişecek — ama ProfileTab'ın gate mantığı (isUserProvider'ı
  /// izleyip true/false'a göre dallanma) AYNI kalacak.
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

String _$isUserHash() => r'8d175cc669c48921d3c09357078c95498fa641c0';

/// Kullanıcının oturum durumu.
///
/// NOT (bilinçli, geçici tasarım kararı): Şu an gerçek kimlik doğrulama
/// YOK — `login`/`register` çağrıları boş/geçersiz olmadığı sürece
/// başarılı sayılır ve state'i `true` yapar. Gerçek backend'e bağlanınca
/// (JWT/token, secure storage, sunucu tarafı e-posta unique kontrolü vb.)
/// burası değişecek — ama ProfileTab'ın gate mantığı (isUserProvider'ı
/// izleyip true/false'a göre dallanma) AYNI kalacak.

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
