import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../../../../models/travel.dart';
import '../widgets/travel_profile_card_view.dart';

/// Seyahat modülünün masaüstü detay paneli görünümü: bilet no, koltuk, varış saati, ücret.
IconData _transportIcon(TransportType type) => switch (type) {
  TransportType.flight => Icons.flight_takeoff,
  TransportType.bus => Icons.directions_bus_outlined,
  TransportType.train => Icons.train_outlined,
  TransportType.ferry => Icons.directions_boat_outlined,
};

Widget _ticketItem(TravelTicket t, Color accent) {
  return DetailItem(
    accent: accent,
    icon: _transportIcon(t.transportType),
    title: '${t.origin} → ${t.destination}',
    subtitle: '${t.company} · ${t.transportType.label}',
    rows: [
      DetailRow(label: 'Kalkış', value: formatDateTime(t.departureDateTime)),
      if (t.arrivalDateTime != null)
        DetailRow(label: 'Varış', value: formatDateTime(t.arrivalDateTime!)),
      DetailRow(label: 'Bilet No', value: t.ticketNumber),
      if (t.seatNumber != null)
        DetailRow(label: 'Koltuk', value: t.seatNumber!),
      DetailRow(
        label: 'Ücret',
        value: '${formatMoney(t.price, decimals: 2)} ${t.currency}',
        emphasize: true,
      ),
    ],
  );
}

Widget buildTravelDetail(BuildContext context, TravelProfileCard card) {
  const accent = TravelProfileCardView.moduleAccent;
  final upcoming = card.upcoming;
  final past = card.past;
  return DetailPage(
    title: 'Seyahat',
    subtitle: '${upcoming.length} yaklaşan · ${past.length} geçmiş yolculuk',
    icon: Icons.explore_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Yaklaşan Yolculuklar (${upcoming.length})',
        children: [
          if (upcoming.isEmpty) const DetailEmpty('Yaklaşan yolculuk yok'),
          for (final t in upcoming) _ticketItem(t, accent),
        ],
      ),
      DetailSection(
        title: 'Geçmiş Yolculuklar (${past.length})',
        children: [
          if (past.isEmpty) const DetailEmpty('Geçmiş yolculuk yok'),
          for (final t in past) _ticketItem(t, accent),
        ],
      ),
    ],
  );
}
