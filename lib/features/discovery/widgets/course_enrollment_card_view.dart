import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../collection/widgets/save_to_collection_button.dart';
import 'ecommerce_shared_widgets.dart';

class CourseEnrollmentCardView extends StatelessWidget {
  final CourseEnrollmentCard card;

  const CourseEnrollmentCardView({super.key, required this.card});

  static const _base = Color(0xFF0E1620);
  static const _baseEnd = Color(0xFF152030);
  static const accent = Color(0xFF3FA6E0);

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(card: card),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageGallery(imageUrls: card.imageUrls),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.courseTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                PriceRow(
                  price: card.price,
                  discountedPrice: card.discountedPrice,
                  currency: card.currency,
                  accentColor: accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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
              children: [
                AttributeBadge(
                  text: card.format.label,
                  accentColor: accent,
                  icon: Icons.school_outlined,
                ),
                AttributeBadge(
                  text: card.language,
                  accentColor: accent,
                  icon: Icons.language,
                ),
                AttributeBadge(text: card.level.label, accentColor: accent),
                if (card.format != CourseFormat.online &&
                    card.district != null &&
                    card.country != null)
                  AttributeBadge(
                    text: "${card.district}, ${card.country}",
                    accentColor: accent,
                    icon: Icons.location_on_outlined,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sezon: ${_formatDate(card.seasonStart)} - ${_formatDate(card.seasonEnd)}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  "Son kayıt: ${_formatDate(card.enrollmentDeadline)}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                if (card.seatsTotal > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (card.seatsTaken / card.seatsTotal).clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(
                        card.isFull ? Colors.redAccent : accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.isFull
                        ? "Kontenjan doldu"
                        : "${card.seatsAvailable} kontenjan kaldı",
                    style: TextStyle(
                      color: card.isFull ? Colors.redAccent : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: card.isFull ? Colors.white24 : accent,
                    ),
                    onPressed: card.isFull
                        ? null
                        : () {
                            // NOT: Gerçek kayıt/ödeme akışı backend
                            // bağlanınca eklenecek — şimdilik mock onay.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${card.courseTitle} kursuna kayıt (mock)",
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                    child: Text(card.isFull ? "Kontenjan Doldu" : "Kaydol"),
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
  final CourseEnrollmentCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StoreLogo(logoUrl: card.providerLogoUrl, name: card.providerName),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.providerName,
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
                card.isSchool ? "Okul" : "Bağımsız Öğretmen",
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
