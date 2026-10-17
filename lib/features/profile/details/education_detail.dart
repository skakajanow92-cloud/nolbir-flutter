import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/education.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/education_profile_card_view.dart';
import 'profile_detail_common.dart';

const _ongoingColor = Color(0xFF7FB8D9);

/// Eğitim modülünün masaüstü detay paneli görünümü: kurum > program
/// hiyerarşisi (mobildeki kartla aynı), her programın tüm alanlarıyla.
Widget buildEducationDetail(BuildContext context, EducationProfileCard card) {
  const accent = EducationProfileCardView.moduleAccent;
  final alert = card.nextRenewalAlert;

  return DetailPage(
    title: 'Eğitim',
    subtitle: '${card.institutions.length} kurum',
    icon: Icons.school_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Özet',
        spacing: 0,
        children: [
          DetailRow(label: 'Devam eden', value: '${card.ongoingCount}'),
          DetailRow(label: 'Tamamlanan', value: '${card.completedCount}'),
          DetailRow(label: 'Periyodik', value: '${card.periodicCount}'),
        ],
      ),
      if (alert != null)
        DetailSection(
          title: 'Yaklaşan Yeni Dönem',
          children: [
            DetailItem(
              accent: accent,
              icon: Icons.event_repeat_outlined,
              title: alert.name,
              subtitle: (alert.daysUntilRenewal ?? 0) <= 0
                  ? 'Bugün yeni dönem'
                  : '${alert.daysUntilRenewal} gün sonra yeni dönem',
              rows: [
                if (alert.nextRenewalDate != null)
                  DetailRow(
                    label: 'Sonraki dönem',
                    value: formatDate(alert.nextRenewalDate!),
                  ),
              ],
            ),
          ],
        ),
      if (card.institutions.isEmpty)
        const DetailSection(
          title: 'Kurumlar',
          children: [DetailEmpty('Henüz eklenmiş bir eğitim yok')],
        ),
      for (final inst in card.institutions)
        DetailSection(
          title: '${inst.name} (${inst.programs.length} program)',
          children: [
            if (inst.interactionChannel != null &&
                inst.interactionChannel!.isNotEmpty)
              DetailRow(label: 'Etkileşim', value: inst.interactionChannel!),
            if (inst.programs.isEmpty) const DetailEmpty('Program yok'),
            for (final p in inst.programs) _programItem(p, accent),
          ],
        ),
    ],
  );
}

Widget _programItem(EducationProgram p, Color accent) {
  final status = p.isRecurring
      ? 'Periyodik'
      : (p.isOngoing ? 'Devam Ediyor' : 'Tamamlandı');
  final statusColor = p.isRecurring
      ? detailOk
      : (p.isOngoing ? _ongoingColor : Colors.white54);

  return DetailItem(
    accent: accent,
    icon: Icons.school_outlined,
    title: p.name,
    subtitle: p.type.label,
    badge: DetailBadge(label: status, color: statusColor),
    rows: [
      DetailRow(label: 'Başlangıç', value: formatDate(p.startDate)),
      DetailRow(
        label: 'Bitiş',
        value: p.endDate != null ? formatDate(p.endDate!) : 'Devam ediyor',
      ),
      if (p.isRecurring && p.nextRenewalDate != null)
        DetailRow(
          label: 'Sonraki dönem',
          value: formatDate(p.nextRenewalDate!),
        ),
      if (p.price > 0)
        DetailRow(
          label: 'Ücret',
          value: '${formatMoney(p.price)} ${p.currency}',
        ),
      DetailRow(label: 'Sertifika', value: p.hasCertificate ? 'Var' : 'Yok'),
      if (!p.isRecurring && p.isOngoing)
        DetailProgress(
          value: p.progressPercent / 100,
          label: 'İlerleme',
          caption: '%${p.progressPercent.toStringAsFixed(0)} tamamlandı',
          color: _ongoingColor,
        ),
    ],
  );
}
