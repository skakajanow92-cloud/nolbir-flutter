import '../../../models/cart_card/cart_card.dart';
import '../../../models/bank_cart.dart';
import '../../../models/cart.dart';

BankCartCard buildBankCartMock() {
  return BankCartCard(
    id: "bankcart1",
    cart: Cart(
      cartType: CartType.banking,
      items: [
        // Para transferiyle açılan akış: transfer bekleniyor → transfer
        // tamamlandı → hesap açıldı. Belge onayı YOK.
        CartItem(
          id: "bci1",
          cartType: CartType.banking,
          title: "12 Ay Vadeli TL Mevduat",
          price: 50000,
          metadata: {
            "productType": BankProductType.deposit,
            "bankName": "Garanti BBVA",
            "interestRate": 44.5,
            "termMonths": 12,
            "processSteps": <ProcessStep>[
              ProcessStep(
                id: "s1",
                label: "Para Transferi",
                status: ProcessStepStatus.completed,
                completedAt: DateTime.now().subtract(const Duration(hours: 3)),
              ),
              ProcessStep(
                id: "s2",
                label: "Hesap Açılışı",
                status: ProcessStepStatus.inProgress,
              ),
            ],
          },
        ),
        // Forma yönlendirip belge onayı bekleyen akış: form dolduruldu →
        // belge onayı → kredi tahsisi. Para transferi YOK, en sonda kredi
        // tutarı kullanıcıya aktarılır.
        CartItem(
          id: "bci2",
          cartType: CartType.banking,
          title: "İhtiyaç Kredisi",
          price: 75000,
          metadata: {
            "productType": BankProductType.loan,
            "bankName": "Akbank",
            "interestRate": 3.89,
            "termMonths": 24,
            "processSteps": <ProcessStep>[
              ProcessStep(
                id: "s3",
                label: "Başvuru Formu",
                status: ProcessStepStatus.completed,
                completedAt: DateTime.now().subtract(const Duration(days: 1)),
              ),
              ProcessStep(
                id: "s4",
                label: "Belge Onayı",
                status: ProcessStepStatus.inProgress,
                note: "Gelir belgesi inceleniyor",
              ),
              ProcessStep(
                id: "s5",
                label: "Kredi Tahsisi",
                status: ProcessStepStatus.pending,
              ),
            ],
          },
        ),
        // Tamamlanmış bir ürün — "Tamamlanan Ürünlerim" bölümünü
        // doldurmak için.
        CartItem(
          id: "bci3",
          cartType: CartType.banking,
          title: "Gram Altın Alımı",
          price: 12500,
          metadata: {
            "productType": BankProductType.preciousMetal,
            "bankName": "Ziraat Bankası",
            "processSteps": <ProcessStep>[
              ProcessStep(
                id: "s6",
                label: "Para Transferi",
                status: ProcessStepStatus.completed,
                completedAt: DateTime.now().subtract(const Duration(days: 4)),
              ),
              ProcessStep(
                id: "s7",
                label: "Altın Hesabına Aktarım",
                status: ProcessStepStatus.completed,
                completedAt: DateTime.now().subtract(const Duration(days: 4, hours: -1)),
              ),
            ],
          },
        ),
      ],
    ),
    comparisons: const [
      InterestRateComparisonGroup(
        id: "irc1",
        productName: "12 Ay Vadeli TL Mevduat",
        productType: BankProductType.deposit,
        offers: [
          BankOffer(id: "bo1", bankName: "Garanti BBVA", interestRate: 44.5),
          BankOffer(id: "bo2", bankName: "İş Bankası", interestRate: 46.0),
          BankOffer(id: "bo3", bankName: "Akbank", interestRate: 43.2),
        ],
      ),
      InterestRateComparisonGroup(
        id: "irc2",
        productName: "İhtiyaç Kredisi",
        productType: BankProductType.loan,
        offers: [
          BankOffer(id: "bo4", bankName: "Akbank", interestRate: 3.89),
          BankOffer(id: "bo5", bankName: "Yapı Kredi", interestRate: 3.65),
          BankOffer(id: "bo6", bankName: "QNB Finansbank", interestRate: 4.10),
        ],
      ),
    ],
    recommendations: const [
      RecommendedBankProduct(
        id: "rbp1",
        productName: "6 Ay Vadeli Döviz Mevduatı",
        productType: BankProductType.deposit,
        bankName: "İş Bankası",
        interestRate: 5.2,
        reason: BankRecommendationReason.alternativeProduct,
      ),
      RecommendedBankProduct(
        id: "rbp2",
        productName: "12 Ay Vadeli TL Mevduat",
        productType: BankProductType.deposit,
        bankName: "İş Bankası",
        interestRate: 46.0,
        reason: BankRecommendationReason.betterRate,
      ),
      RecommendedBankProduct(
        id: "rbp3",
        productName: "Kiralık Kasa",
        productType: BankProductType.safeBox,
        bankName: "Garanti BBVA",
        reason: BankRecommendationReason.alternativeProduct,
      ),
    ],
  );
}
