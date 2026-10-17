/// Kimlik doğrulama akışının 5 sıralı adımı (A1 -> A2 -> B1 -> B2 -> C1).
///
/// BİLİNÇLİ TASARIM KARARI: sıra, enum bildirim sırasıyla (`.index`) birebir
/// eşleşir — bu sayede "şu seviyeye ulaşıldı mı" kontrolü her yerde basit bir
/// `level.index >= VerificationLevel.phoneVerified.index` karşılaştırmasıyla
/// yapılabilir. Yeni bir adım eklenirse SADECE doğru sıraya eklenmesi yeterli,
/// başka hiçbir karşılaştırma kodu değişmez.
///
/// AKIŞ KURALI (kullanıcıdan): adımlar KESİNLİKLE ard arda ilerler — yerli
/// evrak (B1) onaylanmadan uluslararası belge (B2) adımına geçilemez, belgeler
/// onaylanmadan tam erişim (C1) talebi açılamaz. Bu sıralama burada değil,
/// `VerificationRepository`/`VerificationStatusNotifier` tarafında, "önceki
/// adım approved değilse sıradaki adım available değildir" kuralıyla
/// uygulanır (bkz. o dosyalardaki doc comment).
///
/// Akış nerede bırakılırsa bırakılsın, o ana kadar ONAYLANMIŞ olan en yüksek
/// seviyenin verdiği izinler çalışmaya devam eder — bu yüzden "mevcut izin
/// seviyesi" tek bir alanla (`VerificationStatus.approvedLevel`) temsil
/// edilir, ileride diğer modüller bu seviyeyi okuyarak kendi özelliklerini
/// açıp kapatabilir (ör. `approvedLevel.index >= VerificationLevel.
/// nationalDocumentVerified.index` -> "para transferi" gibi bir özelliği aç).
enum VerificationLevel {
  /// Sadece kayıtlı/giriş yapmış, hiçbir doğrulama tamamlanmamış.
  none,

  /// A1: e-posta + kod onayı.
  emailVerified,

  /// A2: telefon + SMS kod onayı.
  phoneVerified,

  /// B1: kimlik/ülke içi yerli evrak.
  nationalDocumentVerified,

  /// B2: pasaport/uluslararası belge.
  internationalDocumentVerified,

  /// C1: şube başvurusu ya da canlı görüşme ile tam erişim.
  fullAccess,
}

extension VerificationLevelX on VerificationLevel {
  /// Sıradaki adım — son adımdaysa kendisini döner (daha ileri adım yok).
  VerificationLevel get next {
    final nextIndex = index + 1;
    if (nextIndex >= VerificationLevel.values.length) return this;
    return VerificationLevel.values[nextIndex];
  }

  bool get isMaxLevel => this == VerificationLevel.fullAccess;

  String get label {
    switch (this) {
      case VerificationLevel.none:
        return "Doğrulanmadı";
      case VerificationLevel.emailVerified:
        return "A1 · E-posta Doğrulama";
      case VerificationLevel.phoneVerified:
        return "A2 · Telefon Doğrulama";
      case VerificationLevel.nationalDocumentVerified:
        return "B1 · Yerli Evrak Doğrulama";
      case VerificationLevel.internationalDocumentVerified:
        return "B2 · Uluslararası Belge Doğrulama";
      case VerificationLevel.fullAccess:
        return "C1 · Tam Erişim";
    }
  }

  /// Her adımın ne işe yaradığını anlatan uzun açıklama — Doğrulama
  /// Merkezi'nde başlık altında ve adım satırlarında gösterilir.
  String get description {
    switch (this) {
      case VerificationLevel.none:
        return "Henüz herhangi bir doğrulama yapılmadı.";
      case VerificationLevel.emailVerified:
        return "Geçerli bir e-posta adresiyle doğrulanır. Paylaşılan "
            "içerikleri beğenme ve yorum yapma izni verir.";
      case VerificationLevel.phoneVerified:
        return "Geçerli bir telefon numarasıyla doğrulanır. Beğeni/yoruma "
            "ek olarak kendi içeriğini paylaşma izni verir.";
      case VerificationLevel.nationalDocumentVerified:
        return "Kimlik ya da ülke içinde geçerli yerli bir evrak, admin "
            "incelemesinden geçirilerek doğrulanır. Cüzdan açma, para "
            "işlemleri ve kendi ülkende transfer izni verir.";
      case VerificationLevel.internationalDocumentVerified:
        return "Pasaport ya da geçerli uluslararası bir belge admin "
            "incelemesinden geçirilerek doğrulanır. Farklı para "
            "birimlerinde hesap açma ve uluslararası döviz işlemleri "
            "imkanı sağlar.";
      case VerificationLevel.fullAccess:
        return "Şubeye tüm evraklarla başvuru ya da admin ile canlı "
            "görüşme yoluyla yapılır. Admin/ortaklık/ajanta/şube açma "
            "gibi sınırsız imkanların tamamını kullanma yetkisi verir.";
    }
  }

  // Kümülatif yetkiler — her seviye bir öncekinin hepsini kapsar (bkz. dosya
  // başı doc comment — `approvedLevel` tek kaynak, diğer modüller bu
  // getter'ları okuyarak kendi özelliklerini açıp kapatır).
  bool get canLikeAndComment => index >= VerificationLevel.emailVerified.index;
  bool get canPostContent => index >= VerificationLevel.phoneVerified.index;
  bool get canOpenWalletAndTransfer =>
      index >= VerificationLevel.nationalDocumentVerified.index;
  bool get canMultiCurrencyAndInvest =>
      index >= VerificationLevel.internationalDocumentVerified.index;
  bool get hasFullAccess => index >= VerificationLevel.fullAccess.index;
}
