import 'package:flutter/material.dart';
import '../../../models/feed_card.dart';
import '../../../models/career.dart';

/// Kariyer/CV Profili — sekizinci profil modülü.
///
/// TASARIM NOTU: Food modülündeki gibi üç alt bölümü var (iş deneyimi,
/// eğitim, yetenekler) ve içerik her cihazda tek ekrana sığmayabilir —
/// bu yüzden aynı gerekçeyle dikey `SingleChildScrollView` kullanıldı.
///
/// Modül vurgu rengi: koyu grafit-mavi — önceki yedi modülden (bordo/
/// zümrüt/indigo/amber/mor/hardal/teal) ayrışan, "profesyonellik/iş
/// dünyası" hissi.
class CareerProfileCardView extends StatelessWidget {
  final CareerProfileCard card;

  const CareerProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF35404F);
  static const _base = Color(0xFF0F1114);
  static const _baseEnd = Color(0xFF181B20);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final experiences = card.sortedExperiences;
    final educations = card.sortedEducations;
    final current = card.currentExperience;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(headline: card.headline, current: current),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "İş Deneyimi (${experiences.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 168,
                  child: experiences.isEmpty
                      ? const _EmptyHint(text: "Henüz iş deneyimi eklenmedi")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: experiences.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _ExperienceMiniCard(experience: experiences[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Eğitim (${educations.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: educations.isEmpty
                      ? const _EmptyHint(text: "Henüz eğitim bilgisi eklenmedi")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: educations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _EducationMiniCard(education: educations[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Yetenekler (${card.skills.length})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: card.skills.isEmpty
                      ? const Text("Henüz yetenek eklenmedi",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: card.skills.map((s) => _SkillChip(skill: s)).toList(),
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
  final String headline;
  final WorkExperience? current;
  const _Header({required this.headline, required this.current});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.work_outline,
                color: CareerProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Kariyer", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          headline.isNotEmpty ? headline : "Kariyer bilgisi eklenmedi",
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.15),
        ),
        if (current != null) ...[
          const SizedBox(height: 6),
          Text(
            "${current!.title} · ${current!.company}",
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
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

class _ExperienceMiniCard extends StatelessWidget {
  final WorkExperience experience;
  const _ExperienceMiniCard({required this.experience});

  @override
  Widget build(BuildContext context) {
    final color = _companyColor(experience.company);

    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
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
              Icon(Icons.apartment_outlined, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(experience.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              if (experience.isCurrent) const _CurrentBadge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(experience.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(experience.employmentType.label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            "${_formatMonth(experience.startDate)} - "
            "${experience.endDate != null ? _formatMonth(experience.endDate!) : 'Günümüz'}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(experience.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF7FD98A).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text("Devam ediyor",
          style: TextStyle(
              color: Color(0xFF7FD98A), fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}

class _EducationMiniCard extends StatelessWidget {
  final EducationEntry education;
  const _EducationMiniCard({required this.education});

  @override
  Widget build(BuildContext context) {
    final color = _companyColor(education.school);

    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_outlined, color: color, size: 18),
          const SizedBox(height: 8),
          Text(education.school,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 2),
          Text("${education.degree} · ${education.fieldOfStudy}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          Text(
            "${education.startDate.year} - "
            "${education.endDate != null ? education.endDate!.year.toString() : 'Devam ediyor'}",
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final Skill skill;
  const _SkillChip({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CareerProfileCardView.moduleAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: CareerProfileCardView.moduleAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: skill.level.progress,
                minHeight: 4,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFB8C4D6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Şirket/okul başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _companyPalette = <Color>[
  Color(0xFF2E3A47),
  Color(0xFF3E4A5A),
  Color(0xFF35452E),
  Color(0xFF452E3E),
];

Color _companyColor(String seed) {
  final index = seed.hashCode.abs() % _companyPalette.length;
  return _companyPalette[index];
}

String _formatMonth(DateTime d) {
  const months = [
    "Oca", "Şub", "Mar", "Nis", "May", "Haz",
    "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara",
  ];
  return "${months[d.month - 1]} ${d.year}";
}
