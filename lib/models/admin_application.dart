import 'dart:typed_data';

/// Başvurulabilecek maaşlı admin pozisyonları.
enum AdminRole { systemAdmin, operations, finance, humanResources, moderation }

extension AdminRoleMeta on AdminRole {
  String get label => switch (this) {
        AdminRole.systemAdmin => "Sistem Yöneticisi",
        AdminRole.operations => "Operasyon Yöneticisi",
        AdminRole.finance => "Finans Yöneticisi",
        AdminRole.humanResources => "İnsan Kaynakları Yöneticisi",
        AdminRole.moderation => "İçerik Moderasyon Yöneticisi",
      };

  String get description => switch (this) {
        AdminRole.systemAdmin => "Sistem yapılandırması, kullanıcı ve yetki yönetimi",
        AdminRole.operations =>
          "Mağaza, şube ve ajanta operasyonlarının günlük yönetimi",
        AdminRole.finance => "Ödeme, transfer ve hesap işlemlerinin denetimi",
        AdminRole.humanResources => "Personel başvuruları ve çalışan süreçleri",
        AdminRole.moderation =>
          "Paylaşılan içeriklerin denetimi ve şikâyet yönetimi",
      };

  /// Para akışına dokunan rol mesleki yeterlilik belgesi ister. Başka bir
  /// rol için de gerekirse tek yerden (burası) genişletilir.
  bool get requiresProfessionalCertificate => this == AdminRole.finance;
}

/// İstenebilecek belge türleri. Hangilerinin ZORUNLU olduğu burada değil,
/// başvurunun durumuna göre `AdminApplication.requiredDocumentTypes`'ta
/// hesaplanıyor (uyruk ve pozisyona göre değişiyor).
enum AdminDocumentType {
  identityCard,
  passport,
  applicantPhoto,
  residenceProof,
  workPermit,
  resume,
  diploma,
  criminalRecord,
  employmentHistory,
  professionalCertificate,
  referenceLetter,
}

extension AdminDocumentTypeMeta on AdminDocumentType {
  String get label => switch (this) {
        AdminDocumentType.identityCard => "Kimlik Belgesi",
        AdminDocumentType.passport => "Pasaport",
        AdminDocumentType.applicantPhoto => "Vesikalık Fotoğraf",
        AdminDocumentType.residenceProof => "İkametgâh Belgesi",
        AdminDocumentType.workPermit => "Çalışma İzni",
        AdminDocumentType.resume => "Özgeçmiş (CV)",
        AdminDocumentType.diploma => "Diploma / Mezuniyet Belgesi",
        AdminDocumentType.criminalRecord => "Adli Sicil Kaydı",
        AdminDocumentType.employmentHistory => "Hizmet / İş Geçmişi Dökümü",
        AdminDocumentType.professionalCertificate =>
          "Mesleki Yeterlilik Belgesi",
        AdminDocumentType.referenceLetter => "Referans Mektubu",
      };

  String get description => switch (this) {
        AdminDocumentType.identityCard => "Kimlik veya pasaporttan en az biri",
        AdminDocumentType.passport => "Kimlik veya pasaporttan en az biri",
        AdminDocumentType.applicantPhoto => "Yakın zamanlı vesikalık fotoğraf",
        AdminDocumentType.residenceProof => "Güncel adres doğrulama belgesi",
        AdminDocumentType.workPermit =>
          "Yabancı uyruklular için geçerli çalışma izni",
        AdminDocumentType.resume => "Güncel özgeçmişin (PDF)",
        AdminDocumentType.diploma => "En son mezun olunan okula ait belge",
        AdminDocumentType.criminalRecord =>
          "Son 3 ay içinde alınmış adli sicil kaydı",
        AdminDocumentType.employmentHistory =>
          "Önceki işlerini doğrulayan resmi döküm (opsiyonel)",
        AdminDocumentType.professionalCertificate =>
          "Pozisyonla ilgili lisans/sertifika",
        AdminDocumentType.referenceLetter =>
          "Önceki işverenden referans (opsiyonel)",
      };
}

/// Gerçek dosya seçiciyle alınmış tek bir belge. Bayt tabanlı (web uyumu).
///
/// NOT: Shareholder modülündeki `UploadedDocument`'a çok benziyor ama
/// bilinçli olarak AYRI — o modül test edilip çalışıyor, ona dokunmamak
/// için. İkisi ortak bir `core/documents/` yapısına ileride birleştirilebilir.
class AdminDocument {
  final AdminDocumentType type;
  final String fileName;
  final Uint8List bytes;
  final int fileSizeBytes;
  final String? documentNumber;
  final DateTime uploadedAt;

  const AdminDocument({
    required this.type,
    required this.fileName,
    required this.bytes,
    required this.fileSizeBytes,
    this.documentNumber,
    required this.uploadedAt,
  });

  bool get isImage {
    final n = fileName.toLowerCase();
    return n.endsWith('.png') || n.endsWith('.jpg') || n.endsWith('.jpeg');
  }

  AdminDocument copyWith({String? documentNumber}) {
    return AdminDocument(
      type: type,
      fileName: fileName,
      bytes: bytes,
      fileSizeBytes: fileSizeBytes,
      documentNumber: documentNumber ?? this.documentNumber,
      uploadedAt: uploadedAt,
    );
  }
}

enum AdminApplicationStatus {
  draft,
  submitted,
  underReview,
  interview,
  approved,
  rejected,
}

extension AdminApplicationStatusMeta on AdminApplicationStatus {
  String get label => switch (this) {
        AdminApplicationStatus.draft => "Taslak",
        AdminApplicationStatus.submitted => "Gönderildi",
        AdminApplicationStatus.underReview => "İnceleniyor",
        AdminApplicationStatus.interview => "Mülakat Aşamasında",
        AdminApplicationStatus.approved => "Onaylandı",
        AdminApplicationStatus.rejected => "Reddedildi",
      };
}

/// Maaşlı admin pozisyonu için iş başvurusunun tamamı.
class AdminApplication {
  final AdminRole? role;
  final String fullName;
  final String nationalOrPassportNo;
  final String email;
  final String phone;
  final bool isForeignNational;
  final int yearsOfExperience;
  final double expectedMonthlySalary;
  final String currency;
  final DateTime? availableFrom;
  final String coverLetter;
  final List<AdminDocument> documents;
  final bool acceptedConfidentiality;
  final bool acceptedDataProcessing;
  final AdminApplicationStatus status;
  final DateTime? submittedAt;

  const AdminApplication({
    this.role,
    this.fullName = "",
    this.nationalOrPassportNo = "",
    this.email = "",
    this.phone = "",
    this.isForeignNational = false,
    this.yearsOfExperience = 0,
    this.expectedMonthlySalary = 0,
    this.currency = "TRY",
    this.availableFrom,
    this.coverLetter = "",
    this.documents = const [],
    this.acceptedConfidentiality = false,
    this.acceptedDataProcessing = false,
    this.status = AdminApplicationStatus.draft,
    this.submittedAt,
  });

  AdminDocument? documentOf(AdminDocumentType type) {
    for (final d in documents) {
      if (d.type == type) return d;
    }
    return null;
  }

  /// Kimlik VEYA pasaporttan biri yeterli — tek bir "slot" sayılıyor.
  bool get hasIdentityDocument =>
      documentOf(AdminDocumentType.identityCard) != null ||
      documentOf(AdminDocumentType.passport) != null;

  /// Zorunlu belgeler (kimlik/pasaport slotu HARİÇ) başvuruya göre değişir:
  /// yabancı uyruklu → çalışma izni, finans rolü → mesleki yeterlilik.
  List<AdminDocumentType> get requiredDocumentTypes => [
        AdminDocumentType.applicantPhoto,
        AdminDocumentType.residenceProof,
        AdminDocumentType.resume,
        AdminDocumentType.diploma,
        AdminDocumentType.criminalRecord,
        if (isForeignNational) AdminDocumentType.workPermit,
        if (role?.requiresProfessionalCertificate ?? false)
          AdminDocumentType.professionalCertificate,
      ];

  int get requiredDocumentSlotCount => requiredDocumentTypes.length + 1;

  int get completedDocumentSlotCount =>
      requiredDocumentTypes.where((t) => documentOf(t) != null).length +
      (hasIdentityDocument ? 1 : 0);

  /// Tamamlanmamış her şeyin insan-okunur listesi — hem "gönder" kontrolü
  /// hem de gözden geçirme ekranındaki uyarı bu tek kaynaktan besleniyor.
  List<String> get missingItems {
    final items = <String>[];
    if (role == null) items.add("Başvurulan pozisyon");
    if (fullName.isEmpty) items.add("Ad soyad");
    if (nationalOrPassportNo.isEmpty) items.add("Kimlik/pasaport no");
    if (email.isEmpty) items.add("E-posta");
    if (phone.isEmpty) items.add("Telefon");
    if (expectedMonthlySalary <= 0) items.add("Beklenen maaş");
    if (availableFrom == null) items.add("Başlayabileceği tarih");
    if (!hasIdentityDocument) items.add("Kimlik veya pasaport belgesi");
    for (final t in requiredDocumentTypes) {
      if (documentOf(t) == null) items.add(t.label);
    }
    if (!acceptedConfidentiality) items.add("Gizlilik taahhüdü onayı");
    if (!acceptedDataProcessing) {
      items.add("Kişisel verilerin işlenmesi onayı (KVKK)");
    }
    return items;
  }

  bool get isComplete => missingItems.isEmpty;

  AdminApplication copyWith({
    AdminRole? role,
    String? fullName,
    String? nationalOrPassportNo,
    String? email,
    String? phone,
    bool? isForeignNational,
    int? yearsOfExperience,
    double? expectedMonthlySalary,
    String? currency,
    DateTime? availableFrom,
    String? coverLetter,
    List<AdminDocument>? documents,
    bool? acceptedConfidentiality,
    bool? acceptedDataProcessing,
    AdminApplicationStatus? status,
    DateTime? submittedAt,
  }) {
    return AdminApplication(
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      nationalOrPassportNo: nationalOrPassportNo ?? this.nationalOrPassportNo,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isForeignNational: isForeignNational ?? this.isForeignNational,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      expectedMonthlySalary:
          expectedMonthlySalary ?? this.expectedMonthlySalary,
      currency: currency ?? this.currency,
      availableFrom: availableFrom ?? this.availableFrom,
      coverLetter: coverLetter ?? this.coverLetter,
      documents: documents ?? this.documents,
      acceptedConfidentiality:
          acceptedConfidentiality ?? this.acceptedConfidentiality,
      acceptedDataProcessing:
          acceptedDataProcessing ?? this.acceptedDataProcessing,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
