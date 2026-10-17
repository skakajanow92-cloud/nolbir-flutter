import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/detail_kit.dart';
import '../../../../models/estate.dart';
import '../../../../models/feed_card/feed_card.dart';
import '../widgets/estate_profile_card_view.dart';
import 'profile_detail_common.dart';

IconData _propertyIcon(PropertyType type) => switch (type) {
  PropertyType.apartment => Icons.apartment_outlined,
  PropertyType.house => Icons.house_outlined,
  PropertyType.land => Icons.landscape_outlined,
  PropertyType.field => Icons.agriculture_outlined,
  PropertyType.shop => Icons.storefront_outlined,
  PropertyType.office => Icons.business_center_outlined,
  PropertyType.warehouse => Icons.warehouse_outlined,
  PropertyType.parking => Icons.local_parking_outlined,
};

/// Gayrimenkul modülünün masaüstü detay paneli görünümü: her taşınmazın
/// konum, tapu ve değer bilgileri mobildeki alt sayfa yerine doğrudan
/// listede.
Widget buildEstateDetail(BuildContext context, EstateProfileCard card) {
  const accent = EstateProfileCardView.moduleAccent;
  final address = card.registeredAddress;
  final total = card.totalOwnedValue;

  return DetailPage(
    title: 'Gayrimenkul',
    subtitle: total > 0
        ? '${formatMoney(total)} TRY toplam güncel değer (paya düşen)'
        : '${card.properties.length} taşınmaz',
    icon: Icons.home_work_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Özet',
        spacing: 0,
        children: [
          DetailRow(label: 'Taşınmaz', value: '${card.properties.length}'),
          DetailRow(
            label: 'Toplam alan',
            value: '${formatMoney(card.totalArea)} m²',
          ),
          DetailRow(label: 'Kiradaki', value: '${card.rentedCount}'),
          if (card.totalMonthlyRent > 0)
            DetailRow(
              label: 'Aylık kira',
              value: '${formatMoney(card.totalMonthlyRent)} TRY',
            ),
          if (total > 0)
            DetailRow(
              label: 'Toplam değer',
              value: '${formatMoney(total)} TRY',
              emphasize: true,
            ),
        ],
      ),
      if (address != null)
        DetailSection(
          title: 'Kayıtlı İkametgâh',
          children: [
            DetailItem(
              accent: accent,
              icon: Icons.location_on_outlined,
              title: '${address.district} / ${address.city}',
              subtitle: address.oneLine,
              rows: [
                if (address.postalCode != null &&
                    address.postalCode!.isNotEmpty)
                  DetailRow(label: 'Posta kodu', value: address.postalCode!),
              ],
            ),
          ],
        ),
      DetailSection(
        title: 'Taşınmazlarım (${card.properties.length})',
        children: [
          if (card.properties.isEmpty)
            const DetailEmpty('Kayıtlı taşınmaz yok'),
          for (final p in card.properties) _propertyItem(p, accent),
        ],
      ),
    ],
  );
}

Widget _propertyItem(RealEstate p, Color accent) {
  final deed = p.deed;
  final isShared =
      p.ownershipType == OwnershipType.shared && p.sharePercent != null;
  final growth = p.appreciationPercent;

  return DetailItem(
    accent: accent,
    icon: _propertyIcon(p.type),
    title: p.title,
    subtitle: '${p.type.label} · ${p.locationSummary}',
    badge: p.isRentedOut
        ? const DetailBadge(label: 'Kirada', color: detailOk)
        : null,
    rows: [
      _GroupLabel(text: 'Konum', accent: accent),
      DetailRow(label: 'İl / İlçe', value: '${p.district} / ${p.city}'),
      if (p.neighborhood != null && p.neighborhood!.isNotEmpty)
        DetailRow(label: 'Mahalle', value: p.neighborhood!),
      if (p.fullAddress != null && p.fullAddress!.isNotEmpty)
        DetailRow(label: 'Adres', value: p.fullAddress!),
      _GroupLabel(text: 'Tapu Kaydı', accent: accent),
      DetailRow(label: 'Tapu / Yevmiye', value: deed.deedNumber),
      if (deed.parcelSummary.isNotEmpty)
        DetailRow(label: 'Ada / Parsel', value: deed.parcelSummary),
      DetailRow(label: 'Tapu Müdürlüğü', value: deed.landRegistryOffice),
      DetailRow(
        label: 'Tescil tarihi',
        value: formatDate(deed.registrationDate),
      ),
      DetailRow(
        label: 'Mülkiyet',
        value: isShared
            ? '${p.ownershipType.label} (%${p.sharePercent!.toStringAsFixed(0)})'
            : p.ownershipType.label,
      ),
      _GroupLabel(text: 'Değer', accent: accent),
      DetailRow(label: 'Alan', value: '${formatMoney(p.areaSqm)} m²'),
      DetailRow(label: 'Edinme tarihi', value: formatDate(p.acquisitionDate)),
      if (p.acquisitionPrice != null)
        DetailRow(
          label: 'Edinme bedeli',
          value: '${formatMoney(p.acquisitionPrice!)} ${p.currency}',
        ),
      if (p.currentValue != null)
        DetailRow(
          label: 'Güncel değer',
          value: '${formatMoney(p.currentValue!)} ${p.currency}',
          emphasize: true,
        ),
      if (isShared && p.ownedValue != null)
        DetailRow(
          label: 'Paya düşen',
          value: '${formatMoney(p.ownedValue!)} ${p.currency}',
        ),
      if (growth != null)
        DetailRow(
          label: 'Değer değişimi',
          value:
              '${growth >= 0 ? '+' : '-'}%${growth.abs().toStringAsFixed(1)}',
        ),
      if (p.isRentedOut && p.monthlyRent != null)
        DetailRow(
          label: 'Aylık kira',
          value: '${formatMoney(p.monthlyRent!)} ${p.currency}',
        ),
    ],
  );
}

class _GroupLabel extends StatelessWidget {
  final String text;
  final Color accent;

  const _GroupLabel({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Color.lerp(accent, Colors.white, 0.55) ?? accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
