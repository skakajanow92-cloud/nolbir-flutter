import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../collection/widgets/save_to_collection_button.dart';
import 'ecommerce_shared_widgets.dart';
import 'appointment_booking_dialog.dart';

class DoctorAppointmentCardView extends StatelessWidget {
  final DoctorAppointmentCard card;

  const DoctorAppointmentCardView({super.key, required this.card});

  static const accent = Color(0xFF1FA2A6);

  void _openBooking(BuildContext context, AppointmentSlot slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppointmentBookingDialog(doctor: card, slot: slot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: const Color(0xFF0E1A1A),
      baseEndColor: const Color(0xFF142424),
      header: _Header(card: card),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              card.bio,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AttributeBadge(
                  text: card.specialty.label,
                  accentColor: accent,
                  icon: Icons.medical_services_outlined,
                ),
                if (card.isVerifiedSpecialist)
                  AttributeBadge(
                    text: "Doğrulanmış Uzman",
                    accentColor: accent,
                    icon: Icons.verified_outlined,
                  ),
                AttributeBadge(
                  text:
                      "${card.consultationFee.toStringAsFixed(0)} ${card.currency}",
                  accentColor: accent,
                  icon: Icons.payments_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const CardSectionLabel(text: "Müsait Randevu Saatleri"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.availableSlots.map((slot) {
                return ActionChip(
                  avatar: Icon(
                    slot.isOnline
                        ? Icons.videocam_outlined
                        : Icons.store_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  label: Text(
                    "${slot.dateTime.day.toString().padLeft(2, '0')}.${slot.dateTime.month.toString().padLeft(2, '0')} ${slot.dateTime.hour.toString().padLeft(2, '0')}:${slot.dateTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  onPressed: () => _openBooking(context, slot),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SaveToCollectionButton(card: card),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final DoctorAppointmentCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StoreLogo(logoUrl: card.doctorPhotoUrl, name: card.doctorName),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.doctorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card.clinicName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}
