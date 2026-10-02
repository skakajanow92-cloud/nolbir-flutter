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
  static final List<BankProductCard Function(String id)> _bankProductBuilders = [
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
          checkingAccountDetails: const CheckingAccountDetails(hasLinkedCard: false),
        ),
    (id) => BankProductCard(
          id: id,
          bankName: "Liman Bankası",
          bankLogoUrl: "",
          title: "Vadeli Mevduat",
          description:
              "Farklı vade seçenekleriyle yüksek getirili mevduat hesabı.",
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

  @override
  Future<List<FeedCard>> fetchFeed({required int page, int pageSize = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (page >= 5) return [];

    return List.generate(pageSize, (i) {
      final n = page * pageSize + i;
      final type = n % 4; // 0: video, 1: ürün, 2: abonelik, 3: banka ürünü
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
        default:
          return _bankProductBuilders[n % _bankProductBuilders.length]("bank$n");
      }
    });
  }
}