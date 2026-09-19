import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// Kullanıcının oturum durumu.
///
/// NOT (bilinçli, geçici tasarım kararı): Şu an gerçek kimlik doğrulama
/// YOK — `login`/`register` çağrıları boş/geçersiz olmadığı sürece
/// başarılı sayılır ve state'i `true` yapar. Gerçek backend'e bağlanınca
/// (JWT/token, secure storage, sunucu tarafı e-posta unique kontrolü vb.)
/// burası değişecek — ama ProfileTab'ın gate mantığı (isUserProvider'ı
/// izleyip true/false'a göre dallanma) AYNI kalacak.
@riverpod
class IsUser extends _$IsUser {
  @override
  bool build() => false; // varsayılan: oturum açılmamış

  /// Giriş formunun "Giriş Yap" butonundan çağrılır.
  /// identifier: T.C. kimlik no / e-posta / telefondan biri olabilir.
  void login({required String identifier, required String password}) {
    state = true;
  }

  /// Kayıt formunun "Kayıt Ol" butonundan çağrılır.
  ///
  /// VARSAYIM: Kayıt sonrası otomatik giriş yapılmış sayılıyor (yaygın
  /// bir UX tercihi) — backend bağlanırken bu davranış değişebilir,
  /// örneğin e-posta doğrulaması beklenen bir ara adım eklenebilir.
  ///
  /// email: sunucu tarafında unique olacak, ilk hesap açılışında istenen
  /// tek zorunlu kimlik alanı. password: genel oturum tokeni için.
  /// pin: içerideki özel/kritik işlemler için ayrı bir token'a bağlanacak.
  void register({
    required String email,
    required String password,
    required String pin,
  }) {
    state = true;
  }

  void logout() {
    state = false;
  }
}
