import '../wallet.dart';
import 'base.dart';

/// İkinci profil modülü: kullanıcının farklı bankalardaki hesapları ve
/// kredi kartları. Diğer profil modüllerinden (Temel Bilgiler vb.)
/// tamamen bağımsız — kendi rengi, kendi görünümü, kendi veri kaynağı
/// olacak (bkz. wallet_profile_card_view.dart).
class WalletProfileCard extends FeedCard implements Collectible {
  final List<BankAccount> accounts;
  final List<BankCreditCard> creditCards;

  const WalletProfileCard({
    required String id,
    this.accounts = const [],
    this.creditCards = const [],
  }) : super(id);

  // NOT: Şimdilik tüm hesapların TRY olduğu varsayılıyor — çoklu para
  // birimi toplamı (döviz kuru çevrimi) backend adımında ele alınacak.
  double get totalBalance => accounts.fold(0.0, (sum, a) => sum + a.balance);

  @override
  (String, String) toCollectionPreview() => ("Cüzdan Profili", "");
}
