/// Kullanıcının doğrulama seviyesi — kümülatif bir "tier" sistemi.
/// Her seviye bir ÖNCEKİNİN tüm yetkilerini kapsar (bkz. capability
/// getter'ları — `index >= X.index` şeklinde kontrol ediliyor). Tekil bir
/// `isVerified` bayrağı yerine bilinçli olarak bu enum kullanılıyor.
enum VerifiedType { none, a1, a2, b1, b2, c1 }

enum VerificationMethod {
  none,
  emailCode,
  phoneCode,
  nationalDocument,
  internationalDocument,
  branchOrLiveCall,
}

extension VerifiedTypeMeta on VerifiedType {
  String get label => switch (this) {
        VerifiedType.none => "Doğrulanmamış",
        VerifiedType.a1 => "A1 · E-posta Doğrulama",
        VerifiedType.a2 => "A2 · Telefon Doğrulama",
        VerifiedType.b1 => "B1 · Kimlik Doğrulama",
        VerifiedType.b2 => "B2 · Uluslararası Doğrulama",
        VerifiedType.c1 => "C1 · Tam Yetki",
      };

  String get description => switch (this) {
        VerifiedType.none => "Henüz herhangi bir doğrulama yapılmadı.",
        VerifiedType.a1 =>
          "Geçerli bir e-posta adresiyle doğrulanır. Paylaşılan içerikleri beğenme ve yorum yapma izni verir.",
        VerifiedType.a2 =>
          "Geçerli bir telefon numarasıyla doğrulanır. Beğeni/yoruma ek olarak kendi içeriğini paylaşma izni verir.",
        VerifiedType.b1 =>
          "Kimlik ya da ülke içinde geçerli yerli bir evrak, ilgili ülkenin kendi doğrulama sisteminden geçirilerek yapılır. Cüzdan açma, para işlemleri ve transfer izni verir.",
        VerifiedType.b2 =>
          "Pasaport ya da geçerli uluslararası bir belge, ilgili ülkenin doğrulama sistemi üzerinden yapılır. Farklı para birimlerinde hesap açma, borsa yatırımı, vize başvuru evrakı için aracılara doğrudan erişim ve uluslararası otel rezervasyonu gibi imkanlar sağlar.",
        VerifiedType.c1 =>
          "Şubeye tüm evraklarla başvuru ya da admin ile canlı görüşme (görüşme kaydı sisteme işlenir) yoluyla yapılır. Tüm imkanları kullanma yetkisi verir.",
      };

  VerificationMethod get method => switch (this) {
        VerifiedType.none => VerificationMethod.none,
        VerifiedType.a1 => VerificationMethod.emailCode,
        VerifiedType.a2 => VerificationMethod.phoneCode,
        VerifiedType.b1 => VerificationMethod.nationalDocument,
        VerifiedType.b2 => VerificationMethod.internationalDocument,
        VerifiedType.c1 => VerificationMethod.branchOrLiveCall,
      };

  // Kümülatif yetkiler — her seviye bir öncekinin hepsini kapsar.
  bool get canLikeAndComment => index >= VerifiedType.a1.index;
  bool get canPostContent => index >= VerifiedType.a2.index;
  bool get canOpenWalletAndTransfer => index >= VerifiedType.b1.index;
  bool get canMultiCurrencyAndInvest => index >= VerifiedType.b2.index;
  bool get hasFullAccess => index >= VerifiedType.c1.index;

  /// Doğrulama merdiveninde bir sonraki basamak — en üstteyse null.
  VerifiedType? get nextLevel {
    final values = VerifiedType.values;
    final i = index + 1;
    return i < values.length ? values[i] : null;
  }
}
