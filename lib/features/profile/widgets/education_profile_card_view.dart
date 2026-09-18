import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/education.dart';
import '../../../core/widgets/page_aware_scroll_view.dart';

/// Eğitim Profili — on üçüncü profil modülü.
///
/// TASARIM NOTU: StreamingProfileCard'daki kurum > program iki seviyeli
/// desen burada da kullanıldı — her KURUM kendi başlığıyla bir bölüm
/// açıyor (+ varsa etkileşim mekanizması alt satırda), içinde o kurumdan
/// alınan PROGRAMLAR yatay kaydırmalı duruyor. Her programın durumu
/// (Devam Ediyor / Tamamlandı / Periyodik) kendi rozetiyle ayrı ayrı
/// gösteriliyor — kurumun kendisi tek bir duruma sahip değil.
///
/// Modül vurgu rengi: koyu orman yeşili — önceki on iki modülden
/// (bordo/zümrüt/indigo/amber/mor/hardal/turkuaz/petrol-teal/mor) net
/// ayrışan, "büyüme/öğrenme" hissi.
class EducationProfileCardView extends StatelessWidget {
  final EducationProfileCard card;

  const EducationProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF3D6B35);
  static const _base = Color(0xFF0F130E);
  static const _baseEnd = Color(0xFF161C14);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final alert = card.nextRenewalAlert;

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
                if (alert != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _RenewalAlert(program: alert),
                  ),
                ],
                const SizedBox(height: 24),
                if (card.institutions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Henüz eklenmiş bir eğitim yok",
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                  )
                else
                  for (final institution in card.institutions) ...[
                    _InstitutionSection(institution: institution),
                    const SizedBox(height: 22),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final EducationProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.school_outlined,
                color: EducationProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Eğitim", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${card.institutions.length} kurum",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.1),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatChip(label: "Devam Ediyor", value: "${card.ongoingCount}"),
            _StatChip(label: "Tamamlandı", value: "${card.completedCount}"),
            _StatChip(label: "Periyodik", value: "${card.periodicCount}"),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: EducationProfileCardView.moduleAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: EducationProfileCardView.moduleAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RenewalAlert extends StatelessWidget {
  final EducationProgram program;
  const _RenewalAlert({required this.program});

  @override
  Widget build(BuildContext context) {
    final days = program.daysUntilRenewal ?? 0;
    final whenText = days <= 0 ? "Bugün" : "$days gün sonra";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EducationProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: EducationProfileCardView.moduleAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_repeat_outlined,
              color: EducationProfileCardView.moduleAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$whenText yeni dönem: ${program.name}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bir kurumun başlığı (+ varsa etkileşim mekanizması) ve o kurumdan
/// alınan programlar.
class _InstitutionSection extends StatelessWidget {
  final EducationInstitution institution;
  const _InstitutionSection({required this.institution});

  @override
  Widget build(BuildContext context) {
    final color = _institutionColor(institution.name);
    final hasChannel = institution.interactionChannel != null &&
        institution.interactionChannel!.isNotEmpty;

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
                  institution.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text("${institution.programs.length} program",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        if (hasChannel) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.hub_outlined, size: 13, color: color),
                const SizedBox(width: 6),
                Text(institution.interactionChannel!,
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          height: 168,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: institution.programs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _ProgramCard(program: institution.programs[i], color: color),
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final EducationProgram program;
  final Color color;
  const _ProgramCard({required this.program, required this.color});

  @override
  Widget build(BuildContext context) {
    final status = program.isRecurring
        ? "Periyodik"
        : (program.isOngoing ? "Devam Ediyor" : "Tamamlandı");

    return Container(
      width: 208,
      padding: const EdgeInsets.all(14),
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
                  program.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _StatusBadge(label: status, color: color),
          const Spacer(),
          if (program.isRecurring) ...[
            Text(
              program.type.label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            if (program.nextRenewalDate != null)
              Text(
                "Sonraki: ${_formatDate(program.nextRenewalDate!)}",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
          ] else if (program.isOngoing) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: program.progressPercent / 100,
                minHeight: 5,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "%${program.progressPercent.toStringAsFixed(0)} tamamlandı",
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ] else ...[
            Text(
              "${_formatDate(program.startDate)} - ${_formatDate(program.endDate!)}",
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            if (program.hasCertificate) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.workspace_premium_outlined, color: color, size: 14),
                  const SizedBox(width: 4),
                  const Text("Sertifikalı",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

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

// Kurum başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _institutionPalette = <Color>[
  Color(0xFF2E6B3D),
  Color(0xFF3E4A5A),
  Color(0xFF6B5A2E),
  Color(0xFF2E5A55),
];

Color _institutionColor(String name) {
  final index = name.hashCode.abs() % _institutionPalette.length;
  return _institutionPalette[index];
}

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
