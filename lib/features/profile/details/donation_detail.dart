import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/donation.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/donation_profile_card_view.dart';

const _recurringColor = Color(0xFF7FD9D0);

/// Bağış modülünün masaüstü detay paneli görünümü.
///
/// GİZLİLİK: `politicalParty` mobildeki kartla AYNI kuralı izler — boş ya da
/// null ise bu satır HİÇ gösterilmez, "belirtilmedi" gibi bir yer tutucu bile
/// yoktur.
Widget buildDonationDetail(BuildContext context, DonationProfileCard card) {
  const accent = DonationProfileCardView.moduleAccent;
  final party = card.politicalParty;
  final donations = card.donations.toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  final recurringCount = card.donations.where((d) => d.isRecurring).length;

  // Kuruluşa göre toplam (para birimi kartın geneliyle aynı, TRY varsayılır).
  final byOrganization = <String, double>{};
  for (final d in card.donations) {
    byOrganization[d.organization] =
        (byOrganization[d.organization] ?? 0) + d.amount;
  }
  final organizationTotals = byOrganization.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return DetailPage(
    title: 'Bağış',
    subtitle: '${formatMoney(card.totalDonated)} TRY toplam bağış',
    icon: Icons.volunteer_activism_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Özet',
        spacing: 0,
        children: [
          DetailRow(
            label: 'Toplam bağış',
            value: '${formatMoney(card.totalDonated)} TRY',
            emphasize: true,
          ),
          DetailRow(label: 'Bağış sayısı', value: '${card.donations.length}'),
          DetailRow(label: 'Düzenli bağış', value: '$recurringCount'),
          if (party != null && party.isNotEmpty)
            DetailRow(label: 'Siyasi parti', value: party),
        ],
      ),
      DetailSection(
        title: 'Kuruluşlarım & Topluluklarım (${card.affiliations.length})',
        children: [
          if (card.affiliations.isEmpty)
            const DetailEmpty('Henüz eklenmiş kuruluş/topluluk yok'),
          for (final a in card.affiliations)
            DetailItem(
              accent: accent,
              icon: Icons.groups_outlined,
              title: a.name,
              subtitle: a.type.label,
              rows: [
                if (a.role != null && a.role!.isNotEmpty)
                  DetailRow(label: 'Görev', value: a.role!),
              ],
            ),
        ],
      ),
      if (organizationTotals.isNotEmpty)
        DetailSection(
          title: 'Kuruluşlara Göre Toplam',
          spacing: 0,
          children: [
            for (final e in organizationTotals)
              DetailRow(label: e.key, value: '${formatMoney(e.value)} TRY'),
          ],
        ),
      DetailSection(
        title: 'Bağışlarım (${donations.length})',
        children: [
          if (donations.isEmpty) const DetailEmpty('Henüz kayıtlı bağış yok'),
          for (final d in donations)
            DetailItem(
              accent: accent,
              icon: Icons.favorite_outline,
              title: d.organization,
              badge: d.isRecurring
                  ? const DetailBadge(label: 'Düzenli', color: _recurringColor)
                  : null,
              rows: [
                DetailRow(
                  label: 'Tutar',
                  value: '${formatMoney(d.amount)} ${d.currency}',
                  emphasize: true,
                ),
                DetailRow(label: 'Tarih', value: formatDate(d.date)),
              ],
            ),
        ],
      ),
    ],
  );
}
