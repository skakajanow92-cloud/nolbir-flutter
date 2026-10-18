import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../collection/widgets/save_to_collection_button.dart';
import 'ecommerce_shared_widgets.dart';

class ClinicProfileCardView extends StatelessWidget {
  final ClinicProfileCard card;

  const ClinicProfileCardView({super.key, required this.card});

  static const accent = Color(0xFF1FA2A6);

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: const Color(0xFF0E1A1A),
      baseEndColor: const Color(0xFF142424),
      header: _Header(card: card),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageGallery(imageUrls: card.imageUrls),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              card.description,
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
              children: card.specialties
                  .map(
                    (s) => AttributeBadge(text: s.label, accentColor: accent),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CardSectionLabel(text: "Doktor Kadrosu"),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: card.doctors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => _DoctorChip(doctor: card.doctors[i]),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    card.address,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${card.clinicName} için randevu akışına yönlendiriliyor (mock)",
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text("Randevu Al"),
                  ),
                ),
                const SizedBox(width: 10),
                SaveToCollectionButton(card: card),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ClinicProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StoreLogo(logoUrl: card.logoUrl, name: card.clinicName),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            card.clinicName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}

class _DoctorChip extends StatelessWidget {
  final ClinicDoctorSummary doctor;
  const _DoctorChip({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            child: doctor.photoUrl.isEmpty
                ? const Icon(Icons.person_outline, color: Colors.white54)
                : ClipOval(
                    child: Image.network(
                      doctor.photoUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            doctor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
