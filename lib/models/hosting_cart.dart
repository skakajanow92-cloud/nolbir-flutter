import 'cart.dart';
import 'hosting.dart';

/// Kiralanmak istenen hosting planının türü.
///
/// NOT: hosting.dart'taki `ServerType` (vps/vds/dedicated) paylaşımlı
/// hosting'i kapsamadığı için sepet kendi enum'unu kullanıyor;
/// `BillingCycle` ise hosting.dart'tan YENİDEN KULLANILIYOR.
enum HostingPlanKind { shared, vps, vds, dedicated }

extension HostingPlanKindLabel on HostingPlanKind {
  String get label => switch (this) {
        HostingPlanKind.shared => "Paylaşımlı Hosting",
        HostingPlanKind.vps => "VPS",
        HostingPlanKind.vds => "VDS",
        HostingPlanKind.dedicated => "Dedicated Sunucu",
      };
}

/// `CartItem.metadata` üzerinden hosting sepetine özel alanları okuyan
/// yardımcı extension.
///
/// KONVANSİYON: `CartItem.price` = bir FATURA DÖNEMİNİN fiyatı (aylık,
/// 3 aylık ya da yıllık — `hostingBillingCycle`e göre), `quantity` = paket
/// adedi. Aylık karşılık ve ilk ödeme SAKLANMIYOR, türetiliyor.
///
/// ÖNEMLİ: Tüm getter'lar bilerek `hosting` önekli — feed_card.dart
/// birden fazla sepet modelini AYNI dosyada import ettiği için aynı
/// isimli extension üyeleri "ambiguous extension member" hatası verir.
extension HostingCartItemExtras on CartItem {
  String get hostingProvider => (metadata['hostingProvider'] as String?) ?? "Bilinmeyen Firma";
  String get hostingPlanName => (metadata['hostingPlanName'] as String?) ?? title;
  HostingPlanKind get hostingPlanKind =>
      (metadata['hostingPlanKind'] as HostingPlanKind?) ?? HostingPlanKind.shared;
  BillingCycle get hostingBillingCycle =>
      (metadata['hostingBillingCycle'] as BillingCycle?) ?? BillingCycle.monthly;

  int? get hostingCpuCores => metadata['hostingCpuCores'] as int?;
  int? get hostingRamGb => metadata['hostingRamGb'] as int?;
  int? get hostingDiskGb => metadata['hostingDiskGb'] as int?;
  int? get hostingBandwidthGb => metadata['hostingBandwidthGb'] as int?;
  bool get hostingUnlimitedBandwidth =>
      (metadata['hostingUnlimitedBandwidth'] as bool?) ?? false;

  String? get hostingDatacenter => metadata['hostingDatacenter'] as String?;
  String? get hostingOs => metadata['hostingOs'] as String?;
  String? get hostingControlPanel => metadata['hostingControlPanel'] as String?;
  double? get hostingUptimeSla => metadata['hostingUptimeSla'] as double?; // örn. 99.9
  double? get hostingSetupFee => metadata['hostingSetupFee'] as double?;
  List<String> get hostingFeatures =>
      (metadata['hostingFeatures'] as List<String>?) ?? const [];

  /// Bir adet paketin aylık karşılığı (farklı fatura dönemlerini ortak
  /// birime indirger — bkz. hosting.dart'taki `BillingCycle.monthDivisor`).
  double get hostingMonthlyEquivalent => price / hostingBillingCycle.monthDivisor;

  double get hostingLineMonthlyEquivalent => hostingMonthlyEquivalent * quantity;

  /// Kalemin ilk ödemesi: dönem fiyatı + (varsa) kurulum ücreti.
  double get hostingFirstPayment => lineTotal + (hostingSetupFee ?? 0) * quantity;

  /// "4 vCPU · 8 GB RAM · 160 GB disk" gibi kısa özellik özeti.
  String get hostingSpecSummary {
    final parts = <String>[
      if (hostingCpuCores != null) "$hostingCpuCores vCPU",
      if (hostingRamGb != null) "$hostingRamGb GB RAM",
      if (hostingDiskGb != null) "$hostingDiskGb GB disk",
      if (hostingUnlimitedBandwidth)
        "Sınırsız trafik"
      else if (hostingBandwidthGb != null)
        "$hostingBandwidthGb GB trafik",
    ];
    return parts.join(" · ");
  }
}

/// Bir firmanın, karşılaştırılan özellik düzeyindeki plan teklifi.
class HostingPlanOffer {
  final String id;
  final String provider;
  final String planName;
  final double price; // bir fatura döneminin fiyatı
  final String currency;
  final BillingCycle billingCycle;
  final double? uptimeSla;
  final String? datacenter;
  final bool isAvailable;

  const HostingPlanOffer({
    required this.id,
    required this.provider,
    required this.planName,
    required this.price,
    this.currency = "TRY",
    this.billingCycle = BillingCycle.monthly,
    this.uptimeSla,
    this.datacenter,
    this.isAvailable = true,
  });

  double get monthlyEquivalent => price / billingCycle.monthDivisor;
}

/// Eşdeğer özellikteki planların farklı firmalardaki tekliflerinin grubu.
///
/// BİLİNÇLİ TASARIM KARARI: Teklifler fatura dönemine göre DEĞİL aylık
/// karşılığa göre kıyaslanıyor — yıllık ödemeli bir plan, aylık ödemeli
/// bir planla ancak böyle adil karşılaştırılabilir. Ayrıca en ucuz teklif
/// ile en yüksek uptime SLA'lı teklif AYRI türetiliyor: hosting'de en
/// ucuz seçenek çoğu zaman en güvenilir olan değildir (bkz. hotel_cart.dart'taki
/// "en ucuz" ile "ücretsiz iptalli en ucuz" ayrımıyla aynı mantık). İkisi de
/// SAKLANMIYOR, `offers` listesinden canlı hesaplanıyor.
class HostingPlanComparisonGroup {
  final String id;
  final String title; // örn. "4 vCPU / 8 GB RAM VPS"
  final HostingPlanKind planKind;
  final List<HostingPlanOffer> offers;

  const HostingPlanComparisonGroup({
    required this.id,
    required this.title,
    required this.planKind,
    this.offers = const [],
  });

  List<HostingPlanOffer> get sortedByMonthly {
    final available = offers.where((o) => o.isAvailable).toList()
      ..sort((a, b) => a.monthlyEquivalent.compareTo(b.monthlyEquivalent));
    final unavailable = offers.where((o) => !o.isAvailable).toList();
    return [...available, ...unavailable];
  }

  HostingPlanOffer? get cheapestOffer {
    final available = offers.where((o) => o.isAvailable);
    if (available.isEmpty) return null;
    return available.reduce((a, b) => a.monthlyEquivalent <= b.monthlyEquivalent ? a : b);
  }

  HostingPlanOffer? get highestUptimeOffer {
    final rated = offers.where((o) => o.isAvailable && o.uptimeSla != null);
    if (rated.isEmpty) return null;
    return rated.reduce((a, b) => a.uptimeSla! >= b.uptimeSla! ? a : b);
  }

  /// En pahalı MÜSAİT tekliften en ucuza geçişte aylık karşılıkta
  /// sağlanan tasarruf (%).
  double? get savingsPercentVsHighest {
    final available = offers.where((o) => o.isAvailable).toList();
    if (available.length < 2) return null;
    final cheapest = cheapestOffer!;
    final highest =
        available.reduce((a, b) => a.monthlyEquivalent >= b.monthlyEquivalent ? a : b);
    if (highest.monthlyEquivalent == 0) return null;
    return ((highest.monthlyEquivalent - cheapest.monthlyEquivalent) /
            highest.monthlyEquivalent) *
        100;
  }
}

/// Önerilen ek hizmetin türü.
enum HostingAddOnKind { domain, ssl, backup, cdn, monitoring }

extension HostingAddOnKindLabel on HostingAddOnKind {
  String get label => switch (this) {
        HostingAddOnKind.domain => "Alan Adı",
        HostingAddOnKind.ssl => "SSL Sertifikası",
        HostingAddOnKind.backup => "Yedekleme",
        HostingAddOnKind.cdn => "CDN",
        HostingAddOnKind.monitoring => "İzleme",
      };
}

/// Sepetteki bir plana eşlik edebilecek tek bir ek hizmet önerisi.
class RecommendedHostingAddOn {
  final String id;
  final String name;
  final HostingAddOnKind kind;
  final String provider;
  final double price;
  final String currency;
  final BillingCycle billingCycle;
  final String? relatedPlanName; // örn. "CPX31 VPS için"

  const RecommendedHostingAddOn({
    required this.id,
    required this.name,
    required this.kind,
    required this.provider,
    required this.price,
    this.currency = "TRY",
    this.billingCycle = BillingCycle.monthly,
    this.relatedPlanName,
  });
}
