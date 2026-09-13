/// Cüzdan modülünde kullanılan hesap türü.
enum BankAccountType { checking, timeDeposit }

extension BankAccountTypeLabel on BankAccountType {
  String get label => switch (this) {
        BankAccountType.checking => "Vadesiz",
        BankAccountType.timeDeposit => "Vadeli",
      };
}

/// Bir bankadaki tek bir hesap (vadesiz ya da vadeli).
class BankAccount {
  final String id;
  final String bankName;
  final BankAccountType type;
  final double balance;
  final String currency;
  final double? interestRate; // yıllık faiz oranı — sadece vadeli hesaplarda
  final DateTime? maturityDate; // vade tarihi — sadece vadeli hesaplarda

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.type,
    required this.balance,
    this.currency = "TRY",
    this.interestRate,
    this.maturityDate,
  });
}

/// Bir bankadan alınmış kredi kartı ve limiti.
class BankCreditCard {
  final String id;
  final String bankName;
  final String maskedNumber; // örn. **** 4417
  final double limit;
  final double used;
  final String currency;

  const BankCreditCard({
    required this.id,
    required this.bankName,
    required this.maskedNumber,
    required this.limit,
    required this.used,
    this.currency = "TRY",
  });

  double get available => limit - used;
  double get usageRatio => limit == 0 ? 0 : (used / limit).clamp(0, 1);
}
