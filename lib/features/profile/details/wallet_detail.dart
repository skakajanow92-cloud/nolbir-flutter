import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../../../../models/wallet.dart';
import '../widgets/wallet_profile_card_view.dart';

/// Cüzdan modülünün masaüstü detay paneli görünümü: tüm hesaplar ve kredi kartları.
Widget buildWalletDetail(BuildContext context, WalletProfileCard card) {
  const accent = WalletProfileCardView.moduleAccent;
  return DetailPage(
    title: 'Cüzdan',
    subtitle:
        '${formatMoney(card.totalBalance, decimals: 2)} TRY toplam bakiye',
    icon: Icons.account_balance_wallet_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Hesaplar (${card.accounts.length})',
        children: [
          if (card.accounts.isEmpty) const DetailEmpty('Henüz bağlı hesap yok'),
          for (final a in card.accounts)
            DetailItem(
              accent: accent,
              icon: Icons.account_balance_outlined,
              title: a.bankName,
              subtitle: a.type.label,
              rows: [
                DetailRow(
                  label: 'Bakiye',
                  value: '${formatMoney(a.balance, decimals: 2)} ${a.currency}',
                  emphasize: true,
                ),
                if (a.interestRate != null)
                  DetailRow(label: 'Yıllık faiz', value: '%${a.interestRate}'),
                if (a.maturityDate != null)
                  DetailRow(label: 'Vade', value: formatDate(a.maturityDate!)),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'Kredi Kartları (${card.creditCards.length})',
        children: [
          if (card.creditCards.isEmpty)
            const DetailEmpty('Henüz kayıtlı kredi kartı yok'),
          for (final c in card.creditCards)
            DetailItem(
              accent: accent,
              icon: Icons.credit_card,
              title: c.bankName,
              subtitle: c.maskedNumber,
              rows: [
                DetailRow(
                  label: 'Limit',
                  value: '${formatMoney(c.limit)} ${c.currency}',
                ),
                DetailRow(
                  label: 'Kullanılan',
                  value: '${formatMoney(c.used)} ${c.currency}',
                ),
                DetailRow(
                  label: 'Kullanılabilir',
                  value: '${formatMoney(c.available)} ${c.currency}',
                  emphasize: true,
                ),
              ],
              footer: DetailProgress(
                value: c.usageRatio,
                caption: '%${(c.usageRatio * 100).round()} kullanım',
              ),
            ),
        ],
      ),
    ],
  );
}
