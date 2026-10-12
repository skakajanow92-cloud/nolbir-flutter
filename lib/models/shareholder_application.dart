import 'dart:typed_data';

/// Başvuru sürecinde istenen belge türleri.
enum DocumentType {
  identityCard,
  passport,
  applicantPhoto,
  criminalRecord,
  financialStatement,
  taxRegistration,
  sourceOfFundsDeclaration,
  mentalHealthReport,
  referenceLetter,
  /// Varlık katkılarına (taşınmaz, araç vb.) özel kanıt belgesi — ana
  /// zorunlu listede DEĞİL, her varlığın kendi altında ayrı ayrı eklenir
  /// (bkz. AssetContribution.proofDocument).
  assetProof,
}

extension DocumentTypeMeta on DocumentType {
  String get label => switch (this) {
        DocumentType.identityCard => "Kimlik Belgesi",
        DocumentType.passport => "Pasaport",
        DocumentType.applicantPhoto => "Başvuran Fotoğrafı",
        DocumentType.criminalRecord => "Adli Sicil Kaydı",
        DocumentType.financialStatement => "Mali Durum Beyanı",
        DocumentType.taxRegistration => "Vergi Levhası",
        DocumentType.sourceOfFundsDeclaration => "Kaynak Beyanı",
        DocumentType.mentalHealthReport => "Sağlık Raporu",
        DocumentType.referenceLetter => "Referans Mektubu",
        DocumentType.assetProof => "Varlık Belgesi",
      };

  String get description => switch (this) {
        DocumentType.identityCard =>
          "T.C. kimlik kartı ya da eşdeğer resmi kimlik",
        DocumentType.passport => "Geçerli pasaport",
        DocumentType.applicantPhoto => "Yakın zamanlı vesikalık fotoğraf",
        DocumentType.criminalRecord => "Güncel adli sicil kaydı belgesi",
        DocumentType.financialStatement =>
          "Gelir/mali durum beyanı ya da banka dökümü",
        DocumentType.taxRegistration =>
          "Vergi levhası ya da vergi kimlik belgesi",
        DocumentType.sourceOfFundsDeclaration =>
          "Katkı sermayesinin kaynağına dair beyan",
        DocumentType.mentalHealthReport =>
          "Tam teşekküllü sağlık kurumundan alınmış rapor",
        DocumentType.referenceLetter =>
          "Opsiyonel — mevcut bir ortak/kurumdan referans",
        DocumentType.assetProof =>
          "Tapu, ruhsat gibi varlığı kanıtlayan belge",
      };

  /// `referenceLetter` opsiyonel; `assetProof` ana listede hiç yer
  /// almadığı için (her varlığın kendi altında) burada da "zorunlu
  /// değil" sayılıyor — `missingRequiredDocuments` taraması bunu
  /// otomatik dışlar.
  bool get isRequired =>
      this != DocumentType.referenceLetter && this != DocumentType.assetProof;
}

/// Gerçek dosya seçiciyle alınmış tek bir belge.
///
/// BİLİNÇLİ TASARIM KARARI: `filePath` DEĞİL `bytes` tutuluyor — Flutter
/// Web'de gerçek bir dosya yolu yok, sadece bellekte bayt dizisi var. Bu
/// sayede önizleme (`Image.memory`) hem web hem mobil hem masaüstünde
/// aynı şekilde çalışıyor.
class UploadedDocument {
  final DocumentType type;
  final String fileName;
  final Uint8List bytes;
  final int fileSizeBytes;
  final String? documentNumber;
  final DateTime uploadedAt;

  const UploadedDocument({
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

  UploadedDocument copyWith({String? documentNumber}) {
    return UploadedDocument(
      type: type,
      fileName: fileName,
      bytes: bytes,
      fileSizeBytes: fileSizeBytes,
      documentNumber: documentNumber ?? this.documentNumber,
      uploadedAt: uploadedAt,
    );
  }
}

enum AssetType { realEstate, vehicle, cash, other }

extension AssetTypeMeta on AssetType {
  String get label => switch (this) {
        AssetType.realEstate => "Taşınmaz",
        AssetType.vehicle => "Araç",
        AssetType.cash => "Nakit",
        AssetType.other => "Diğer",
      };
}

/// Sisteme katkı olarak sunulan tek bir varlık ve onu kanıtlayan belge.
class AssetContribution {
  final String id;
  final AssetType type;
  final String description;
  final double estimatedValue;
  final String currency;
  final UploadedDocument? proofDocument;

  const AssetContribution({
    required this.id,
    required this.type,
    required this.description,
    required this.estimatedValue,
    this.currency = "TRY",
    this.proofDocument,
  });
}

enum ShareholderApplicationStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
}

extension ShareholderApplicationStatusMeta on ShareholderApplicationStatus {
  String get label => switch (this) {
        ShareholderApplicationStatus.draft => "Taslak",
        ShareholderApplicationStatus.submitted => "Gönderildi",
        ShareholderApplicationStatus.underReview => "İnceleniyor",
        ShareholderApplicationStatus.approved => "Onaylandı",
        ShareholderApplicationStatus.rejected => "Reddedildi",
      };
}

/// Holding'e ortaklık başvurusunun tamamı.
class ShareholderApplication {
  final String fullName;
  final String nationalOrPassportNo;
  final String email;
  final String phone;
  final double requestedEquityPercent;
  final double cashContribution;
  final String currency;
  final List<AssetContribution> assetContributions;
  final List<UploadedDocument> documents;
  final ShareholderApplicationStatus status;
  final DateTime? submittedAt;

  const ShareholderApplication({
    this.fullName = "",
    this.nationalOrPassportNo = "",
    this.email = "",
    this.phone = "",
    this.requestedEquityPercent = 0,
    this.cashContribution = 0,
    this.currency = "TRY",
    this.assetContributions = const [],
    this.documents = const [],
    this.status = ShareholderApplicationStatus.draft,
    this.submittedAt,
  });

  double get totalAssetValue =>
      assetContributions.fold(0.0, (sum, a) => sum + a.estimatedValue);

  double get totalContribution => cashContribution + totalAssetValue;

  UploadedDocument? documentOf(DocumentType type) {
    for (final d in documents) {
      if (d.type == type) return d;
    }
    return null;
  }

  List<DocumentType> get missingRequiredDocuments => DocumentType.values
      .where((t) => t.isRequired && documentOf(t) == null)
      .toList();

  bool get isComplete =>
      fullName.isNotEmpty &&
      nationalOrPassportNo.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty &&
      requestedEquityPercent > 0 &&
      missingRequiredDocuments.isEmpty;

  ShareholderApplication copyWith({
    String? fullName,
    String? nationalOrPassportNo,
    String? email,
    String? phone,
    double? requestedEquityPercent,
    double? cashContribution,
    String? currency,
    List<AssetContribution>? assetContributions,
    List<UploadedDocument>? documents,
    ShareholderApplicationStatus? status,
    DateTime? submittedAt,
  }) {
    return ShareholderApplication(
      fullName: fullName ?? this.fullName,
      nationalOrPassportNo: nationalOrPassportNo ?? this.nationalOrPassportNo,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      requestedEquityPercent:
          requestedEquityPercent ?? this.requestedEquityPercent,
      cashContribution: cashContribution ?? this.cashContribution,
      currency: currency ?? this.currency,
      assetContributions: assetContributions ?? this.assetContributions,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
