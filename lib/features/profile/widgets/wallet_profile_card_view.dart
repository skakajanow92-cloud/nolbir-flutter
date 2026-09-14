import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/wallet.dart';

/// Cüzdan Profili — ikinci profil modülü.
///
/// TASARIM NOTU: `CardShell`'in sabit background/bottomContent/actions
/// slotları bu kart için yeterince esnek değil (yatay kaydırmalı hesap ve
/// kredi kartı listeleri tam genişlik istiyor) — bu yüzden bilinçli olarak
/// `CardShell` kullanılmadı, tamamen özel bir tam ekran layout kuruldu.
/// Bu, sistemin "her kart türü CardShell'e mecbur değil, kendi düzenini
/// kurabilir" esnekliğinin somut örneği.
///
/// Modül vurgu rengi: koyu zümrüt yeşili — Temel Bilgiler kartının
/// bordosundan bilinçli olarak farklı, "mali/güven" hissi veriyor.
class WalletProfileCardView extends StatelessWidget {
  final WalletProfileCard card;

  const WalletProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF1F6F5C);
  static const _base = Color(0xFF0F1210);
  static const _baseEnd = Color(0xFF161B19);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Header(card: card),
              ),
              const SizedBox(height: 28),
              _SectionLabel(text: "Hesaplarım (${card.accounts.length})"),
              const SizedBox(height: 12),
              SizedBox(
                height: 152,
                child: card.accounts.isEmpty
                    ? const _EmptyHint(text: "Henüz bağlı hesap yok")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: card.accounts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _AccountMiniCard(account: card.accounts[i]),
                      ),
              ),
              const SizedBox(height: 28),
              _SectionLabel(text: "Kredi Kartlarım (${card.creditCards.length})"),
              const SizedBox(height: 12),
              SizedBox(
                height: 152,
                child: card.creditCards.isEmpty
                    ? const _EmptyHint(text: "Henüz kayıtlı kredi kartı yok")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: card.creditCards.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _CreditCardMiniCard(card: card.creditCards[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final WalletProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: WalletProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Cüzdan", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${card.totalBalance.toStringAsFixed(2)} TRY",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.1),
        ),
        const SizedBox(height: 2),
        const Text("toplam bakiye (vadesiz + vadeli)",
            style: TextStyle(color: Colors.white38, fontSize: 13)),
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
          style: const TextStyle(
              color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
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

class _AccountMiniCard extends StatelessWidget {
  final BankAccount account;
  const _AccountMiniCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final color = _bankColor(account.bankName);
    final isTimeDeposit = account.type == BankAccountType.timeDeposit;

    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  account.bankName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const SizedBox(width: 6),
              _TypeBadge(label: account.type.label, color: color),
            ],
          ),
          const Spacer(),
          Text(
            "${account.balance.toStringAsFixed(2)} ${account.currency}",
            style: const TextStyle(
                color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (isTimeDeposit && account.maturityDate != null)
            Text(
              "Vade: ${_formatDate(account.maturityDate!)}"
              "${account.interestRate != null ? ' · %${account.interestRate}' : ''}",
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            )
          else
            const Text("Anında kullanılabilir",
                style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _CreditCardMiniCard extends StatelessWidget {
  final BankCreditCard card;
  const _CreditCardMiniCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final color = _bankColor(card.bankName);

    return Container(
      width: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.55)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(card.bankName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const Icon(Icons.credit_card, color: Colors.white70, size: 18),
            ],
          ),
          const Spacer(),
          Text(card.maskedNumber,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: card.usageRatio,
              minHeight: 5,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${card.available.toStringAsFixed(0)} ${card.currency} kullanılabilir",
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// Banka başına sabit, elle seçilmiş uyumlu bir palet — rastgele/asorti
// renk karmaşasından kaçınmak için (bkz. frontend-design ilkeleri).
const _bankPalette = <Color>[
  Color(0xFF2F5233),
  Color(0xFF1F3B57),
  Color(0xFF5C3A21),
  Color(0xFF4A2545),
  Color(0xFF203A43),
];

Color _bankColor(String bankName) {
  final index = bankName.hashCode.abs() % _bankPalette.length;
  return _bankPalette[index];
}
