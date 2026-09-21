// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kullanıcının doğrulama seviyesi. `IsUser`/`isUserProvider` ile aynı
/// mantık ama bool yerine `VerifiedType` enum'u tutuyor.
///
/// NOT (bilinçli, geçici tasarım kararı): Gerçek doğrulama entegrasyonu
/// (e-posta/SMS kod gönderimi, ülke kimlik doğrulama sistemleri, admin
/// onay akışı) YOK — her `submit...` metodu şimdilik doğrudan bir sonraki
/// seviyeye geçiriyor. Gerçek backend bağlanınca burada asıl doğrulama +
/// bekleme/hata durumları eklenecek; UI tarafı (VerificationProfileCard,
/// form kartları) değişmeyecek.

@ProviderFor(UserVerification)
final userVerificationProvider = UserVerificationProvider._();

/// Kullanıcının doğrulama seviyesi. `IsUser`/`isUserProvider` ile aynı
/// mantık ama bool yerine `VerifiedType` enum'u tutuyor.
///
/// NOT (bilinçli, geçici tasarım kararı): Gerçek doğrulama entegrasyonu
/// (e-posta/SMS kod gönderimi, ülke kimlik doğrulama sistemleri, admin
/// onay akışı) YOK — her `submit...` metodu şimdilik doğrudan bir sonraki
/// seviyeye geçiriyor. Gerçek backend bağlanınca burada asıl doğrulama +
/// bekleme/hata durumları eklenecek; UI tarafı (VerificationProfileCard,
/// form kartları) değişmeyecek.
final class UserVerificationProvider
    extends $NotifierProvider<UserVerification, VerifiedType> {
  /// Kullanıcının doğrulama seviyesi. `IsUser`/`isUserProvider` ile aynı
  /// mantık ama bool yerine `VerifiedType` enum'u tutuyor.
  ///
  /// NOT (bilinçli, geçici tasarım kararı): Gerçek doğrulama entegrasyonu
  /// (e-posta/SMS kod gönderimi, ülke kimlik doğrulama sistemleri, admin
  /// onay akışı) YOK — her `submit...` metodu şimdilik doğrudan bir sonraki
  /// seviyeye geçiriyor. Gerçek backend bağlanınca burada asıl doğrulama +
  /// bekleme/hata durumları eklenecek; UI tarafı (VerificationProfileCard,
  /// form kartları) değişmeyecek.
  UserVerificationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userVerificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userVerificationHash();

  @$internal
  @override
  UserVerification create() => UserVerification();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifiedType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifiedType>(value),
    );
  }
}

String _$userVerificationHash() => r'9589c676ae931750a94dca976e97a2eec71294b3';

/// Kullanıcının doğrulama seviyesi. `IsUser`/`isUserProvider` ile aynı
/// mantık ama bool yerine `VerifiedType` enum'u tutuyor.
///
/// NOT (bilinçli, geçici tasarım kararı): Gerçek doğrulama entegrasyonu
/// (e-posta/SMS kod gönderimi, ülke kimlik doğrulama sistemleri, admin
/// onay akışı) YOK — her `submit...` metodu şimdilik doğrudan bir sonraki
/// seviyeye geçiriyor. Gerçek backend bağlanınca burada asıl doğrulama +
/// bekleme/hata durumları eklenecek; UI tarafı (VerificationProfileCard,
/// form kartları) değişmeyecek.

abstract class _$UserVerification extends $Notifier<VerifiedType> {
  VerifiedType build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VerifiedType, VerifiedType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerifiedType, VerifiedType>,
              VerifiedType,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
