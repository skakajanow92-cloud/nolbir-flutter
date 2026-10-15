import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/accommodation.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/accommodation_profile_card_view.dart';

/// Konaklama modülünün masaüstü detay paneli görünümü: oda tipi, onay no, süre, ücret.
Widget _stayItem(AccommodationReservation r, Color accent) {
  return DetailItem(
    accent: accent,
    icon: Icons.king_bed_outlined,
    title: r.hotelName,
    subtitle: r.location,
    rows: [
      DetailRow(label: 'Oda', value: r.roomType),
      DetailRow(label: 'Giriş', value: formatDate(r.checkIn)),
      DetailRow(label: 'Çıkış', value: formatDate(r.checkOut)),
      DetailRow(
          label: 'Süre', value: '${r.nights} gece · ${r.guestCount} misafir'),
      DetailRow(label: 'Onay No', value: r.confirmationNumber),
      DetailRow(
        label: 'Ücret',
        value: '${formatMoney(r.price)} ${r.currency}',
        emphasize: true,
      ),
    ],
  );
}

Widget buildAccommodationDetail(BuildContext context, AccommodationProfileCard card) {
  const accent = AccommodationProfileCardView.moduleAccent;
  final upcoming = card.upcoming;
  final past = card.past;
  return DetailPage(
    title: 'Konaklama',
    subtitle: '${upcoming.length} yaklaşan · ${past.length} geçmiş rezervasyon',
    icon: Icons.hotel_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Yaklaşan Rezervasyonlar (${upcoming.length})',
        children: [
          if (upcoming.isEmpty) const DetailEmpty('Yaklaşan rezervasyon yok'),
          for (final r in upcoming) _stayItem(r, accent),
        ],
      ),
      DetailSection(
        title: 'Geçmiş Rezervasyonlar (${past.length})',
        children: [
          if (past.isEmpty) const DetailEmpty('Geçmiş rezervasyon yok'),
          for (final r in past) _stayItem(r, accent),
        ],
      ),
    ],
  );
}
