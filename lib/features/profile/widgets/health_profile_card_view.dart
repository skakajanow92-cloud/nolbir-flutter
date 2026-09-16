import 'package:flutter/material.dart';
import 'package:nolbir/core/widgets/page_aware_scroll_view.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/health.dart';

/// Sağlık Profili — on birinci profil modülü.
///
/// TASARIM NOTU: Üç alt bölümü var (son ölçümler, randevular, düzenli
/// kullanılanlar) — Food ve Career modüllerindeki aynı gerekçeyle
/// (içerik tek ekrana sığmayabilir) dikey `SingleChildScrollView`
/// kullanıldı.
///
/// ÖNEMLİ: Bu kart yalnızca kullanıcının kendi kaydettiği verileri
/// LİSTELER — herhangi bir değeri "normal/anormal" diye yorumlamaz,
/// teşhis ya da tıbbi tavsiye üretmez. Ölçüm değerleri nötr olarak,
/// son ölçüm tarihiyle birlikte gösterilir.
///
/// Modül vurgu rengi: yumuşak menekşe-mor — Konaklama'nın gül-morundan
/// (0xFF6B4258) ve Sigorta'nın indigosundan (0xFF3A4E7A) ayrışan,
/// "bakım/sakinlik" hissi.
class HealthProfileCardView extends StatelessWidget {
  final HealthProfileCard card;

  const HealthProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF6A4E9C);
  static const _base = Color(0xFF110F16);
  static const _baseEnd = Color(0xFF191620);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final latest = card.latestMeasurements;
    final upcoming = card.upcomingAppointments;
    final past = card.pastAppointments;
    final ongoing = card.ongoingMedications;
    final nextAppointment = card.nextAlertAppointment;

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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border, color: moduleAccent, size: 20),
                      SizedBox(width: 8),
                      Text("Sağlık",
                          style: TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                ),
                if (nextAppointment != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _AlertBanner(appointment: nextAppointment),
                  ),
                ],
                const SizedBox(height: 22),
                _SectionLabel(text: "Son Ölçümler (${latest.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 116,
                  child: latest.isEmpty
                      ? const _EmptyHint(text: "Henüz ölçüm kaydedilmedi")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: latest.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _MeasurementMiniCard(measurement: latest[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Yaklaşan Randevular (${upcoming.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: upcoming.isEmpty
                      ? const _EmptyHint(text: "Yaklaşan randevu yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: upcoming.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => _AppointmentMiniCard(
                              appointment: upcoming[i], muted: false),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Geçmiş Randevular (${past.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: past.isEmpty
                      ? const _EmptyHint(text: "Geçmiş randevu yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: past.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => _AppointmentMiniCard(
                              appointment: past[i], muted: true),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Düzenli Kullandıklarım (${ongoing.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: ongoing.isEmpty
                      ? const _EmptyHint(text: "Düzenli kullanılan bir şey eklenmedi")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: ongoing.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _MedicationMiniCard(medication: ongoing[i]),
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

class _AlertBanner extends StatelessWidget {
  final HealthAppointment appointment;
  const _AlertBanner({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final days = appointment.dateTime.difference(DateTime.now()).inDays;
    final whenText = days <= 0 ? "Bugün" : "$days gün sonra";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: HealthProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: HealthProfileCardView.moduleAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_outlined,
              color: HealthProfileCardView.moduleAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$whenText: ${appointment.doctorName} · ${appointment.specialty}",
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

class _MeasurementMiniCard extends StatelessWidget {
  final VitalMeasurement measurement;
  const _MeasurementMiniCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(measurement.type.label);
    final days = measurement.daysAgo;
    final agoText = days <= 0 ? "bugün ölçüldü" : "$days gün önce";

    return Container(
      width: 164,
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
              Icon(_iconFor(measurement.type), color: color, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(measurement.type.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(measurement.displayValue,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(measurement.type.unit,
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(agoText,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _AppointmentMiniCard extends StatelessWidget {
  final HealthAppointment appointment;
  final bool muted;
  const _AppointmentMiniCard({required this.appointment, required this.muted});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(appointment.facility);

    return Opacity(
      opacity: muted ? 0.5 : 1.0,
      child: Container(
        width: 205,
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
                Icon(Icons.local_hospital_outlined, color: color, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(appointment.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(appointment.doctorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(appointment.facility,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const Spacer(),
            Text(_formatDateTime(appointment.dateTime),
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(appointment.type.label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _MedicationMiniCard extends StatelessWidget {
  final Medication medication;
  const _MedicationMiniCard({required this.medication});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(medication.name);

    return Container(
      width: 195,
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
              Icon(_iconForKind(medication.kind), color: color, size: 16),
              const SizedBox(width: 6),
              Text(medication.kind.label,
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(medication.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(medication.dosage,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          Text(medication.frequency,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}

IconData _iconFor(VitalType type) => switch (type) {
      VitalType.bloodSugar => Icons.water_drop_outlined,
      VitalType.bloodPressure => Icons.monitor_heart_outlined,
      VitalType.bodyTemperature => Icons.thermostat_outlined,
      VitalType.pulse => Icons.favorite_outline,
      VitalType.weight => Icons.monitor_weight_outlined,
      VitalType.oxygenSaturation => Icons.air_outlined,
    };

IconData _iconForKind(MedicationKind kind) => switch (kind) {
      MedicationKind.medicine => Icons.medication_outlined,
      MedicationKind.supplement => Icons.eco_outlined,
      MedicationKind.vitamin => Icons.wb_sunny_outlined,
    };

// Kaynak adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF443A5F),
  Color(0xFF3E4A5A),
  Color(0xFF3E5A4A),
  Color(0xFF5A3E52),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}

String _formatDateTime(DateTime d) {
  final date =
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  final time =
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  return "$date · $time";
}
