import 'cart.dart';

/// Dijital reçetenin kullanım durumu.
enum PrescriptionStatus { active, partiallyFilled, fullyFilled, expired }

extension PrescriptionStatusLabel on PrescriptionStatus {
  String get label => switch (this) {
    PrescriptionStatus.active => "Aktif",
    PrescriptionStatus.partiallyFilled => "Kısmen Kullanıldı",
    PrescriptionStatus.fullyFilled => "Tamamen Kullanıldı",
    PrescriptionStatus.expired => "Süresi Doldu",
  };
}

/// Yetkili bir sağlık kurumundan, doktorun dijital imzasıyla onaylanmış
/// bir e-reçete.
///
/// BİLİNÇLİ TASARIM KARARI: Bu model yalnızca reçetenin İDARİ/DOĞRULAMA
/// bilgisini taşır (reçete no, doktor, kurum, dijital imza referansı,
/// geçerlilik tarihi) — tanı/teşhis gibi klinik içerik BİLEREK dışarıda
/// bırakıldı; bu, uygulamanın görevi değil.
class DigitalPrescription {
  final String id;
  final String prescriptionNumber;
  final String doctorName;
  final String? doctorSpecialty;
  final String healthInstitution;
  final String digitalSignatureRef; // dijital imza doğrulama referansı
  final DateTime issuedDate;
  final DateTime expiryDate;
  final PrescriptionStatus status;

  const DigitalPrescription({
    required this.id,
    required this.prescriptionNumber,
    required this.doctorName,
    this.doctorSpecialty,
    required this.healthInstitution,
    required this.digitalSignatureRef,
    required this.issuedDate,
    required this.expiryDate,
    this.status = PrescriptionStatus.active,
  });

  bool get isUsable =>
      status == PrescriptionStatus.active ||
      status == PrescriptionStatus.partiallyFilled;

  bool get isExpiringSoon =>
      isUsable && expiryDate.difference(DateTime.now()).inDays <= 7;
}

/// `CartItem.metadata` üzerinden ilaç sepetine özel alanları okuyan
/// yardımcı extension.
///
/// NOT: `CartItem.quantity` sepetteki talep edilen adedi taşır;
/// `prescribedQuantity` ise reçetede İZİN VERİLEN toplam adedi — ikisi
/// bilerek ayrı tutuluyor, böylece "reçete numarasına göre adetli"
/// ilişki kartta görünür kalıyor.
extension PharmacyCartItemExtras on CartItem {
  bool get requiresPrescription =>
      (metadata['requiresPrescription'] as bool?) ?? false;
  String? get prescriptionNumber => metadata['prescriptionNumber'] as String?;
  int? get prescribedQuantity => metadata['prescribedQuantity'] as int?;
  String get pharmacyName =>
      (metadata['pharmacyName'] as String?) ?? "Bilinmeyen Eczane";
  String? get pharmacyLicenseNumber =>
      metadata['pharmacyLicenseNumber'] as String?;
  String? get dosageInstructions => metadata['dosageInstructions'] as String?;
}

/// Lisanslı bir eczanenin tek bir ilaç için fiyat teklifi.
///
/// BİLİNÇLİ TASARIM KARARI: Her teklif kendi ruhsat/lisans numarasını ve
/// ülkesini taşıyor — market sepetindeki genel `marketName`den farklı
/// olarak, eczane satıcılığı ülkelere göre alınan ÖZEL bir lisansa bağlı;
/// bu bilgi kartta görünür kalmalı.
class PharmacyOffer {
  final String id;
  final String pharmacyName;
  final String licenseNumber;
  final String country;
  final double price;
  final String currency;
  final bool inStock;

  const PharmacyOffer({
    required this.id,
    required this.pharmacyName,
    required this.licenseNumber,
    required this.country,
    required this.price,
    this.currency = "TRY",
    this.inStock = true,
  });
}

/// Aynı ilacın farklı lisanslı eczanelerdeki fiyat tekliflerinin grubu.
///
/// NOT: Bu SADECE fiyat karşılaştırmasıdır — klinik bir ikame/alternatif
/// ilaç önerisi DEĞİLDİR. Reçeteli bir ilaç için grup her zaman AYNI
/// ilacın kendisini temsil eder, farklı bir ilacı değil.
class MedicineComparisonGroup {
  final String id;
  final String medicineName;
  final bool requiresPrescription;
  final List<PharmacyOffer> offers;

  const MedicineComparisonGroup({
    required this.id,
    required this.medicineName,
    this.requiresPrescription = false,
    this.offers = const [],
  });

  List<PharmacyOffer> get sortedByPrice {
    final available = offers.where((o) => o.inStock).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    final unavailable = offers.where((o) => !o.inStock).toList();
    return [...available, ...unavailable];
  }

  PharmacyOffer? get cheapestOffer {
    final available = offers.where((o) => o.inStock);
    if (available.isEmpty) return null;
    return available.reduce((a, b) => a.price <= b.price ? a : b);
  }
}

/// Reçetesiz (OTC) bir ürün kategorisi — öneri bölümü bilerek SADECE bu
/// tür ürünleri kapsar, reçeteli bir ilaca alternatif ilaç önermez.
enum OtcCategory { vitamin, supplement, personalCare, firstAid }

extension OtcCategoryLabel on OtcCategory {
  String get label => switch (this) {
    OtcCategory.vitamin => "Vitamin",
    OtcCategory.supplement => "Takviye",
    OtcCategory.personalCare => "Kişisel Bakım",
    OtcCategory.firstAid => "İlk Yardım",
  };
}

/// Kullanıcıya önerilen, reçete gerektirmeyen tek bir ürün.
class RecommendedPharmacyProduct {
  final String id;
  final String title;
  final OtcCategory category;
  final double price;
  final String currency;
  final String pharmacyName;

  const RecommendedPharmacyProduct({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    this.currency = "TRY",
    required this.pharmacyName,
  });
}
