import 'package:flutter/material.dart';

class HotelOptionItem {
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final double pricePerNight;
  final String? smartBadge; // "Rotanıza yakın", "Akıllı öneri" gibi

  const HotelOptionItem({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.pricePerNight,
    this.smartBadge,
  });
}

List<HotelOptionItem> _mockHotelOptions(String destinationLabel) {
  final seed = destinationLabel.hashCode.abs();
  const names = [
    "Mavi Koy Otel",
    "Şehir Merkezi Suites",
    "Yeşil Vadi Resort",
    "Liman Butik Otel",
  ];
  return List.generate(4, (i) {
    final price = 900.0 + ((seed + i * 173) % 2200);
    return HotelOptionItem(
      name: names[(seed + i) % names.length],
      imageUrl: "",
      rating: 3.6 + ((seed + i * 7) % 14) / 10,
      reviewCount: 80 + ((seed + i * 31) % 900),
      tags: [
        if (i.isEven) "Wi-Fi",
        if (i % 3 == 0) "Evcil Hayvan Dostu",
        "Kahvaltı Dahil",
      ],
      pricePerNight: price,
      smartBadge: i == 0 ? "Rotanıza yakın" : null,
    );
  })..sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
}

class HotelOptionsDialog extends StatelessWidget {
  final String destinationLabel;
  final int guestCount;
  final int roomCount;

  const HotelOptionsDialog({
    super.key,
    required this.destinationLabel,
    required this.guestCount,
    required this.roomCount,
  });

  @override
  Widget build(BuildContext context) {
    final options = _mockHotelOptions(destinationLabel);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF14181A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                destinationLabel.isEmpty ? "Sonuçlar" : destinationLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$guestCount misafir · $roomCount oda · ${options.length} otel bulundu",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final hotel in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HotelOptionTile(hotel: hotel),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HotelOptionTile extends StatelessWidget {
  final HotelOptionItem hotel;
  const _HotelOptionTile({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 72,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
                          color: Colors.lightBlueAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hotel.smartBadge!,
                          style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
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
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${hotel.pricePerNight.toStringAsFixed(0)} TRY/gece",
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // NOT: Sepete ekleme burada henüz bağlı değil —
                        // sadece arayüz, gerçek entegrasyon refactor
                        // turunda (CartType'a konaklama eklenince).
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${hotel.name} seçildi (mock)"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text("Seç"),
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
