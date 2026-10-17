import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../core/widgets/detail_timeline.dart';
import '../../../../models/cargo.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/cargo_profile_card_view.dart';
import 'profile_detail_common.dart';

const _transitColor = Color(0xFF7FB8D9);

Color _statusColor(ShipmentStatus status) => status == ShipmentStatus.delivered
    ? detailOk
    : (status.isFinal ? Colors.white54 : _transitColor);

/// Kargo modülünün masaüstü detay paneli görünümü: her gönderinin takip
/// geçmişi mobildeki gibi bir alt sayfada değil, doğrudan listede açık.
Widget buildCargoDetail(BuildContext context, CargoProfileCard card) {
  const accent = CargoProfileCardView.moduleAccent;
  final active = card.activeShipments;
  final past = card.pastShipments;

  return DetailPage(
    title: 'Kargo',
    subtitle: '${active.length} devam eden · ${past.length} geçmiş gönderi',
    icon: Icons.local_shipping_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Devam Eden Gönderiler (${active.length})',
        children: [
          if (active.isEmpty) const DetailEmpty('Devam eden gönderi yok'),
          for (final s in active) _shipmentItem(s, accent),
        ],
      ),
      DetailSection(
        title: 'Geçmiş Gönderiler (${past.length})',
        children: [
          if (past.isEmpty) const DetailEmpty('Geçmiş gönderi yok'),
          for (final s in past) _shipmentItem(s, accent),
        ],
      ),
      DetailSection(
        title: 'Favori Kargo Firmaları (${card.favoriteCompanies.length})',
        children: [
          if (card.favoriteCompanies.isEmpty)
            const DetailEmpty('Henüz favori firma eklenmedi'),
          for (final c in card.favoriteCompanies)
            DetailItem(
              accent: accent,
              icon: Icons.local_shipping_outlined,
              title: c.name,
              rows: [
                DetailRow(label: 'Puan', value: '${c.rating.toStringAsFixed(1)} / 5'),
                DetailRow(label: 'Kullanım', value: '${c.timesUsed} kez'),
                if (c.note != null && c.note!.isNotEmpty) DetailParagraph(c.note!),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'Favori Kuryeler (${card.favoriteCouriers.length})',
        children: [
          if (card.favoriteCouriers.isEmpty)
            const DetailEmpty('Henüz favori kurye eklenmedi'),
          for (final c in card.favoriteCouriers)
            DetailItem(
              accent: accent,
              icon: Icons.delivery_dining_outlined,
              title: c.name,
              subtitle: c.company,
              rows: [
                if (c.phone != null && c.phone!.isNotEmpty)
                  DetailRow(label: 'Telefon', value: c.phone!),
                DetailRow(label: 'Puan', value: '${c.rating.toStringAsFixed(1)} / 5'),
                DetailRow(label: 'Kullanım', value: '${c.timesUsed} kez'),
                if (c.note != null && c.note!.isNotEmpty) DetailParagraph(c.note!),
              ],
            ),
        ],
      ),
    ],
  );
}

Widget _shipmentItem(Shipment s, Color accent) {
  final latest = s.latestEvent;
  final events = s.sortedEvents;

  return DetailItem(
    accent: accent,
    icon: s.isOutgoing ? Icons.north_east : Icons.south_west,
    title: s.contentDescription,
    subtitle: '${s.company} · ${s.trackingNumber}',
    badge: DetailBadge(label: s.status.label, color: _statusColor(s.status)),
    rows: [
      DetailRow(label: 'Güzergah', value: '${s.originCity} → ${s.destinationCity}'),
      DetailRow(label: 'Gönderen', value: s.senderName),
      DetailRow(label: 'Alıcı', value: s.receiverName),
      DetailRow(label: 'Oluşturulma', value: formatDate(s.createdDate)),
      if (s.estimatedDeliveryDate != null)
        DetailRow(
            label: 'Tahmini teslimat', value: formatDate(s.estimatedDeliveryDate!)),
      if (latest != null) DetailRow(label: 'Son konum', value: latest.locationLabel),
    ],
    footer: events.isEmpty
        ? const DetailEmpty('Henüz takip kaydı yok')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Takip Geçmişi',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              DetailTimeline(
                accent: accent,
                entries: [
                  for (final e in events)
                    DetailTimelineEntry(
                      title: e.status.label,
                      subtitle: e.locationLabel,
                      caption: e.note != null && e.note!.isNotEmpty
                          ? '${formatDateTime(e.timestamp)} · ${e.note}'
                          : formatDateTime(e.timestamp),
                    ),
                ],
              ),
            ],
          ),
  );
}
