import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'ecommerce_shared_widgets.dart' show AttributeBadge;

class DatingProfileDetailDialog extends StatelessWidget {
  final DatingProfile profile;

  const DatingProfileDetailDialog({super.key, required this.profile});

  static const accent = Color(0xFFFF5864);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF17121A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.05),
                    child: profile.photoUrl.isEmpty
                        ? const Icon(
                            Icons.person_outline,
                            color: Colors.white24,
                            size: 64,
                          )
                        : Image.network(profile.photoUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${profile.fullName}, ${profile.age}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile.hometown,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  if (profile.distanceKm != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      "· ${profile.distanceKm!.toStringAsFixed(0)} km uzakta",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Text(
                profile.bio,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (profile.hobbies.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  "İlgi Alanları",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.hobbies
                      .map((h) => AttributeBadge(text: h, accentColor: accent))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
