import '../feed_card/base.dart';

enum InsuranceSellerKind { directInsurer, brokerAgent }

enum InsuranceCoverageType {
  health,
  vehicle,
  traffic,
  home,
  travel,
  life,
  personalAccident,
  petCare,
}

extension InsuranceCoverageTypeLabel on InsuranceCoverageType {
  String get label {
    switch (this) {
      case InsuranceCoverageType.health:
        return "Sağlık Sigortası";
      case InsuranceCoverageType.vehicle:
        return "Kasko";
      case InsuranceCoverageType.traffic:
        return "Trafik Sigortası";
      case InsuranceCoverageType.home:
        return "Konut Sigortası";
      case InsuranceCoverageType.travel:
        return "Seyahat Sigortası";
      case InsuranceCoverageType.life:
        return "Hayat Sigortası";
      case InsuranceCoverageType.personalAccident:
        return "Ferdi Kaza Sigortası";
      case InsuranceCoverageType.petCare:
        return "Evcil Hayvan Sigortası";
    }
  }
}

/// Fiyatlandırılmış bir teminat/paket seçeneği, örn. "Temel / Standart / Geniş".
class InsurancePlanOption {
  final String name;
  final double monthlyPremium;
  final String coverageSummary;

  const InsurancePlanOption({
    required this.name,
    required this.monthlyPremium,
    required this.coverageSummary,
  });
}

/// Orta tab için: tek bir sigorta ürününü tanıtan kart.
///
/// SATICI/ÜSTLENEN AYRIMI: Üstte her zaman `sellerName`/`sellerLogoUrl`
/// gösterilir — bu, ekranda görünen "tanıdık" marka (doğrudan sigorta
/// şirketi ya da bir aracı/acente kuruluşu). `sellerKind == brokerAgent`
/// olduğunda poliçeyi asıl üstlenen şirket `underwritingCompanyName` ile
/// ayrıca, daha küçük bir satırda belirtilir. Aynı şirket hem kendi
/// ürününü hem bir acente vitrininde başka şirketlerin ürününü
/// satabildiği için bu iki alan kasıtlı olarak ayrı tutuldu.
class InsuranceProductCard extends FeedCard implements Collectible {
  final InsuranceSellerKind sellerKind;
  final String sellerName;
  final String sellerLogoUrl;

  /// Sadece `sellerKind == brokerAgent` iken dolu olması beklenir.
  final String? underwritingCompanyName;
  final String? underwritingCompanyLogoUrl;

  final InsuranceCoverageType coverageType;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String? detailUrl;
  final double rating;
  final int reviewCount;

  final List<String> coverageHighlights;
  final List<InsurancePlanOption> planOptions;
  final double? deductible;
  final String currency;

  const InsuranceProductCard({
    required String id,
    required this.sellerKind,
    required this.sellerName,
    required this.sellerLogoUrl,
    required this.coverageType,
    required this.title,
    required this.description,
    required this.planOptions,
    this.underwritingCompanyName,
    this.underwritingCompanyLogoUrl,
    this.imageUrls = const [],
    this.detailUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.coverageHighlights = const [],
    this.deductible,
    this.currency = "TRY",
  })  : assert(
          sellerKind == InsuranceSellerKind.directInsurer ||
              underwritingCompanyName != null,
          'brokerAgent için underwritingCompanyName zorunlu',
        ),
        assert(planOptions.length > 0, 'en az bir plan seçeneği gerekli'),
        super(id);

  InsurancePlanOption get cheapestPlan => planOptions.reduce(
        (a, b) => a.monthlyPremium <= b.monthlyPremium ? a : b,
      );

  @override
  (String, String) toCollectionPreview() => (
        "$sellerName · $title",
        imageUrls.isNotEmpty ? imageUrls.first : sellerLogoUrl,
      );
}