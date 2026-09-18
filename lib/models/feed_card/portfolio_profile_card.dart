import '../portfolio.dart';
import 'base.dart';

/// On dokuzuncu profil modülü: kullanıcının farklı yatırım şirketleri ve
/// aracı kurumlar üzerinden tuttuğu portföyler. Hiyerarşi üç seviyeli —
/// StreamingProfileCard'daki (kurum > paket) desenin bir katman daha
/// derini: aracı kurum > portföy > varlık. Ayrıca tüm portföyleri kesen
/// AYRI bir "son işlemler" özeti taşıyor (bkz. RecentTransactionEntry).
class PortfolioProfileCard extends FeedCard implements Collectible {
  final List<InvestmentBrokerage> brokerages;

  const PortfolioProfileCard({
    required String id,
    this.brokerages = const [],
  }) : super(id);

  double get totalValue =>
      brokerages.fold(0.0, (sum, b) => sum + b.totalValue);

  double get totalGainLoss =>
      brokerages.fold(0.0, (sum, b) => sum + b.totalGainLoss);

  double get totalGainLossPercent {
    final cost = totalValue - totalGainLoss;
    return cost == 0 ? 0 : (totalGainLoss / cost) * 100;
  }

  int get portfolioCount =>
      brokerages.fold(0, (sum, b) => sum + b.portfolios.length);

  /// Tüm portföylerdeki işlemleri, hangi portföy/kurumdan geldiğiyle
  /// birlikte tarihe göre (en yeni önce) sıralı döner.
  List<RecentTransactionEntry> get recentTransactions {
    final all = <RecentTransactionEntry>[];
    for (final b in brokerages) {
      for (final p in b.portfolios) {
        for (final t in p.recentTransactions) {
          all.add(RecentTransactionEntry(
            transaction: t,
            portfolioName: p.name,
            brokerageName: b.name,
          ));
        }
      }
    }
    all.sort((a, b) => b.transaction.date.compareTo(a.transaction.date));
    return all;
  }

  @override
  (String, String) toCollectionPreview() => ("Portföy Profili", "");
}
