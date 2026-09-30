import 'cart.dart';

/// Banka ürününün türü.
enum BankProductType { deposit, preciousMetal, loan, safeBox, crypto }

extension BankProductTypeLabel on BankProductType {
  String get label => switch (this) {
        BankProductType.deposit => "Vadeli Mevduat",
        BankProductType.preciousMetal => "Kıymetli Maden",
        BankProductType.loan => "Kredi",
        BankProductType.safeBox => "Kiralık Kasa",
        BankProductType.crypto => "Kripto Varlık",
      };
}

/// Bir işlem adımının durumu.
enum ProcessStepStatus { pending, inProgress, completed, rejected }

extension ProcessStepStatusLabel on ProcessStepStatus {
  String get label => switch (this) {
        ProcessStepStatus.pending => "Bekliyor",
        ProcessStepStatus.inProgress => "İşlemde",
        ProcessStepStatus.completed => "Tamamlandı",
        ProcessStepStatus.rejected => "Reddedildi",
      };
}

/// Bir banka ürünü başvurusunun tek bir işlem adımı.
///
/// BİLİNÇLİ TASARIM KARARI: Banka ürünleri sepetindeki "sepete ekle/öde"
/// diğer sepetlerin aksine bir SONUÇ değil bir BAŞLANGIÇ — para transferiyle
/// açılan ürünler (vadeli mevduat, kıymetli maden) ile forma yönlendirip
/// belge onayı bekleyen ürünler (kredi, kiralık kasa, kripto) TAMAMEN
/// FARKLI gerçek dünya akışları, ama ikisi de aynı `ProcessStep` dizisiyle
/// temsil edilebiliyor — ayrı bir "akış türü" enum'u YOK, fark sadece
/// hangi adımların hangi sırayla eklendiğinde.
class ProcessStep {
  final String id;
  final String label; // örn. "Kimlik Doğrulama", "Para Transferi", "Belge Onayı"
  final ProcessStepStatus status;
  final DateTime? completedAt;
  final String? note;

  const ProcessStep({
    required this.id,
    required this.label,
    required this.status,
    this.completedAt,
    this.note,
  });
}

/// `CartItem.metadata` üzerinden banka ürünleri sepetine özel alanları
/// okuyan yardımcı extension.
extension BankCartItemExtras on CartItem {
  BankProductType get productType =>
      (metadata['productType'] as BankProductType?) ?? BankProductType.deposit;
  String get bankName => (metadata['bankName'] as String?) ?? "Bilinmeyen Banka";
  double? get interestRate => metadata['interestRate'] as double?;
  int? get termMonths => metadata['termMonths'] as int?;
  List<ProcessStep> get processSteps =>
      (metadata['processSteps'] as List<ProcessStep>?) ?? const [];

  /// Tüm adımlar tamamlandıysa ürün tamamen işlenmiş sayılır (bkz.
  /// cargo.dart'taki `ShipmentStatus.isFinal` ile aynı "durum bazlı"
  /// yaklaşım — tarih değil, adım durumları belirleyici).
  bool get isFullyProcessed =>
      processSteps.isNotEmpty &&
      processSteps.every((s) => s.status == ProcessStepStatus.completed);

  bool get hasRejectedStep =>
      processSteps.any((s) => s.status == ProcessStepStatus.rejected);

  /// Şu an bekleyen/işlemde olan ilk adım — kartta öne çıkarılacak adım.
  ProcessStep? get currentStep {
    for (final step in processSteps) {
      if (step.status == ProcessStepStatus.pending ||
          step.status == ProcessStepStatus.inProgress) {
        return step;
      }
    }
    return null;
  }

  int get completedStepCount =>
      processSteps.where((s) => s.status == ProcessStepStatus.completed).length;
}

/// Bir bankanın tek bir faiz teklifi.
class BankOffer {
  final String id;
  final String bankName;
  final double interestRate;
  final bool isAvailable;

  const BankOffer({
    required this.id,
    required this.bankName,
    required this.interestRate,
    this.isAvailable = true,
  });
}

/// Aynı ürün için farklı bankaların faiz tekliflerinin toplandığı grup.
///
/// BİLİNÇLİ TASARIM KARARI: "En iyi teklif" yönü ürün türüne göre TERS
/// DÖNÜYOR — kredide en DÜŞÜK faiz en iyisi, mevduatta en YÜKSEK faiz en
/// iyisi. Bu yön `lowerIsBetter` ile tek bir yerden belirleniyor, kartın
/// geri kalanı bunu sorgusuz kullanıyor.
class InterestRateComparisonGroup {
  final String id;
  final String productName; // örn. "12 Ay Vadeli TL Mevduat", "İhtiyaç Kredisi"
  final BankProductType productType;
  final List<BankOffer> offers;

  const InterestRateComparisonGroup({
    required this.id,
    required this.productName,
    required this.productType,
    this.offers = const [],
  });

  bool get lowerIsBetter => productType == BankProductType.loan;

  List<BankOffer> get sortedByBest {
    final available = offers.where((o) => o.isAvailable).toList()
      ..sort((a, b) => lowerIsBetter
          ? a.interestRate.compareTo(b.interestRate)
          : b.interestRate.compareTo(a.interestRate));
    final unavailable = offers.where((o) => !o.isAvailable).toList();
    return [...available, ...unavailable];
  }

  BankOffer? get bestOffer {
    final available = offers.where((o) => o.isAvailable);
    if (available.isEmpty) return null;
    return lowerIsBetter
        ? available.reduce((a, b) => a.interestRate <= b.interestRate ? a : b)
        : available.reduce((a, b) => a.interestRate >= b.interestRate ? a : b);
  }
}

/// Bir önerinin gösterilme gerekçesi.
enum BankRecommendationReason { alternativeProduct, betterRate }

extension BankRecommendationReasonLabel on BankRecommendationReason {
  String get label => switch (this) {
        BankRecommendationReason.alternativeProduct => "Alternatif Ürün",
        BankRecommendationReason.betterRate => "Daha İyi Oran",
      };
}

/// Kullanıcıya önerilen tek bir banka ürünü.
class RecommendedBankProduct {
  final String id;
  final String productName;
  final BankProductType productType;
  final String bankName;
  final double? interestRate;
  final BankRecommendationReason reason;

  const RecommendedBankProduct({
    required this.id,
    required this.productName,
    required this.productType,
    required this.bankName,
    this.interestRate,
    required this.reason,
  });
}
