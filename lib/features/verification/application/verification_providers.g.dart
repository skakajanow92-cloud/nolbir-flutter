// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Hangi `VerificationRepository` implementasyonunun kullanılacağı — bugün
/// mock (admin onayını 3sn gecikmeyle simüle eder), gerçek backend'e
/// geçerken TEK satır: `MockVerificationRepository()` ->
/// `DioVerificationRepository()`. `authRepositoryProvider` ile AYNI desen.

@ProviderFor(verificationRepository)
final verificationRepositoryProvider = VerificationRepositoryProvider._();

/// Hangi `VerificationRepository` implementasyonunun kullanılacağı — bugün
/// mock (admin onayını 3sn gecikmeyle simüle eder), gerçek backend'e
/// geçerken TEK satır: `MockVerificationRepository()` ->
/// `DioVerificationRepository()`. `authRepositoryProvider` ile AYNI desen.

final class VerificationRepositoryProvider
    extends
        $FunctionalProvider<
          VerificationRepository,
          VerificationRepository,
          VerificationRepository
        >
    with $Provider<VerificationRepository> {
  /// Hangi `VerificationRepository` implementasyonunun kullanılacağı — bugün
  /// mock (admin onayını 3sn gecikmeyle simüle eder), gerçek backend'e
  /// geçerken TEK satır: `MockVerificationRepository()` ->
  /// `DioVerificationRepository()`. `authRepositoryProvider` ile AYNI desen.
  VerificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<VerificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerificationRepository create(Ref ref) {
    return verificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerificationRepository>(value),
    );
  }
}

String _$verificationRepositoryHash() =>
    r'91a23e90a07d13b53b52d35cad4ca330a894e30d';

/// Kullanıcının doğrulama durumunun TEK gerçek kaynağı.
///
/// GÜNCELLEME (eski `UserVerification`/`VerifiedType` sisteminin yerine
/// geçti): artık `VerificationRepository` üzerinden gerçek bir admin onay
/// akışına bağlı — `submit...` metodu çağrıldığında durum anında
/// `approved` olmaz, `VerificationStatus.pendingLevel`e düşer ve admin
/// onaylayana kadar (mock'ta: 3sn sonra kendiliğinden) o seviyenin izinleri
/// AÇILMAZ. UI tarafı (kart görünümleri, `VerificationProfileCardView`,
/// `FullAccessGate`) `VerificationStatus.statusFor(level)` ile adımın
/// `locked`/`available`/`pending`/`approved`/`rejected` durumunu okur.
///
/// `AsyncNotifier` kullanılıyor (diğer feed provider'larıyla aynı desen)
/// çünkü `fetchStatus()` ve her `submit...` çağrısı artık gerçekten
/// asenkron — repository'nin gecikmeli/ağ tabanlı doğası UI'a `AsyncValue`
/// olarak yansıyor.

@ProviderFor(VerificationStatusNotifier)
final verificationStatusProvider = VerificationStatusNotifierProvider._();

/// Kullanıcının doğrulama durumunun TEK gerçek kaynağı.
///
/// GÜNCELLEME (eski `UserVerification`/`VerifiedType` sisteminin yerine
/// geçti): artık `VerificationRepository` üzerinden gerçek bir admin onay
/// akışına bağlı — `submit...` metodu çağrıldığında durum anında
/// `approved` olmaz, `VerificationStatus.pendingLevel`e düşer ve admin
/// onaylayana kadar (mock'ta: 3sn sonra kendiliğinden) o seviyenin izinleri
/// AÇILMAZ. UI tarafı (kart görünümleri, `VerificationProfileCardView`,
/// `FullAccessGate`) `VerificationStatus.statusFor(level)` ile adımın
/// `locked`/`available`/`pending`/`approved`/`rejected` durumunu okur.
///
/// `AsyncNotifier` kullanılıyor (diğer feed provider'larıyla aynı desen)
/// çünkü `fetchStatus()` ve her `submit...` çağrısı artık gerçekten
/// asenkron — repository'nin gecikmeli/ağ tabanlı doğası UI'a `AsyncValue`
/// olarak yansıyor.
final class VerificationStatusNotifierProvider
    extends
        $AsyncNotifierProvider<VerificationStatusNotifier, VerificationStatus> {
  /// Kullanıcının doğrulama durumunun TEK gerçek kaynağı.
  ///
  /// GÜNCELLEME (eski `UserVerification`/`VerifiedType` sisteminin yerine
  /// geçti): artık `VerificationRepository` üzerinden gerçek bir admin onay
  /// akışına bağlı — `submit...` metodu çağrıldığında durum anında
  /// `approved` olmaz, `VerificationStatus.pendingLevel`e düşer ve admin
  /// onaylayana kadar (mock'ta: 3sn sonra kendiliğinden) o seviyenin izinleri
  /// AÇILMAZ. UI tarafı (kart görünümleri, `VerificationProfileCardView`,
  /// `FullAccessGate`) `VerificationStatus.statusFor(level)` ile adımın
  /// `locked`/`available`/`pending`/`approved`/`rejected` durumunu okur.
  ///
  /// `AsyncNotifier` kullanılıyor (diğer feed provider'larıyla aynı desen)
  /// çünkü `fetchStatus()` ve her `submit...` çağrısı artık gerçekten
  /// asenkron — repository'nin gecikmeli/ağ tabanlı doğası UI'a `AsyncValue`
  /// olarak yansıyor.
  VerificationStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationStatusNotifierHash();

  @$internal
  @override
  VerificationStatusNotifier create() => VerificationStatusNotifier();
}

String _$verificationStatusNotifierHash() =>
    r'f9439f60d10e7dc5cb893436abae5a264ccece59';

/// Kullanıcının doğrulama durumunun TEK gerçek kaynağı.
///
/// GÜNCELLEME (eski `UserVerification`/`VerifiedType` sisteminin yerine
/// geçti): artık `VerificationRepository` üzerinden gerçek bir admin onay
/// akışına bağlı — `submit...` metodu çağrıldığında durum anında
/// `approved` olmaz, `VerificationStatus.pendingLevel`e düşer ve admin
/// onaylayana kadar (mock'ta: 3sn sonra kendiliğinden) o seviyenin izinleri
/// AÇILMAZ. UI tarafı (kart görünümleri, `VerificationProfileCardView`,
/// `FullAccessGate`) `VerificationStatus.statusFor(level)` ile adımın
/// `locked`/`available`/`pending`/`approved`/`rejected` durumunu okur.
///
/// `AsyncNotifier` kullanılıyor (diğer feed provider'larıyla aynı desen)
/// çünkü `fetchStatus()` ve her `submit...` çağrısı artık gerçekten
/// asenkron — repository'nin gecikmeli/ağ tabanlı doğası UI'a `AsyncValue`
/// olarak yansıyor.

abstract class _$VerificationStatusNotifier
    extends $AsyncNotifier<VerificationStatus> {
  FutureOr<VerificationStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<VerificationStatus>, VerificationStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VerificationStatus>, VerificationStatus>,
              AsyncValue<VerificationStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
