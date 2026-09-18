import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/portfolio.dart';
import '../../../core/widgets/page_aware_scroll_view.dart';

/// Portföy Profili — on dokuzuncu profil modülü.
///
/// TASARIM NOTU: Hiyerarşi ÜÇ seviyeli (aracı kurum > portföy > varlık) —
/// StreamingProfileCard'daki iki seviyeli (kurum > paket) desenden bir
/// katman derin. Üçüncü seviyeyi (varlıklar) ayrı bir yatay kaydırma
/// katmanı yapmadım — yatay kaydırma İÇİNDE yatay kaydırma kullanıcı
/// deneyimini karmaşıklaştırır. Bunun yerine her portföy kartının içinde
/// varlıklar kısa, dikey bir liste (en fazla ilk 3 + "+N daha") olarak
/// duruyor. "Yapılan işlemler" gereksinimi ise TÜM portföyleri kesen ayrı
/// bir "Son İşlemler" bölümünde, hangi kurum/portföyden geldiği
/// etiketiyle birlikte gösteriliyor.
///
/// Modül vurgu rengi: kobalt mavi — önceki modüllerin hiçbiriyle
/// çakışmayan, "borsa/grafik" hissi veren net bir mavi.
class PortfolioProfileCardView extends StatelessWidget {
  final PortfolioProfileCard card;

  const PortfolioProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF2E5C9E);
  static const profitColor = Color(0xFF4CAF7D);
  static const lossColor = Color(0xFFD16C6C);
  static const _base = Color(0xFF0D1116);
  static const _baseEnd = Color(0xFF141B24);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final transactions = card.recentTransactions;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: SafeArea(
          child: PageAwareScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(card: card),
                ),
                const SizedBox(height: 24),
                if (card.brokerages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Henüz bağlı bir portföy yok",
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                  )
                else
                  for (final brokerage in card.brokerages) ...[
                    _BrokerageSection(brokerage: brokerage),
                    const SizedBox(height: 22),
                  ],
                _SectionLabel(text: "Son İşlemler (${transactions.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 118,
                  child: transactions.isEmpty
                      ? const _EmptyHint(text: "Henüz işlem yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: transactions.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _TransactionMiniCard(entry: transactions[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PortfolioProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    final isProfit = card.totalGainLoss >= 0;
    final glColor =
        isProfit ? PortfolioProfileCardView.profitColor : PortfolioProfileCardView.lossColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.show_chart, color: PortfolioProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Portföy", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(card.totalValue)} TRY",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(isProfit ? Icons.arrow_upward : Icons.arrow_downward, color: glColor, size: 14),
            const SizedBox(width: 4),
            Text(
              "${isProfit ? '+' : ''}${_formatMoney(card.totalGainLoss)} TRY "
              "(${isProfit ? '+' : ''}${card.totalGainLossPercent.toStringAsFixed(1)}%)",
              style: TextStyle(color: glColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          "${card.brokerages.length} aracı kurum · ${card.portfolioCount} portföy",
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text,
          style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      ),
    );
  }
}

/// Bir aracı kurumun başlığı (+ toplam değeri) ve o kurum altındaki
/// portföyler.
class _BrokerageSection extends StatelessWidget {
  final InvestmentBrokerage brokerage;
  const _BrokerageSection({required this.brokerage});

  @override
  Widget build(BuildContext context) {
    final color = _brokerageColor(brokerage.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  brokerage.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                "${_formatMoney(brokerage.totalValue)} TRY",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "${brokerage.portfolios.length} portföy",
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 212,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: brokerage.portfolios.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _PortfolioCard(portfolio: brokerage.portfolios[i], color: color),
          ),
        ),
      ],
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final Portfolio portfolio;
  final Color color;
  const _PortfolioCard({required this.portfolio, required this.color});

  @override
  Widget build(BuildContext context) {
    final isProfit = portfolio.totalGainLoss >= 0;
    final glColor =
        isProfit ? PortfolioProfileCardView.profitColor : PortfolioProfileCardView.lossColor;
    // En değerli 3 varlık gösterilir, gerisi "+N daha" ile özetlenir —
    // portföy kartı içinde bir yatay kaydırma daha AÇMAMAK için (bkz.
    // sınıfın üstündeki TASARIM NOTU).
    final sortedHoldings = [...portfolio.holdings]
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final shown = sortedHoldings.take(3).toList();
    final remaining = sortedHoldings.length - shown.length;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            portfolio.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "${_formatMoney(portfolio.totalValue)} TRY",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            "${isProfit ? '+' : ''}${portfolio.totalGainLossPercent.toStringAsFixed(1)}%",
            style: TextStyle(color: glColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),
          for (final h in shown) _HoldingRow(holding: h),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text("+$remaining varlık daha",
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ),
        ],
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  final Holding holding;
  const _HoldingRow({required this.holding});

  @override
  Widget build(BuildContext context) {
    final isProfit = holding.gainLoss >= 0;
    final glColor =
        isProfit ? PortfolioProfileCardView.profitColor : PortfolioProfileCardView.lossColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              holding.symbol,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Text(
            "${isProfit ? '+' : ''}${holding.gainLossPercent.toStringAsFixed(1)}%",
            style: TextStyle(color: glColor, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TransactionMiniCard extends StatelessWidget {
  final RecentTransactionEntry entry;
  const _TransactionMiniCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final t = entry.transaction;
    final color = _brokerageColor(entry.brokerageName);

    return Container(
      width: 194,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconFor(t.type), color: color, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${t.type.label} · ${t.currency}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "${t.quantity} × ${_formatMoney(t.price)} ${t.currency}",
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            "${entry.brokerageName} · ${entry.portfolioName}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
          const Spacer(),
          Text(_formatDate(t.date),
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

IconData _iconFor(TransactionType type) => switch (type) {
      TransactionType.buy => Icons.add_circle_outline,
      TransactionType.sell => Icons.remove_circle_outline,
      TransactionType.dividend => Icons.savings_outlined,
    };

// Kurum başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _brokeragePalette = <Color>[
  Color(0xFF2E4A6B),
  Color(0xFF2E5A55),
  Color(0xFF4A3E6B),
  Color(0xFF5A4E2E),
];

Color _brokerageColor(String name) {
  final index = name.hashCode.abs() % _brokeragePalette.length;
  return _brokeragePalette[index];
}

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
