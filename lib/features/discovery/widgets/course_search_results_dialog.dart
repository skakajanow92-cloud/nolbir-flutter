import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

class CourseSearchResult {
  final String title;
  final String providerName;
  final CourseFormat format;
  final CourseLevel level;
  final double price;
  final String currency;
  final double rating;

  const CourseSearchResult({
    required this.title,
    required this.providerName,
    required this.format,
    required this.level,
    required this.price,
    required this.rating,
    this.currency = "TRY",
  });
}

List<CourseSearchResult> _mockResults(String subject, String language) {
  final seed = (subject + language).hashCode.abs();
  const providers = [
    "Akademi Bir",
    "Bilge Okul",
    "Mentor Sınıfı",
    "Kampüs Online",
  ];
  return List.generate(4, (i) {
    return CourseSearchResult(
      title: "$subject ${i == 0 ? "Temelleri" : "Serisi #$i"}",
      providerName: providers[(seed + i) % providers.length],
      format: CourseFormat.values[(seed + i) % CourseFormat.values.length],
      level: CourseLevel.values[(seed + i) % CourseLevel.values.length],
      price: 300.0 + ((seed + i * 97) % 2000),
      rating: 3.6 + ((seed + i * 13) % 14) / 10,
    );
  })..sort((a, b) => a.price.compareTo(b.price));
}

class CourseSearchResultsDialog extends StatelessWidget {
  final String subject;
  final String language;

  const CourseSearchResultsDialog({
    super.key,
    required this.subject,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final results = _mockResults(subject, language);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E1620),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                subject.isEmpty ? "Sonuçlar" : subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${results.length} kurs/seri bulundu",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final result in results)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${result.providerName} · ${result.format.label} · ${result.level.label}",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${result.price.toStringAsFixed(0)} ${result.currency}",
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                Text(
                                  result.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
