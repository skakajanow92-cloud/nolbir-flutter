/// API isteklerine otomatik eklenecek kimlik bilgilerinin TEK kaynağı.
///
/// `ApiClient` bu sınıfı okur ama kimseyle doğrudan bağımlı DEĞİLDİR —
/// ileride gerçek bir auth/login modülü eklendiğinde sadece bu sınıfın
/// değerleri güncellenir (`ApiAuthContext.token = ...`), `ApiClient`'ın
/// kendisine hiç dokunulmaz. Aynı ayrım `CartRepository`/`ProfileRepository`
/// ile provider'lar arasındaki bağımlılıkla aynı ilke.
class ApiAuthContext {
  ApiAuthContext._();

  static String? token;

  /// Backend'in modül/uygulama bazlı erişim kontrolü gibi ekstra header
  /// istediği durumlar için (ör. Nolbir'de "x-app-no").
  static final Map<String, String> extraHeaders = {};

  static void clear() {
    token = null;
    extraHeaders.clear();
  }
}
