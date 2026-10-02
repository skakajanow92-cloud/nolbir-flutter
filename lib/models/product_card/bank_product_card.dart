import '../feed_card/base.dart';

enum BankProductType { loan, checkingAccount, timeDeposit }

/// Vadeli mevduat için tek bir süre/faiz seçeneği.
class DepositTermOption {
  final int months;
  final double annualInterestRate; // yüzde, örn. 42.5

  const DepositTermOption({
    required this.months,
    required this.annualInterestRate,
  });
}

/// Kredi ürününe özel detaylar.
class LoanDetails {
  final double interestRate; // aylık, yüzde
  final int maxTermMonths;
  final double maxAmount;

  /// Kredi sadece hesap üzerinden mi kullanılıyor, yoksa buna bağlı
  /// dijital/fiziksel bir harcama kartı tanımlanmış mı.
  final bool hasDigitalCard;

  const LoanDetails({
    required this.interestRate,
    required this.maxTermMonths,
    required this.maxAmount,
    required this.hasDigitalCard,
  });
}

/// Vadesiz hesap ürününe özel detaylar.
class CheckingAccountDetails {
  /// Hesaba bağlı, günlük alışverişte kullanılacak bir kart var mı.
  final bool hasLinkedCard;
  final String? cardName; // kart varsa: "Bonus", "Axess" vb.
  final double? annualFee; // kart varsa yıllık ücret, ücretsizse 0/null

  const CheckingAccountDetails({
    required this.hasLinkedCard,
    this.cardName,
    this.annualFee,
  });
}

/// Vadeli mevduat ürününe özel detaylar.
class TimeDepositDetails {
  final List<DepositTermOption> termOptions;

  const TimeDepositDetails({required this.termOptions});

  /// Öne çıkarılacak en yüksek faizli seçenek.
  DepositTermOption get bestOption => termOptions.reduce(
        (a, b) => a.annualInterestRate >= b.annualInterestRate ? a : b,
      );
}

/// Orta tab için: bir bankanın tek bir ürününü tanıtan kart.
///
/// TASARIM NOTU: `productType` kapalı ve sabit bir küme (kredi/vadesiz
/// hesap/vadeli mevduat) — bankacılık ürünleri bunun dışına çıkmıyor. Bu
/// yüzden `FeedCard`'ın genel registry+fallback felsefesinin aksine, bu
/// tek kart türünün İÇİNDE (view tarafında) dar kapsamlı bir switch
/// kullanmak bilinçli bir tercih: yeni bir üst düzey kart türü değil,
/// mevcut türün üç sabit gövdesi.
class BankProductCard extends FeedCard implements Collectible {
  final String bankName;
  final String bankLogoUrl;
  final String title; // ürün başlığı, örn. "İhtiyaç Kredisi"
  final String description; // reklam metni / kısa açıklama
  final List<String> imageUrls; // opsiyonel ek görseller
  final String? detailUrl; // "banka hakkında" / ürün detay linki
  final double rating; // 0-5, sistem geriye dönük puanlaması
  final int reviewCount;

  final BankProductType productType;
  final LoanDetails? loanDetails;
  final CheckingAccountDetails? checkingAccountDetails;
  final TimeDepositDetails? timeDepositDetails;

  const BankProductCard({
    required String id,
    required this.bankName,
    required this.bankLogoUrl,
    required this.title,
    required this.description,
    required this.productType,
    this.imageUrls = const [],
    this.detailUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.loanDetails,
    this.checkingAccountDetails,
    this.timeDepositDetails,
  })  : assert(
          (productType == BankProductType.loan && loanDetails != null) ||
              (productType == BankProductType.checkingAccount &&
                  checkingAccountDetails != null) ||
              (productType == BankProductType.timeDeposit &&
                  timeDepositDetails != null),
          'productType ile eşleşen details alanı doldurulmalı',
        ),
        super(id);

  @override
  (String, String) toCollectionPreview() => (
        "$bankName · $title",
        imageUrls.isNotEmpty ? imageUrls.first : bankLogoUrl,
      );
}