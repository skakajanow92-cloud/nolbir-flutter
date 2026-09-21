import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/verification.dart';

part 'verification_providers.g.dart';

/// Kullanıcının doğrulama seviyesi. `IsUser`/`isUserProvider` ile aynı
/// mantık ama bool yerine `VerifiedType` enum'u tutuyor.
///
/// NOT (bilinçli, geçici tasarım kararı): Gerçek doğrulama entegrasyonu
/// (e-posta/SMS kod gönderimi, ülke kimlik doğrulama sistemleri, admin
/// onay akışı) YOK — her `submit...` metodu şimdilik doğrudan bir sonraki
/// seviyeye geçiriyor. Gerçek backend bağlanınca burada asıl doğrulama +
/// bekleme/hata durumları eklenecek; UI tarafı (VerificationProfileCard,
/// form kartları) değişmeyecek.
@riverpod
class UserVerification extends _$UserVerification {
  @override
  VerifiedType build() => VerifiedType.none;

  void submitEmailCode(String code) {
    if (state.index < VerifiedType.a1.index) state = VerifiedType.a1;
  }

  void submitPhoneCode(String code) {
    if (state.index < VerifiedType.a2.index) state = VerifiedType.a2;
  }

  void submitNationalDocument({required String documentNumber}) {
    if (state.index < VerifiedType.b1.index) state = VerifiedType.b1;
  }

  void submitInternationalDocument({required String documentNumber}) {
    if (state.index < VerifiedType.b2.index) state = VerifiedType.b2;
  }

  /// C1: şube başvurusu ya da canlı görüşme talebi. NOT: gerçek akışta bu
  /// çağrı "beklemede" durumuna düşer, admin onaylayana kadar seviye
  /// atlanmaz — demo modunda doğrudan onaylanmış sayılıyor.
  void submitFullAccessRequest() {
    if (state.index < VerifiedType.c1.index) state = VerifiedType.c1;
  }
}
