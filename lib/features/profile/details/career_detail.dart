import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/career.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/career_profile_card_view.dart';
import 'profile_detail_common.dart';

/// Kariyer modülünün masaüstü detay paneli görünümü: iş tanımları, süreler, eğitim notları, yetenekler.
Widget buildCareerDetail(BuildContext context, CareerProfileCard card) {
  const accent = CareerProfileCardView.moduleAccent;
  final experiences = card.sortedExperiences;
  final educations = card.sortedEducations;
  return DetailPage(
    title: card.headline.isNotEmpty ? card.headline : 'Kariyer',
    subtitle: card.currentExperience != null
        ? '${card.currentExperience!.title} · ${card.currentExperience!.company}'
        : null,
    icon: Icons.work_outline,
    accent: accent,
    children: [
      DetailSection(
        title: 'İş Deneyimi (${experiences.length})',
        children: [
          if (experiences.isEmpty)
            const DetailEmpty('Henüz iş deneyimi eklenmedi'),
          for (final e in experiences)
            DetailItem(
              accent: accent,
              icon: Icons.apartment_outlined,
              title: e.title,
              subtitle: '${e.company} · ${e.employmentType.label}',
              badge: e.isCurrent
                  ? const DetailBadge(label: 'Devam ediyor', color: detailOk)
                  : null,
              rows: [
                DetailRow(
                  label: 'Dönem',
                  value: '${formatMonth(e.startDate)} - '
                      '${e.endDate != null ? formatMonth(e.endDate!) : 'Günümüz'}',
                ),
                DetailRow(label: 'Süre', value: formatDuration(e.durationInMonths)),
                DetailRow(label: 'Konum', value: e.location),
                if (e.description != null && e.description!.isNotEmpty)
                  DetailParagraph(e.description!),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'Eğitim (${educations.length})',
        children: [
          if (educations.isEmpty)
            const DetailEmpty('Henüz eğitim bilgisi eklenmedi'),
          for (final e in educations)
            DetailItem(
              accent: accent,
              icon: Icons.school_outlined,
              title: e.school,
              subtitle: '${e.degree} · ${e.fieldOfStudy}',
              rows: [
                DetailRow(
                  label: 'Dönem',
                  value: '${e.startDate.year} - '
                      '${e.endDate != null ? e.endDate!.year.toString() : 'Devam ediyor'}',
                ),
                if (e.note != null && e.note!.isNotEmpty)
                  DetailParagraph(e.note!),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'Yetenekler (${card.skills.length})',
        spacing: 4,
        children: [
          if (card.skills.isEmpty) const DetailEmpty('Henüz yetenek eklenmedi'),
          for (final s in card.skills)
            DetailProgress(
              label: s.name,
              caption: s.level.label,
              value: s.level.progress,
              color: const Color(0xFFB8C4D6),
            ),
        ],
      ),
    ],
  );
}
