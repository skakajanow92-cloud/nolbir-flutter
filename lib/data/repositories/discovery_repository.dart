import '../../models/feed_card/feed_card.dart';
import '../../models/cart.dart';
import '../../models/product_card/product_card.dart';

abstract class DiscoveryRepository {
  Future<List<FeedCard>> fetchFeed({required int page, int pageSize = 10});
}

class MockDiscoveryRepository implements DiscoveryRepository {
  static const _demoCartTypes = [
    CartType.market,
    CartType.secondHand,
    CartType.sportsGear,
    CartType.wholesale,
  ];

  // Banka ürünü örnekleri — id'yi dışarıdan (üretim sırasında) alan
  // birer "şablon" fonksiyonu: aynı içerik farklı sayfalarda farklı id
  // ile tekrar kullanılabilsin diye.
  static final List<BankProductCard Function(String id)>
  _bankProductBuilders = [
    (id) => BankProductCard(
      id: id,
      bankName: "Kuzey Bankası",
      bankLogoUrl: "",
      title: "İhtiyaç Kredisi",
      description:
          "Hızlı onaylı, düşük faizli ihtiyaç kredisi — başvuru 5 dakika sürer.",
      productType: BankProductType.loan,
      rating: 4.3,
      reviewCount: 1280,
      detailUrl: "https://example.com/kuzeybank/ihtiyac-kredisi",
      loanDetails: const LoanDetails(
        interestRate: 3.49,
        maxTermMonths: 36,
        maxAmount: 250000,
        hasDigitalCard: true,
      ),
    ),
    (id) => BankProductCard(
      id: id,
      bankName: "Liman Bankası",
      bankLogoUrl: "",
      title: "Taşıt Kredisi",
      description: "0 km ve ikinci el taşıtlar için uygun vadeli kredi paketi.",
      productType: BankProductType.loan,
      rating: 3.9,
      reviewCount: 512,
      loanDetails: const LoanDetails(
        interestRate: 2.89,
        maxTermMonths: 48,
        maxAmount: 900000,
        hasDigitalCard: false,
      ),
    ),
    (id) => BankProductCard(
      id: id,
      bankName: "Kuzey Bankası",
      bankLogoUrl: "",
      title: "Vadesiz Hesap",
      description: "Maaş hesabı avantajlarıyla ücretsiz vadesiz hesap.",
      productType: BankProductType.checkingAccount,
      rating: 4.6,
      reviewCount: 3040,
      checkingAccountDetails: const CheckingAccountDetails(
        hasLinkedCard: true,
        cardName: "Kuzey Bonus",
        annualFee: 0,
      ),
    ),
    (id) => BankProductCard(
      id: id,
      bankName: "Vadi Bankası",
      bankLogoUrl: "",
      title: "Dijital Vadesiz Hesap",
      description: "Sadece mobil üzerinden yönetilen, şubesiz hesap.",
      productType: BankProductType.checkingAccount,
      rating: 4.1,
      reviewCount: 208,
      checkingAccountDetails: const CheckingAccountDetails(
        hasLinkedCard: false,
      ),
    ),
    (id) => BankProductCard(
      id: id,
      bankName: "Liman Bankası",
      bankLogoUrl: "",
      title: "Vadeli Mevduat",
      description: "Farklı vade seçenekleriyle yüksek getirili mevduat hesabı.",
      productType: BankProductType.timeDeposit,
      rating: 4.4,
      reviewCount: 964,
      timeDepositDetails: const TimeDepositDetails(
        termOptions: [
          DepositTermOption(months: 1, annualInterestRate: 41.0),
          DepositTermOption(months: 3, annualInterestRate: 44.5),
          DepositTermOption(months: 6, annualInterestRate: 43.0),
          DepositTermOption(months: 12, annualInterestRate: 40.0),
        ],
      ),
    ),
  ];

  static final List<InsuranceProductCard Function(String id)>
  _insuranceProductBuilders = [
    // Doğrudan sigorta şirketinden — kendi logosu, kendi adı altında.
    (id) => InsuranceProductCard(
      id: id,
      sellerKind: InsuranceSellerKind.directInsurer,
      sellerName: "Güven Sigorta",
      sellerLogoUrl: "",
      coverageType: InsuranceCoverageType.health,
      title: "Tamamlayıcı Sağlık Sigortası",
      description:
          "SGK'lı tüm tedavi giderlerinizi özel hastanede fark ödemeden karşılar.",
      rating: 4.5,
      reviewCount: 2140,
      detailUrl: "https://example.com/guven/saglik",
      coverageHighlights: const ["Ayakta tedavi", "Yatarak tedavi", "Check-up"],
      planOptions: const [
        InsurancePlanOption(
          name: "Temel",
          monthlyPremium: 340,
          coverageSummary: "Yatarak tedavi",
        ),
        InsurancePlanOption(
          name: "Geniş",
          monthlyPremium: 590,
          coverageSummary: "Yatarak + ayakta tedavi",
        ),
      ],
    ),
    // Acente — Kolay Sigorta vitrininde, poliçeyi Anka Sigorta üstleniyor.
    (id) => InsuranceProductCard(
      id: id,
      sellerKind: InsuranceSellerKind.brokerAgent,
      sellerName: "Kolay Sigorta Acentesi",
      sellerLogoUrl: "",
      underwritingCompanyName: "Anka Sigorta",
      underwritingCompanyLogoUrl: "",
      coverageType: InsuranceCoverageType.traffic,
      title: "Trafik Sigortası",
      description: "Zorunlu trafik sigortanızı dakikalar içinde yenileyin.",
      rating: 4.1,
      reviewCount: 876,
      coverageHighlights: const ["Maddi hasar", "Bedeni zarar"],
      planOptions: const [
        InsurancePlanOption(
          name: "Standart",
          monthlyPremium: 180,
          coverageSummary: "Yasal asgari teminat",
        ),
      ],
    ),
    // Aynı acente, farklı bir şirketin kasko ürününü satıyor.
    (id) => InsuranceProductCard(
      id: id,
      sellerKind: InsuranceSellerKind.brokerAgent,
      sellerName: "Kolay Sigorta Acentesi",
      sellerLogoUrl: "",
      underwritingCompanyName: "Deniz Sigorta",
      underwritingCompanyLogoUrl: "",
      coverageType: InsuranceCoverageType.vehicle,
      title: "Kasko",
      description: "Çarpma, çalınma ve doğal afetlere karşı tam koruma.",
      rating: 4.3,
      reviewCount: 431,
      deductible: 2500,
      coverageHighlights: const [
        "Çarpma",
        "Çalınma",
        "Cam kırılması",
        "Yol yardım",
      ],
      planOptions: const [
        InsurancePlanOption(
          name: "Standart",
          monthlyPremium: 420,
          coverageSummary: "Muafiyetli temel kasko",
        ),
        InsurancePlanOption(
          name: "Mini Onarım Hariç",
          monthlyPremium: 510,
          coverageSummary: "Düşük muafiyetli kasko",
        ),
        InsurancePlanOption(
          name: "Tam Kapsam",
          monthlyPremium: 690,
          coverageSummary: "Muafiyetsiz, yol yardım dahil",
        ),
      ],
    ),
    // Doğrudan farklı bir sigorta şirketinden, konut sigortası.
    (id) => InsuranceProductCard(
      id: id,
      sellerKind: InsuranceSellerKind.directInsurer,
      sellerName: "Anka Sigorta",
      sellerLogoUrl: "",
      coverageType: InsuranceCoverageType.home,
      title: "Konut Sigortası",
      description: "Yangın, hırsızlık ve doğal afetlere karşı eviniz güvende.",
      rating: 4.0,
      reviewCount: 305,
      coverageHighlights: const ["Yangın", "Hırsızlık", "Deprem", "Su baskını"],
      planOptions: const [
        InsurancePlanOption(
          name: "Temel",
          monthlyPremium: 95,
          coverageSummary: "Yangın + hırsızlık",
        ),
        InsurancePlanOption(
          name: "Geniş",
          monthlyPremium: 160,
          coverageSummary: "Tüm doğal afetler dahil",
        ),
      ],
    ),
  ];

  static final List<EcommerceProductCard Function(String id)>
  _ecommerceProductBuilders = [
    (id) => EcommerceProductCard(
      id: id,
      storeName: "Moda Dükkanı",
      storeLogoUrl: "",
      brandName: "Nordline",
      category: ProductCategory.clothing,
      title: "Yünlü Kaban",
      description: "Kışlık, su itici kumaşlı, astarlı kaban.",
      price: 1299.0,
      discountedPrice: 899.0,
      rating: 4.4,
      reviewCount: 612,
      stockStatus: StockStatus.lowStock,
      imageUrls: const ["", ""],
      variantGroups: const [
        ProductVariantGroup(name: "Beden", options: ["S", "M", "L", "XL"]),
        ProductVariantGroup(
          name: "Renk",
          options: ["Siyah", "Kamel", "Lacivert"],
        ),
      ],
      specs: const [
        ProductSpec(label: "Kumaş", value: "%70 Yün, %30 Polyester"),
        ProductSpec(label: "Astar", value: "Var"),
      ],
    ),
    (id) => EcommerceProductCard(
      id: id,
      storeName: "Teknoloji Merkezi",
      storeLogoUrl: "",
      brandName: "Orion",
      category: ProductCategory.mobileDevices,
      title: "Orion X12 Akıllı Telefon",
      description: "6.5 inç ekran, üçlü kamera, hızlı şarj desteği.",
      price: 24999.0,
      rating: 4.6,
      reviewCount: 3480,
      imageUrls: const [""],
      variantGroups: const [
        ProductVariantGroup(
          name: "Depolama",
          options: ["128GB", "256GB", "512GB"],
        ),
        ProductVariantGroup(name: "Renk", options: ["Grafit", "Gümüş"]),
      ],
      specs: const [
        ProductSpec(label: "Ekran", value: "6.5\" AMOLED"),
        ProductSpec(label: "İşlemci", value: "Octa-core 2.8GHz"),
        ProductSpec(label: "Batarya", value: "5000 mAh"),
        ProductSpec(label: "Kamera", value: "50MP + 12MP + 8MP"),
      ],
      cartType: CartType.secondHand,
    ),
    (id) => EcommerceProductCard(
      id: id,
      storeName: "Usta Hırdavat",
      storeLogoUrl: "",
      brandName: "PowerMax",
      category: ProductCategory.powerTools,
      title: "PowerMax 900W Matkap",
      description: "Darbeli, değişken hız kontrollü profesyonel matkap.",
      price: 1850.0,
      rating: 4.2,
      reviewCount: 198,
      stockStatus: StockStatus.inStock,
      imageUrls: const [""],
      specs: const [
        ProductSpec(label: "Güç", value: "900W"),
        ProductSpec(label: "Mandren", value: "13mm"),
        ProductSpec(label: "Ağırlık", value: "2.1 kg"),
        ProductSpec(label: "Kutu İçeriği", value: "Çanta + 5 uç"),
      ],
      cartType: CartType.wholesale,
    ),
    (id) => EcommerceProductCard(
      id: id,
      storeName: "Yapı Market",
      storeLogoUrl: "",
      category: ProductCategory.construction,
      title: "Alçıpan Levha",
      description: "Standart iç mekan alçıpan levha, nem direnci yüksek.",
      price: 189.0,
      rating: 3.9,
      reviewCount: 74,
      stockStatus: StockStatus.preOrder,
      imageUrls: const [""],
      variantGroups: const [
        ProductVariantGroup(
          name: "Ölçü",
          options: ["120x200cm", "120x250cm", "120x300cm"],
        ),
      ],
      specs: const [
        ProductSpec(label: "Kalınlık", value: "12.5mm"),
        ProductSpec(label: "Kenar Tipi", value: "Düz kenar"),
      ],
      cartType: CartType.wholesale,
    ),
  ];

  @override
  Future<List<FeedCard>> fetchFeed({
    required int page,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (page >= 7) return [];

    return List.generate(pageSize, (i) {
      final n = page * pageSize + i;
      final type = n % 6; // 0: video, 1: ürün, 2: abonelik, 3: banka ürünü
      switch (type) {
        case 0:
          return VideoCard(
            id: "v$n",
            videoUrl: "",
            username: "kullanici$n",
            description: "Örnek video açıklaması #$n",
            likeCount: (n * 37) % 5000,
          );
        case 1:
          return ProductCard(
            id: "pr$n",
            title: "Ürün #$n",
            imageUrl: "",
            price: 99.9 + n * 10,
            cartType: _demoCartTypes[n % _demoCartTypes.length],
          );
        case 2:
          return SubscriptionCard(
            id: "sub$n",
            serviceName: "Premium Paket #$n",
            description: "Özel içerik ve avantajlar",
            monthlyPrice: 29.9 + n,
          );
        case 3:
          return _bankProductBuilders[n % _bankProductBuilders.length](
            "bank$n",
          );
        case 4:
          return _ecommerceProductBuilders[n %
              _ecommerceProductBuilders.length]("ecmc$n");
        default:
          return _insuranceProductBuilders[n %
              _insuranceProductBuilders.length]("ins$n");
      }
    });
  }
}
