import '../../../models/feed_card/feed_card.dart';
import '../../../models/portfolio.dart';

/// Portföy modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
PortfolioProfileCard buildPortfolioMock() {
  return PortfolioProfileCard(
    id: "portfolio1",
    brokerages: [
      // Aynı kurumdan İKİ portföy — modülün asıl ayırt edici durumu.
      InvestmentBrokerage(
        id: "brk1",
        name: "İş Yatırım",
        portfolios: [
          Portfolio(
            id: "pf1",
            name: "Büyüme Portföyü",
            holdings: const [
              Holding(
                id: "h1",
                symbol: "THYAO",
                name: "Türk Hava Yolları",
                assetType: AssetType.stock,
                quantity: 250,
                averageCost: 240.50,
                currentPrice: 289.75,
              ),
              Holding(
                id: "h2",
                symbol: "ASELS",
                name: "Aselsan",
                assetType: AssetType.stock,
                quantity: 400,
                averageCost: 62.10,
                currentPrice: 58.30,
              ),
              Holding(
                id: "h3",
                symbol: "BTC",
                name: "Bitcoin",
                assetType: AssetType.crypto,
                quantity: 0.015,
                averageCost: 1850000,
                currentPrice: 2210000,
              ),
            ],
            recentTransactions: [
              PortfolioTransaction(
                id: "t1",
                type: TransactionType.buy,
                symbol: "THYAO",
                quantity: 50,
                price: 275.00,
                date: DateTime.now().subtract(const Duration(days: 3)),
              ),
              PortfolioTransaction(
                id: "t2",
                type: TransactionType.sell,
                symbol: "ASELS",
                quantity: 100,
                price: 61.00,
                date: DateTime.now().subtract(const Duration(days: 9)),
              ),
            ],
          ),
          Portfolio(
            id: "pf2",
            name: "Emeklilik Portföyü",
            holdings: const [
              Holding(
                id: "h4",
                symbol: "Gram Altın",
                name: "Gram Altın",
                assetType: AssetType.gold,
                quantity: 45,
                averageCost: 2450,
                currentPrice: 2810,
              ),
              Holding(
                id: "h5",
                symbol: "TL Para Piyasası",
                name: "TL Likit Fon",
                assetType: AssetType.fund,
                quantity: 12000,
                averageCost: 1.00,
                currentPrice: 1.18,
              ),
            ],
            recentTransactions: [
              PortfolioTransaction(
                id: "t3",
                type: TransactionType.dividend,
                symbol: "TL Para Piyasası",
                quantity: 1,
                price: 340,
                date: DateTime.now().subtract(const Duration(days: 20)),
              ),
            ],
          ),
        ],
      ),
      InvestmentBrokerage(
        id: "brk2",
        name: "Garanti Yatırım",
        portfolios: [
          Portfolio(
            id: "pf3",
            name: "Döviz & Emtia",
            holdings: const [
              Holding(
                id: "h6",
                symbol: "USD",
                name: "Amerikan Doları",
                assetType: AssetType.currency,
                quantity: 5000,
                averageCost: 34.20,
                currentPrice: 33.65,
              ),
              Holding(
                id: "h7",
                symbol: "EUROBOND",
                name: "Hazine Eurobond 2030",
                assetType: AssetType.bond,
                quantity: 10,
                averageCost: 980,
                currentPrice: 1042,
              ),
            ],
            recentTransactions: [
              PortfolioTransaction(
                id: "t4",
                type: TransactionType.buy,
                symbol: "USD",
                quantity: 2000,
                price: 34.10,
                date: DateTime.now().subtract(const Duration(days: 1)),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
