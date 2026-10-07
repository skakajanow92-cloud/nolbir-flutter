import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/pharmacy_cart.dart';

/// İlaç Sepeti Kartı — Sepet Kartları ailesinin yedinci üyesi.
///
/// TASARIM NOTU: Diğer sepet kartlarıyla AYNI görsel dili paylaşıyor ama
/// üç noktada kasıtlı olarak farklı: (1) reçeteli kalemler reçete
/// numarasına ve İZİN VERİLEN adede bağlı, (2) her reçeteli kalem,
/// dijital imzalı bir `DigitalPrescription`a dokunarak doğrulanabiliyor
/// (bkz. `PrescriptionDetailSheet`), (3) fiyat karşılaştırması lisanslı
/// eczaneler arasında ve SADECE aynı ilaç için — klinik bir ikame önerisi
/// değil. Öneri bölümü de bilerek sadece reçetesiz (OTC) ürünleri kapsar.
///
/// Modül vurgu rengi: nane yeşili — Otel modülünün adaçayından
/// (0xFF7FA88A) ve Spor modülünün çim yeşilinden (0xFF5AA33A) ayrışan,
/// "sağlık/eczane" hissi veren daha saf bir yeşil.
class PharmacyCartCardView extends StatelessWidget {
  final PharmacyCartCard card;

  const PharmacyCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF3EA876);
  static const _base = Color(0xFF0B1511);
  static const _baseEnd = Color(0xFF121E18);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final prescriptionItems = card.prescriptionItems;
    final otcItems = card.otcItems;
    final expiring = card.expiringPrescriptions;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(card: card),
                ),
                if (expiring.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _ExpiryBanner(prescription: expiring.first),
                  ),
                ],
                const SizedBox(height: 20),
                _SectionLabel(
                  text: "Reçeteli İlaçlarım (${prescriptionItems.length})",
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: prescriptionItems.isEmpty
                      ? const Text(
                          "Reçeteli ilaç yok",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Column(
                          children: prescriptionItems
                              .map(
                                (item) =>
                                    _PharmacyItemRow(item: item, card: card),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Reçetesiz Ürünlerim (${otcItems.length})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: otcItems.isEmpty
                      ? const Text(
                          "Reçetesiz ürün yok",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Column(
                          children: otcItems
                              .map(
                                (item) =>
                                    _PharmacyItemRow(item: item, card: card),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text:
                      "Fiyat Karşılaştırması (${card.priceComparisons.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 148,
                  child: card.priceComparisons.isEmpty
                      ? const _EmptyHint(text: "Karşılaştırma için ürün yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.priceComparisons.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) => _ComparisonMiniCard(
                            group: card.priceComparisons[i],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Önerilen Ürünler (${card.recommendations.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 148,
                  child: card.recommendations.isEmpty
                      ? const _EmptyHint(text: "Henüz öneri yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.recommendations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _RecommendationMiniCard(
                            product: card.recommendations[i],
                          ),
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
  final PharmacyCartCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.local_pharmacy_outlined,
              color: PharmacyCartCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "İlaç Sepeti",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(card.cart.subtotal)} TRY",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "${card.prescriptionItems.length} reçeteli · ${card.otcItems.length} reçetesiz",
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }
}

class _ExpiryBanner extends StatelessWidget {
  final DigitalPrescription prescription;
  const _ExpiryBanner({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final days = prescription.expiryDate.difference(DateTime.now()).inDays;
    final whenText = days <= 0 ? "Bugün" : "$days gün içinde";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0A030).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE0A030).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            color: Color(0xFFE0A030),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$whenText: ${prescription.prescriptionNumber} numaralı reçetenin süresi doluyor",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
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
        child: Text(
          text,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PharmacyItemRow extends StatelessWidget {
  final CartItem item;
  final PharmacyCartCard card;
  const _PharmacyItemRow({required this.item, required this.card});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(item.pharmacyName);
    final prescription = card.prescriptionFor(item);

    return GestureDetector(
      onTap: item.requiresPrescription && prescription != null
          ? () => _openDetail(context, prescription)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.requiresPrescription
                    ? Icons.medication_outlined
                    : Icons.healing_outlined,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.pharmacyLicenseNumber != null
                        ? "${item.pharmacyName} · Ruhsat No: ${item.pharmacyLicenseNumber}"
                        : item.pharmacyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (item.requiresPrescription)
                        _Chip(
                          text: item.prescriptionNumber != null
                              ? "Reçete: ${item.prescriptionNumber}"
                              : "Reçeteli",
                          color: PharmacyCartCardView.moduleAccent,
                        )
                      else
                        const _Chip(text: "Reçetesiz", color: Colors.white54),
                      if (item.prescribedQuantity != null)
                        _Chip(
                          text:
                              "${item.quantity}/${item.prescribedQuantity} adet",
                          color: Colors.white54,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${_formatMoney(item.lineTotal)} ${item.currency}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.requiresPrescription && prescription != null)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white24,
                    size: 18,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, DigitalPrescription prescription) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121E18),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          PrescriptionDetailSheet(prescription: prescription, card: card),
    );
  }
}

/// Reçeteli kaleme dokununca açılan, dijital reçetenin doğrulama
/// bilgilerini ve reçeteye bağlı tüm kalemleri gösteren detay sheet
/// (bkz. InsuranceProfileCardView'daki PolicyDetailSheet presedanı).
class PrescriptionDetailSheet extends StatelessWidget {
  final DigitalPrescription prescription;
  final PharmacyCartCard card;
  const PrescriptionDetailSheet({
    super.key,
    required this.prescription,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final items = card.cart.items
        .where((i) => i.prescriptionNumber == prescription.prescriptionNumber)
        .toList();

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
                  child: Text(
                    "Reçete ${prescription.prescriptionNumber}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            _StatusLine(status: prescription.status),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Doğrulama"),
            _DetailRow(label: "Doktor", value: prescription.doctorName),
            if (prescription.doctorSpecialty != null)
              _DetailRow(label: "Branş", value: prescription.doctorSpecialty!),
            _DetailRow(
              label: "Sağlık Kurumu",
              value: prescription.healthInstitution,
            ),
            _DetailRow(
              label: "Dijital İmza Ref.",
              value: prescription.digitalSignatureRef,
            ),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Geçerlilik"),
            _DetailRow(
              label: "Düzenlenme",
              value: _formatDate(prescription.issuedDate),
            ),
            _DetailRow(
              label: "Son Geçerlilik",
              value: _formatDate(prescription.expiryDate),
            ),
            const SizedBox(height: 16),
            const _GroupLabel(text: "Reçetedeki Ürünler"),
            ...items.map(
              (i) => _DetailRow(
                label: i.title,
                value: i.prescribedQuantity != null
                    ? "${i.quantity}/${i.prescribedQuantity} adet"
                    : "${i.quantity} adet",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final PrescriptionStatus status;
  const _StatusLine({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PrescriptionStatus.active => const Color(0xFF7FD98A),
      PrescriptionStatus.partiallyFilled => const Color(0xFFE0A030),
      PrescriptionStatus.fullyFilled => Colors.white54,
      PrescriptionStatus.expired => const Color(0xFFD98A7F),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: _Chip(text: status.label, color: color),
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
      child: Text(
        text,
        style: const TextStyle(
          color: PharmacyCartCardView.moduleAccent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonMiniCard extends StatelessWidget {
  final MedicineComparisonGroup group;
  const _ComparisonMiniCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(group.medicineName);
    final cheapest = group.cheapestOffer;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.medicineName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (group.requiresPrescription)
              const _Chip(
                text: "Reçeteli",
                color: PharmacyCartCardView.moduleAccent,
              ),
            const Spacer(),
            if (cheapest != null) ...[
              Text(
                "${_formatMoney(cheapest.price)} ${cheapest.currency}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "en ucuz: ${cheapest.pharmacyName}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else
              const Text(
                "Stokta teklif yok",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(
              "${group.offers.length} eczanede",
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121E18),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MedicineComparisonSheet(group: group),
    );
  }
}

/// Karşılaştırma mini kartına dokununca açılan tüm eczane tekliflerinin
/// listesi — her teklif kendi ruhsat/ülke bilgisini gösterir.
class MedicineComparisonSheet extends StatelessWidget {
  final MedicineComparisonGroup group;
  const MedicineComparisonSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final offers = group.sortedByPrice;
    final cheapestId = group.cheapestOffer?.id;

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
                  child: Text(
                    group.medicineName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            if (group.requiresPrescription)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: _Chip(
                  text: "Reçeteli",
                  color: PharmacyCartCardView.moduleAccent,
                ),
              ),
            const SizedBox(height: 16),
            ...offers.map(
              (o) => _OfferRow(offer: o, isCheapest: o.id == cheapestId),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final PharmacyOffer offer;
  final bool isCheapest;
  const _OfferRow({required this.offer, required this.isCheapest});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: offer.inStock ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          offer.pharmacyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isCheapest && offer.inStock) ...[
                        const SizedBox(width: 8),
                        const _Chip(text: "En Ucuz", color: Color(0xFF7FD98A)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Ruhsat: ${offer.licenseNumber} · ${offer.country}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!offer.inStock)
              const Text(
                "Stokta yok",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              )
            else
              Text(
                "${_formatMoney(offer.price)} ${offer.currency}",
                style: TextStyle(
                  color: isCheapest ? const Color(0xFF7FD98A) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationMiniCard extends StatelessWidget {
  final RecommendedPharmacyProduct product;
  const _RecommendationMiniCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(product.pharmacyName);

    return Container(
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Chip(text: product.category.label, color: color),
          const SizedBox(height: 8),
          Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            "${_formatMoney(product.price)} ${product.currency}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            product.pharmacyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// Eczane/ilaç adı başına sabit, elle seçilmiş uyumlu bir palet (bkz.
// diğer modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF1F5A41),
  Color(0xFF3E4A5A),
  Color(0xFF5A4A2E),
  Color(0xFF4A2E45),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
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
