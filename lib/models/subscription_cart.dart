import 'cart.dart';
import 'hosting.dart';

/// Aboneliğin sahibinin türü.
enum SubscriptionOwnerKind { collectionOwner, publisher, producer }

extension SubscriptionOwnerKindLabel on SubscriptionOwnerKind {
  String get label => switch (this) {
        SubscriptionOwnerKind.collectionOwner => "Koleksiyon Sahibi",
        SubscriptionOwnerKind.publisher => "Yayıncı",
        SubscriptionOwnerKind.producer => "Yapımcı Şirket",
      };

  String get pluralLabel => switch (this) {
        SubscriptionOwnerKind.collectionOwner => "Koleksiyon Sahipleri",
        SubscriptionOwnerKind.publisher => "Yayıncılar",
        SubscriptionOwnerKind.producer => "Yapımcı Şirketler",
      };
}

/// `CartItem.metadata` üzerinden abonelik sepetine özel alanları okuyan
/// yardımcı extension.
///
/// KONVANSİYON: `CartItem.price` = bir FATURA DÖNEMİNİN fiyatı. Sepetteki
/// her kalem henüz ÖDENMEMİŞ bir aboneliğin sepet halidir.
///
/// NOT: `BillingCycle` hosting.dart'tan YENİDEN KULLANILIYOR (aylık
/// karşılık normalizasyonu için `monthDivisor` orada). Dosya adı hosting'e
/// özgü olduğu için bu bağımlılık refaktör turunda ortak bir dosyaya
/// taşınmaya aday.
///
/// ÖNEMLİ: Tüm getter'lar bilerek `sub` önekli — feed_card.dart birden
/// fazla sepet modelini AYNI dosyada import ettiği için aynı isimli
/// extension üyeleri "ambiguous extension member" hatası verir.
extension SubscriptionCartItemExtras on CartItem {
  String get subOwnerName => (metadata['subOwnerName'] as String?) ?? "Bilinmeyen Sahip";
  SubscriptionOwnerKind get subOwnerKind =>
      (metadata['subOwnerKind'] as SubscriptionOwnerKind?) ?? SubscriptionOwnerKind.publisher;
  String get subPlanName => (metadata['subPlanName'] as String?) ?? title;
  BillingCycle get subBillingCycle =>
      (metadata['subBillingCycle'] as BillingCycle?) ?? BillingCycle.monthly;

  int get subTrialDays => (metadata['subTrialDays'] as int?) ?? 0;
  bool get subAutoRenew => (metadata['subAutoRenew'] as bool?) ?? true;
  int? get subMinCommitmentMonths => metadata['subMinCommitmentMonths'] as int?;
  String? get subContentSummary => metadata['subContentSummary'] as String?;
  List<String> get subFeatures => (metadata['subFeatures'] as List<String>?) ?? const [];

  bool get subHasTrial => subTrialDays > 0;

  double get subMonthlyEquivalent => price / subBillingCycle.monthDivisor;
  double get subLineMonthlyEquivalent => subMonthlyEquivalent * quantity;

  /// Bugün tahsil edilecek tutar: deneme varsa 0, yoksa dönem fiyatı.
  /// SAKLANMIYOR, türetiliyor.
  double get subChargedToday => subHasTrial ? 0 : lineTotal;

  /// İlk gerçek tahsilatın tarihi: deneme yoksa bugün, varsa deneme
  /// süresinin bittiği gün.
  DateTime get subFirstChargeDate => DateTime.now().add(Duration(days: subTrialDays));
}

/// Aynı sahibin sunduğu tek bir plan seviyesi (Temel/Standart/Premium...).
class SubscriptionTier {
  final String id;
  final String name;
  final double price; // bir fatura döneminin fiyatı
  final String currency;
  final BillingCycle billingCycle;
  final List<String> highlights;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.price,
    this.currency = "TRY",
    this.billingCycle = BillingCycle.monthly,
    this.highlights = const [],
  });

  double get monthlyEquivalent => price / billingCycle.monthDivisor;
}

/// Sepetteki bir aboneliğin sahibinin diğer plan seviyeleri.
///
/// NOT: Bu sepette "aynı ürünün farklı satıcılardaki fiyatı" kıyaslaması
/// yok — abonelik içeriği sahibine özgü, başka sahipte aynısı bulunmaz.
/// Bunun yerine aynı sahibin farklı SEVİYELERİ seçili plana göre aylık
/// farkla karşılaştırılıyor. Fark SAKLANMIYOR, canlı hesaplanıyor.
class SubscriptionTierGroup {
  final String id;
  final String ownerName;
  final String selectedTierName; // sepetteki planın adı
  final List<SubscriptionTier> tiers;

  const SubscriptionTierGroup({
    required this.id,
    required this.ownerName,
    required this.selectedTierName,
    this.tiers = const [],
  });

  SubscriptionTier? get selectedTier {
    for (final t in tiers) {
      if (t.name == selectedTierName) return t;
    }
    return null;
  }

  List<SubscriptionTier> get sortedByPrice =>
      tiers.toList()..sort((a, b) => a.monthlyEquivalent.compareTo(b.monthlyEquivalent));

  SubscriptionTier? get cheapestTier {
    if (tiers.isEmpty) return null;
    return tiers.reduce((a, b) => a.monthlyEquivalent <= b.monthlyEquivalent ? a : b);
  }

  /// Verilen seviyenin aylık karşılığının seçili plana göre farkı
  /// (pozitif = daha pahalı). Seçili plan bulunamazsa `null`.
  double? monthlyDifference(SubscriptionTier tier) {
    final selected = selectedTier;
    if (selected == null) return null;
    return tier.monthlyEquivalent - selected.monthlyEquivalent;
  }
}

/// Bir önerinin gösterilme gerekçesi.
enum SubscriptionRecommendationReason { similarContent, bundleDeal, popularNow }

extension SubscriptionRecommendationReasonLabel on SubscriptionRecommendationReason {
  String get label => switch (this) {
        SubscriptionRecommendationReason.similarContent => "Benzer İçerik",
        SubscriptionRecommendationReason.bundleDeal => "Paket Fırsatı",
        SubscriptionRecommendationReason.popularNow => "Şu An Popüler",
      };
}

/// Kullanıcıya önerilen tek bir abonelik planı.
class RecommendedSubscriptionPlan {
  final String id;
  final String ownerName;
  final SubscriptionOwnerKind ownerKind;
  final String planName;
  final double price;
  final String currency;
  final BillingCycle billingCycle;
  final int? trialDays;
  final double? bundleSavingsPercent; // sadece paket fırsatlarında
  final SubscriptionRecommendationReason reason;

  const RecommendedSubscriptionPlan({
    required this.id,
    required this.ownerName,
    required this.ownerKind,
    required this.planName,
    required this.price,
    this.currency = "TRY",
    this.billingCycle = BillingCycle.monthly,
    this.trialDays,
    this.bundleSavingsPercent,
    required this.reason,
  });
}
