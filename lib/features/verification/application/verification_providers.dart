import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/verification_repository.dart';

part 'verification_providers.g.dart';

/// Hangi `VerificationRepository` implementasyonunun kullanılacağı — bugün
/// mock (admin onayını 3sn gecikmeyle simüle eder), gerçek backend'e
/// geçerken TEK satır: `MockVerificationRepository()` ->
/// `DioVerificationRepository()`. `authRepositoryProvider` ile AYNI desen.
@riverpod
VerificationRepository verificationRepository(Ref ref) =>
    MockVerificationRepository();

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
@riverpod
class VerificationStatusNotifier extends _$VerificationStatusNotifier {
  @override
  Future<VerificationStatus> build() {
    return ref.read(verificationRepositoryProvider).fetchStatus();
  }

  VerificationRepository get _repo => ref.read(verificationRepositoryProvider);

  /// A1 adım 1: koda gönder. Hata (`ApiException`) çağıran widget'a
  /// fırlatılır — state burada DEĞİŞMEZ, çağıran taraf try/catch ile
  /// kendi yükleniyor/hata UI'ını yönetir (bkz. `LoginRegisterCardView`
  /// ile aynı desen).
  Future<void> sendEmailCode(String email) => _repo.sendEmailCode(email: email);

  /// A1 adım 2: kodu onayla. Anlık onaylanır (e-posta/telefon hiç
  /// `pending`'e girmez, bkz. `StepStatus` doc comment), state güncellenir.
  Future<void> confirmEmailCode({
    required String email,
    required String code,
  }) async {
    final status = await _repo.confirmEmailCode(email: email, code: code);
    state = AsyncData(status);
  }

  Future<void> sendPhoneCode(String phoneNumber) =>
      _repo.sendPhoneCode(phoneNumber: phoneNumber);

  Future<void> confirmPhoneCode({
    required String phoneNumber,
    required String code,
  }) async {
    final status = await _repo.confirmPhoneCode(
      phoneNumber: phoneNumber,
      code: code,
    );
    state = AsyncData(status);
  }

  /// B1: admin incelemesine düşer — dönen `status.pendingLevel` dolu olur,
  /// `approvedLevel` DEĞİŞMEZ.
  Future<void> submitNationalDocument({
    required String frontImageUrl,
    String? backImageUrl,
  }) async {
    final status = await _repo.submitNationalDocument(
      frontImageUrl: frontImageUrl,
      backImageUrl: backImageUrl,
    );
    state = AsyncData(status);
  }

  /// B2: admin incelemesine düşer.
  Future<void> submitInternationalDocument({
    required String passportImageUrl,
  }) async {
    final status = await _repo.submitInternationalDocument(
      passportImageUrl: passportImageUrl,
    );
    state = AsyncData(status);
  }

  /// C1: admin incelemesine düşer.
  Future<void> submitFullAccessRequest({
    required FullAccessRequestType type,
    String? note,
  }) async {
    final status = await _repo.submitFullAccessRequest(type: type, note: note);
    state = AsyncData(status);
  }

  /// Ekran her açıldığında (ör. kullanıcı admin onayını kontrol etmek için
  /// geri dönüyor) durumu sunucudan tazelemek için — mock'ta zaten otomatik
  /// onaylanıyor ama gerçek backend'de bu, "pending" bir adımın onaylanıp
  /// onaylanmadığını öğrenmenin tek yolu.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(verificationRepositoryProvider).fetchStatus(),
    );
  }
}
