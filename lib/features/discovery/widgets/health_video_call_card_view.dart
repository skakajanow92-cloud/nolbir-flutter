import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'instant_consult_dialog.dart';

class HealthVideoCallCardView extends StatelessWidget {
  final HealthVideoCallCard card;

  const HealthVideoCallCardView({super.key, required this.card});

  static const accent = Color(0xFF1FA2A6);

  Future<void> _joinAppointment(
    BuildContext context,
    UpcomingHealthAppointment appt,
  ) async {
    // AYRI tıbbi kanal — bkz. HealthVideoCallCard yorumları.
    await connectToMedicalChannel(context, specialty: appt.specialty);
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dr. ${appt.doctorName} ile görüşme başladı (mock)"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _openInstantConsult(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          InstantConsultDialog(specialties: card.instantSpecialties),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: const Color(0xFF0E1A1A),
      baseEndColor: const Color(0xFF142424),
      header: const _Header(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: () => _openInstantConsult(context),
                icon: const Icon(Icons.flash_on_outlined),
                label: const Text("Hemen Görüş"),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CardSectionLabel(text: "Yaklaşan Randevularınız"),
          ),
          const SizedBox(height: 10),
          if (card.upcomingAppointments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Yaklaşan randevunuz yok.",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            )
          else
            for (final appt in card.upcomingAppointments)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: _AppointmentTile(
                  appointment: appt,
                  onJoin: () => _joinAppointment(context, appt),
                ),
              ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.local_hospital_outlined,
            color: HealthVideoCallCardView.accent,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sağlık Görüşmeleri",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Yalnızca doğrulanmış uzmanlarla",
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final UpcomingHealthAppointment appointment;
  final VoidCallback onJoin;
  const _AppointmentTile({required this.appointment, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final joinable = appointment.isJoinable;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: joinable
            ? Border.all(
                color: HealthVideoCallCardView.accent.withValues(alpha: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            child: appointment.doctorPhotoUrl.isEmpty
                ? const Icon(Icons.person_outline, color: Colors.white54)
                : ClipOval(
                    child: Image.network(
                      appointment.doctorPhotoUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${appointment.specialty.label} · ${appointment.scheduledAt.hour.toString().padLeft(2, '0')}:${appointment.scheduledAt.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: joinable
                  ? HealthVideoCallCardView.accent
                  : Colors.white12,
            ),
            onPressed: joinable ? onJoin : null,
            child: Text(joinable ? "Katıl" : "Bekliyor"),
          ),
        ],
      ),
    );
  }
}
