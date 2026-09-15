import '../../../models/feed_card/feed_card.dart';
import '../../../models/wallet.dart';

/// Cüzdan modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
WalletProfileCard buildWalletMock() {
  return WalletProfileCard(
    id: "wallet1",
    accounts: [
      const BankAccount(
        id: "acc1",
        bankName: "Ziraat Bankası",
        type: BankAccountType.checking,
        balance: 12450.75,
      ),
      const BankAccount(
        id: "acc2",
        bankName: "İş Bankası",
        type: BankAccountType.checking,
        balance: 3200.10,
      ),
      BankAccount(
        id: "acc3",
        bankName: "Garanti BBVA",
        type: BankAccountType.timeDeposit,
        balance: 50000.00,
        interestRate: 42.5,
        maturityDate: DateTime(2026, 12, 15),
      ),
      BankAccount(
        id: "acc4",
        bankName: "Akbank",
        type: BankAccountType.timeDeposit,
        balance: 25750.00,
        interestRate: 41.0,
        maturityDate: DateTime(2027, 3, 1),
      ),
    ],
    creditCards: const [
      BankCreditCard(
        id: "cc1",
        bankName: "Ziraat Bankası",
        maskedNumber: "**** 4417",
        limit: 30000,
        used: 12500,
      ),
      BankCreditCard(
        id: "cc2",
        bankName: "Garanti BBVA",
        maskedNumber: "**** 9082",
        limit: 50000,
        used: 41250,
      ),
    ],
  );
}
