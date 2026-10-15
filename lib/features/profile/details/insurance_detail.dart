import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../../../../models/insurance.dart';
import '../widgets/insurance_profile_card_view.dart';
import 'profile_detail_common.dart';

/// Sigorta modülünün masaüstü detay paneli görünümü: poliçe no, teminat, prim, tarihler.
Widget buildInsuranceDetail(BuildContext context, InsuranceProfileCard card) {
  const accent = InsuranceProfileCardView.moduleAccent;
  return DetailPage(
    title: 'Sigorta',
    subtitle: '${card.activeCount} aktif poliçe',
    icon: Icons.shield_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Poliçeler (${card.policies.length})',
        children: [
          if (card.policies.isEmpty)
            const DetailEmpty('Henüz kayıtlı poliçe yok'),
          for (final p in card.policies)
            DetailItem(
              accent: accent,
              icon: Icons.shield_outlined,
              title: p.company,
              subtitle: p.type.label,
              badge: DetailBadge(
                label: p.isActive ? 'Aktif' : 'Süresi Doldu',
                color: p.isActive ? detailOk : Colors.white54,
              ),
              rows: [
                DetailRow(label: 'Poliçe No', value: p.policyNumber),
                DetailRow(
                  label: 'Teminat',
                  value: '${formatMoney(p.coverageAmount)} ${p.currency}',
                  emphasize: true,
                ),
                DetailRow(
                  label: 'Prim',
                  value: '${formatMoney(p.premium)} ${p.currency}',
                ),
                DetailRow(label: 'Başlangıç', value: formatDate(p.startDate)),
                DetailRow(label: 'Bitiş', value: formatDate(p.endDate)),
              ],
            ),
        ],
      ),
    ],
  );
}
