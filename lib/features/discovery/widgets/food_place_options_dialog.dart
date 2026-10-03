import 'package:flutter/material.dart';

class FoodPlaceResult {
  final String name;
  final String imageUrl;
  final String cuisineType;
  final double rating;
  final int reviewCount;
  final int deliveryTimeMinutes;
  final double? distanceKm;
  final String priceRange; // "₺", "₺₺", "₺₺₺"

  const FoodPlaceResult({
    required this.name,
    required this.imageUrl,
    required this.cuisineType,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTimeMinutes,
    required this.priceRange,
    this.distanceKm,
  });
}

List<FoodPlaceResult> _mockFoodPlaces(
  String locationLabel,
  List<String> cuisines,
) {
  final seed = (locationLabel + cuisines.join()).hashCode.abs();
  const names = [
    "Köy Sofrası",
    "Napoli Pizzeria",
    "Doğu Mutfağı",
    "Yeşil Kase",
  ];
  return List.generate(4, (i) {
    return FoodPlaceResult(
      name: names[(seed + i) % names.length],
      imageUrl: "",
      cuisineType: cuisines.isNotEmpty
          ? cuisines[i % cuisines.length]
          : "Genel",
      rating: 3.6 + ((seed + i * 11) % 14) / 10,
      reviewCount: 60 + ((seed + i * 23) % 700),
      deliveryTimeMinutes: 20 + ((seed + i * 7) % 25),
      distanceKm: 0.5 + ((seed + i * 3) % 40) / 10,
      priceRange: ["₺", "₺₺", "₺₺₺"][(seed + i) % 3],
    );
  })..sort((a, b) => a.deliveryTimeMinutes.compareTo(b.deliveryTimeMinutes));
}

class FoodPlaceOptionsDialog extends StatelessWidget {
  final String locationLabel;
  final List<String> selectedCuisines;

  const FoodPlaceOptionsDialog({
    super.key,
    required this.locationLabel,
    required this.selectedCuisines,
  });

  @override
  Widget build(BuildContext context) {
    final places = _mockFoodPlaces(locationLabel, selectedCuisines);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1208),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                locationLabel.isEmpty ? "Sonuçlar" : locationLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${places.length} işletme bulundu",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final place in places)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PlaceTile(place: place),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final FoodPlaceResult place;
  const _PlaceTile({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              color: Colors.white.withValues(alpha: 0.06),
              child: const Icon(Icons.storefront, color: Colors.white24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${place.cuisineType} · ${place.priceRange}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "${place.rating.toStringAsFixed(1)} (${place.reviewCount})",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.delivery_dining,
                      color: Colors.white38,
                      size: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "${place.deliveryTimeMinutes} dk",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
