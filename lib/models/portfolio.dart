/// Bir yatırım aracının türü.
enum AssetType { stock, fund, currency, gold, crypto, bond }

extension AssetTypeLabel on AssetType {
  String get label => switch (this) {
        AssetType.stock => "Hisse Senedi",
        AssetType.fund => "Yatırım Fonu",
        AssetType.currency => "Döviz",
        AssetType.gold => "Altın",
        AssetType.crypto => "Kripto Para",
        AssetType.bond => "Tahvil/Bono",
      };
}

/// Bir portföydeki TEK bir yatırım aracı pozisyonu.
class Holding {
  final String id;
  final String symbol; // örn. "THYAO", "USD", "Gram Altın", "BTC"
  final String name;
  final AssetType assetType;
  final double quantity;
  final double averageCost;
  final double currentPrice;
  final String currency;

  const Holding({
    required this.id,
    required this.symbol,
    required this.name,
    required this.assetType,
    required this.quantity,
    required this.averageCost,
    required this.currentPrice,
    this.currency = "TRY",
  });

  double get currentValue => quantity * currentPrice;
  double get costValue => quantity * averageCost;
  double get gainLoss => currentValue - costValue;
  double get gainLossPercent => costValue == 0 ? 0 : (gainLoss / costValue) * 100;
}

/// İşlem türü.
enum TransactionType { buy, sell, dividend }

extension TransactionTypeLabel on TransactionType {
  String get label => switch (this) {
        TransactionType.buy => "Alış",
        TransactionType.sell => "Satış",
        TransactionType.dividend => "Temettü",
      };
}

/// Bir portföyde gerçekleşmiş TEK bir işlem — "farklı aracı kurumlar
/// üzerinden yapılan işlemler" gereksinimi burada karşılanıyor.
class PortfolioTransaction {
  final String id;
  final TransactionType type;
  final String symbol;
  final double quantity;
  final double price;
  final String currency;
  final DateTime date;

  const PortfolioTransaction({
    required this.id,
    required this.type,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.date,
    this.currency = "TRY",
  });

  double get total => quantity * price;
}

/// Kullanıcının bir aracı kurum altında tuttuğu AYRI bir portföy (örn.
/// "Emeklilik Portföyüm", "Büyüme Portföyü"). Aynı aracı kurumun altında
/// birden fazla portföy olabilir — WalletProfileCard'daki "aynı bankanın
/// birden fazla hesabı" mantığının yatırım karşılığı.
class Portfolio {
  final String id;
  final String name;
  final List<Holding> holdings;
  final List<PortfolioTransaction> recentTransactions;

  const Portfolio({
    required this.id,
    required this.name,
    this.holdings = const [],
    this.recentTransactions = const [],
  });

  double get totalValue => holdings.fold(0.0, (sum, h) => sum + h.currentValue);
  double get totalCost => holdings.fold(0.0, (sum, h) => sum + h.costValue);
  double get totalGainLoss => totalValue - totalCost;
  double get totalGainLossPercent =>
      totalCost == 0 ? 0 : (totalGainLoss / totalCost) * 100;
}

/// Bir yatırım şirketi/aracı kurum ve kullanıcının o kurum altındaki
/// portföyleri.
class InvestmentBrokerage {
  final String id;
  final String name;
  final List<Portfolio> portfolios;

  const InvestmentBrokerage({
    required this.id,
    required this.name,
    this.portfolios = const [],
  });

  double get totalValue =>
      portfolios.fold(0.0, (sum, p) => sum + p.totalValue);
  double get totalGainLoss =>
      portfolios.fold(0.0, (sum, p) => sum + p.totalGainLoss);
}

/// "Son İşlemler" bölümü için: bir işlemi, hangi portföy/kurumdan
/// geldiğiyle birlikte taşıyan görüntüleme yardımcı kaydı. Ayrı bir alan
/// olarak `PortfolioTransaction`'a eklenmedi — işlem zaten kendi
/// portföyünün altında dururken bunu tekrar taşımasına gerek yok, bu
/// bilgi sadece TÜM portföyleri kesen özet görünümde lazım (bkz.
/// PortfolioProfileCard.recentTransactions).
class RecentTransactionEntry {
  final PortfolioTransaction transaction;
  final String portfolioName;
  final String brokerageName;

  const RecentTransactionEntry({
    required this.transaction,
    required this.portfolioName,
    required this.brokerageName,
  });
}
