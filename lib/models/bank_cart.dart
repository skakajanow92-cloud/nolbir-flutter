import 'cart.dart';

/// Banka/finans ürünü türü.
enum BankProductType { loan, deposit, safeDepositBox, preciousMetal, crypto }

extension BankProductTypeLabel on BankProductType {
  String get label => switch (this) {
        BankProductType.loan => "Kredi",
        BankProductType.deposit => "Mevduat",
        BankProductType.safeDepositBox => "Kasa Kiralama",
        BankProductType.preciousMetal => "Kıymetli Maden",
        BankProductType.crypto => "Kripto",
      };
}

/// Bir başvuru adımının durumu.
enum StepStatus { pending, inProgress, completed, rejected }

extension StepStatusLabel on StepStatus {
  String get label => switch (this) {
        StepStatus.pending => "Bekliyor",
        StepStatus.inProgress => "Devam Ediyor",
        StepStatus.completed => "Tamamlandı",
        StepStatus.rejected => "Reddedildi",
      };
}

/// Bir banka ürünü başvurusunun tek bir adımı.
///
/// BİLİNÇLİ TASARIM KARARI: "Para aktarınca hesap açılır" (mevduat/
/// kıymetli maden) ile "forma yönlendirilip evrak onaylanır" (kredi/
/// kasa/kripto) akışları AYRI modellenmedi — ikisi de aynı `ProcessStep`
/// listesiyle temsil ediliyor, sadece adımların içeriği (title) farklı.
/// Bu, sepetin "satın al ve bitir" değil "checkout sonrası süreç devam
/// eder" doğasını tek bir yapıyla karşılıyor.
class ProcessStep {
  final String id;
  final String title; // örn. "Evrak Onayı", "Para Transferi", "Hesap Açılışı"
  final StepStatus status;
  final DateTime? completedAt;
  final String? note;

  const ProcessStep({
    required this.id,
    required this.title,
    this.status = StepStatus.pending,
    this.completedAt,
    this.note,
  });
}

/// `CartItem.metadata` üzerinden banka sepetine özel alanları okuyan
/// yardımcı extension (bkz. diğer sepet dosyalarındaki aynı yaklaşım).
extension BankCartItemExtras on CartItem {
  BankProductType get productType =>
      (metadata['productType'] as BankProductType?) ?? BankProductType.deposit;
  String get bankName => (metadata['bankName'] as String?) ?? "Bilinmeyen Kurum";
  double? get interestRate => metadata['interestRate'] as double?;
  int? get termMonths => metadata['termMonths'] as int?;

  /// Hesabın/işlemin tamamlanması için aktarılması gereken tutar —
  /// mevduat/kıymetli maden ürünlerinde anlamlı; kredi/kasa/kripto gibi
  /// "forma yönlendir" akışlarında `null` kalabilir.
  double? get requiredTransferAmount => metadata['requiredTransferAmount'] as double?;

  List<ProcessStep> get steps => (metadata['steps'] as List<ProcessStep>?) ?? const [];

  int get completedStepCount =>
      steps.where((s) => s.status == StepStatus.completed).length;

  bool get isFullyProcessed =>
      steps.isNotEmpty && steps.every((s) => s.status == StepStatus.completed);

  bool get hasRejectedStep => steps.any((s) => s.status == StepStatus.rejected);

  /// Sıradaki (bekleyen ya da devam eden) ilk adım — tamamlanmışsa `null`.
  ProcessStep? get currentStep {
    for (final s in steps) {
      if (s.status == StepStatus.pending || s.status == StepStatus.inProgress) return s;
    }
    return null;
  }
}

/// Aynı ürün türü/vade için tek bir bankanın oranı.
class BankRateOffer {
  final String id;
  final String bankName;
  final double interestRate; // yıllık, yüzde olarak
  final bool isAvailable;

  const BankRateOffer({
    required this.id,
    required this.bankName,
    required this.interestRate,
    this.isAvailable = true,
  });
}

/// Aynı ürün (örn. "12 Ay Vadeli Mevduat" ya da "İhtiyaç Kredisi") için
/// farklı bankaların oranlarının toplandığı grup.
///
/// ÖNEMLİ TASARIM NOKTASI: "En iyi teklif" ürün türüne göre YÖN
/// DEĞİŞTİRİR — mevduatta en YÜKSEK faiz iyidir, krediде en DÜŞÜK faiz
/// iyidir. `bestOffer` bunu `productType`e bakarak hesaplıyor; aksi
/// halde kredi karşılaştırmasında yanlışlıkla en pahalı teklif "en iyi"
/// gösterilirdi.
class RateComparisonGroup {
  final String id;
  final String productLabel;
  final BankProductType productType;
  final int? termMonths;
  final List<BankRateOffer> offers;

  const RateComparisonGroup({
    required this.id,
    required this.productLabel,
    required this.productType,
    this.termMonths,
    this.offers = const [],
  });

  bool get _lowerIsBetter => productType == BankProductType.loan;

  List<BankRateOffer> get sortedByRate {
    final available = offers.where((o) => o.isAvailable).toList()
      ..sort((a, b) => _lowerIsBetter
          ? a.interestRate.compareTo(b.interestRate)
          : b.interestRate.compareTo(a.interestRate));
    final unavailable = offers.where((o) => !o.isAvailable).toList();
    return [...available, ...unavailable];
  }

  BankRateOffer? get bestOffer {
    final available = offers.where((o) => o.isAvailable);
    if (available.isEmpty) return null;
    return _lowerIsBetter
        ? available.reduce((a, b) => a.interestRate <= b.interestRate ? a : b)
        : available.reduce((a, b) => a.interestRate >= b.interestRate ? a : b);
  }
}

/// Bir önerinin gösterilme gerekçesi.
enum BankRecommendationReason { betterRate, complementaryProduct }

extension BankRecommendationReasonLabel on BankRecommendationReason {
  String get label => switch (this) {
        BankRecommendationReason.betterRate => "Daha İyi Koşul",
        BankRecommendationReason.complementaryProduct => "Tamamlayıcı Ürün",
      };
}

/// Kullanıcıya önerilen tek bir banka ürünü.
class RecommendedBankProduct {
  final String id;
  final String bankName;
  final String productName;
  final BankProductType productType;
  final double? interestRate;
  final BankRecommendationReason reason;

  const RecommendedBankProduct({
    required this.id,
    required this.bankName,
    required this.productName,
    required this.productType,
    this.interestRate,
    required this.reason,
  });
}
