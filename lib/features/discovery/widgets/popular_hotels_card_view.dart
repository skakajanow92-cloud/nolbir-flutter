import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';

class PopularHotelsCardView extends StatelessWidget {
  final PopularHotelsCard card;

  const PopularHotelsCardView({super.key, required this.card});

  static const _base = Color(0xFF14101F);
  static const _baseEnd = Color(0xFF1C1a30);
  static const accent = Color(0xFF6CA0F0);

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                card.subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            card.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          for (final hotel in card.hotels)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _HotelTile(hotel: hotel),
            ),
        ],
      ),
    );
  }
}

class _HotelTile extends StatelessWidget {
  final PopularHotelItem hotel;
  const _HotelTile({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 84,
              height: 84,
              color: Colors.white.withValues(alpha: 0.06),
              child: hotel.imageUrl.isEmpty
                  ? const Icon(Icons.hotel_outlined, color: Colors.white24)
                  : Image.network(hotel.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hotel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (hotel.smartBadge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: PopularHotelsCardView.accent.withValues(
                            alpha: 0.25,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hotel.smartBadge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hotel.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "${hotel.rating.toStringAsFixed(1)} (${hotel.reviewCount})",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (hotel.tags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: hotel.tags
                        .map(
                          (t) => Text(
                            "· $t",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  "${hotel.pricePerNight.toStringAsFixed(0)} TRY/gece",
                  style: const TextStyle(
                    color: PopularHotelsCardView.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
