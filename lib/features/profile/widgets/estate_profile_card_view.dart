import 'package:flutter/material.dart';
import 'package:nolbir/core/widgets/page_aware_scroll_view.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/estate.dart';

/// Gayrimenkul Profili — on altinci profil modülü.
///
/// TASARIM NOTU: Taşınmaz mini kartına dokununca tapu detayları
/// (ada/parsel/yevmiye/tescil tarihi) bir detay sheet'te açılıyor —
/// Insurance modülündeki `PolicyDetailSheet` ve Channels modülündeki
/// `ChannelDetailSheet` presedanıyla aynı mantık. Tapu bilgileri mini
/// kartta gösterilmiyor, çünkü kart yüzeyi özet için; resmi kayıt
/// detayı istendiğinde açılıyor.
///
/// Modül vurgu rengi: toprak bronzu — Seyahat modülünün turuncu
/// amberinden (0xFFA85A2A) ayrışan, daha "toprak/mülk" hissi veren ton.
class EstateProfileCardView extends StatelessWidget {
  final EstateProfileCard card;

  const EstateProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF7A5A3A);
  static const _base = Color(0xFF13110D);
  static const _baseEnd = Color(0xFF1C1813);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final address = card.registeredAddress;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: SafeArea(
          child: PageAwareScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(card: card),
                ),
                if (address != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _AddressBanner(address: address),
                  ),
                ],
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _StatsRow(card: card),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Taşınmazlarım (${card.properties.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 196,
                  child: card.properties.isEmpty
                      ? const _EmptyHint(text: "Kayıtlı taşınmaz yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.properties.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) =>
                              _PropertyMiniCard(property: card.properties[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final EstateProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    final total = card.totalOwnedValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.home_work_outlined,
                color: EstateProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Gayrimenkul",
                style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          total > 0 ? "${_formatMoney(total)} TRY" : "${card.properties.length} taşınmaz",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        if (total > 0) ...[
          const SizedBox(height: 2),
          const Text("toplam güncel değer (paya düşen)",
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ],
    );
  }
}

class _AddressBanner extends StatelessWidget {
  final RegisteredAddress address;
  const _AddressBanner({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EstateProfileCardView.moduleAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: EstateProfileCardView.moduleAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.place_outlined,
              color: EstateProfileCardView.moduleAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Kayıtlı Adres",
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 2),
                Text(address.oneLine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final EstateProfileCard card;
  const _StatsRow({required this.card});

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String)>[
      ("Taşınmaz", "${card.properties.length}"),
      ("Toplam Alan", "${_formatMoney(card.totalArea)} m²"),
      ("Kirada", "${card.rentedCount}"),
      ("Aylık Kira", _formatMoney(card.totalMonthlyRent)),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: stats.map((s) => _StatChip(label: s.$1, value: s.$2)).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: EstateProfileCardView.moduleAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: EstateProfileCardView.moduleAccent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      ),
    );
  }
}

class _PropertyMiniCard extends StatelessWidget {
  final RealEstate property;
  const _PropertyMiniCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final color = _propertyColor(property.title);

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFor(property.type), color: color, size: 17),
                const SizedBox(width: 6),
                Text(property.type.label,
                    style: TextStyle(
                        color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (property.isRentedOut) const _RentedBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(property.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(property.locationSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              "${_formatMoney(property.areaSqm)} m² · ${property.ownershipType.label}"
              "${property.ownershipType == OwnershipType.shared && property.sharePercent != null ? ' (%${property.sharePercent!.toStringAsFixed(0)})' : ''}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const Spacer(),
            if (property.currentValue != null)
              Text(
                "${_formatMoney(property.currentValue!)} ${property.currency}",
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            if (property.appreciationPercent != null)
              Text(
                "${property.appreciationPercent! >= 0 ? '+' : ''}"
                "%${property.appreciationPercent!.toStringAsFixed(0)} edinme bedeline göre",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: property.appreciationPercent! >= 0
                        ? const Color(0xFF7FD98A)
                        : const Color(0xFFD98A7F),
                    fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1813),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PropertyDetailSheet(property: property),
    );
  }
}

class _RentedBadge extends StatelessWidget {
  const _RentedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF7FD98A).withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text("Kirada",
          style: TextStyle(
              color: Color(0xFF7FD98A), fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

/// Taşınmaz mini kartına dokununca açılan tam detay — tapu kaydı ve
/// edinme/değer bilgileri (bkz. InsuranceProfileCardView'daki
/// PolicyDetailSheet presedanı).
class PropertyDetailSheet extends StatelessWidget {
  final RealEstate property;
  const PropertyDetailSheet({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final deed = property.deed;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(property.title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Row(
              children: [
                Icon(_iconFor(property.type),
                    color: EstateProfileCardView.moduleAccent, size: 16),
                const SizedBox(width: 6),
                Text(property.type.label,
                    style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),
            const _GroupLabel(text: "Konum"),
            _DetailRow(label: "İl / İlçe", value: "${property.district} / ${property.city}"),
            if (property.neighborhood != null)
              _DetailRow(label: "Mahalle", value: property.neighborhood!),
            if (property.fullAddress != null)
              _DetailRow(label: "Adres", value: property.fullAddress!),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Tapu Kaydı"),
            _DetailRow(label: "Tapu / Yevmiye No", value: deed.deedNumber),
            if (deed.parcelSummary.isNotEmpty)
              _DetailRow(label: "Ada / Parsel", value: deed.parcelSummary),
            _DetailRow(label: "Tapu Müdürlüğü", value: deed.landRegistryOffice),
            _DetailRow(label: "Tescil Tarihi", value: _formatDate(deed.registrationDate)),
            _DetailRow(
              label: "Mülkiyet",
              value: property.ownershipType == OwnershipType.shared &&
                      property.sharePercent != null
                  ? "${property.ownershipType.label} (%${property.sharePercent!.toStringAsFixed(0)})"
                  : property.ownershipType.label,
            ),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Değer"),
            _DetailRow(label: "Alan", value: "${_formatMoney(property.areaSqm)} m²"),
            _DetailRow(
                label: "Edinme Tarihi", value: _formatDate(property.acquisitionDate)),
            if (property.acquisitionPrice != null)
              _DetailRow(
                  label: "Edinme Bedeli",
                  value:
                      "${_formatMoney(property.acquisitionPrice!)} ${property.currency}"),
            if (property.currentValue != null)
              _DetailRow(
                  label: "Güncel Değer",
                  value: "${_formatMoney(property.currentValue!)} ${property.currency}"),
            if (property.isRentedOut && property.monthlyRent != null)
              _DetailRow(
                  label: "Aylık Kira",
                  value: "${_formatMoney(property.monthlyRent!)} ${property.currency}"),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text,
          style: const TextStyle(
              color: EstateProfileCardView.moduleAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(PropertyType type) => switch (type) {
      PropertyType.apartment => Icons.apartment_outlined,
      PropertyType.house => Icons.house_outlined,
      PropertyType.land => Icons.landscape_outlined,
      PropertyType.field => Icons.agriculture_outlined,
      PropertyType.shop => Icons.storefront_outlined,
      PropertyType.office => Icons.business_center_outlined,
      PropertyType.warehouse => Icons.warehouse_outlined,
      PropertyType.parking => Icons.local_parking_outlined,
    };

// Taşınmaz başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _propertyPalette = <Color>[
  Color(0xFF5A4A2E),
  Color(0xFF3E4A5A),
  Color(0xFF4A5A3E),
  Color(0xFF5A3E3E),
];

Color _propertyColor(String seed) {
  final index = seed.hashCode.abs() % _propertyPalette.length;
  return _propertyPalette[index];
}

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
