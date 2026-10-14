import 'package:flutter/material.dart';
import '../../../models/cart_card/cart_card.dart';
import '../../../models/cart.dart';
import '../../../models/hosting.dart';
import '../../../models/hosting_cart.dart';

/// Hosting Sepeti Kartı — Sepet Kartları ailesinin dokuzuncu üyesi.
///
/// TASARIM NOTU: Kalemler hosting firmasına göre gruplanıyor çünkü her
/// firma ayrı faturalandırıyor — grup başlığında o firmanın ilk ödeme
/// toplamı görünüyor (dönem fiyatı + kurulum ücreti). Fiyat
/// karşılaştırması farklı fatura dönemlerini aylık karşılığa
/// normalize ederek yapılıyor ve en ucuz teklifle birlikte en yüksek
/// uptime SLA'lı teklifi de işaretliyor.
///
/// NOT: Tüm kalemlerin TRY olduğu varsayılıyor (bkz. Cüzdan/Gayrimenkul
/// modüllerindeki aynı not) — çoklu para birimi backend adımında.
///
/// Modül vurgu rengi: elektrik indigosu — Hosting profil modülünün
/// mor-gri tonundan (0xFF52466B) ve Market Sepeti'nin kobaltından
/// (0xFF3D6FD1) ayrışan, daha canlı bir "teknoloji" tonu.
class HostingCartCardView extends StatelessWidget {
  final HostingCartCard card;

  const HostingCartCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF6C63D9);
  static const _base = Color(0xFF0E0D16);
  static const _baseEnd = Color(0xFF161524);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cart = card.cart;
    final grouped = card.itemsByProvider;

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
                  child: _Header(card: card, providerCount: grouped.length),
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: "Paketlerim (${cart.items.length})"),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: cart.items.isEmpty
                      ? const Text(
                          "Sepetiniz boş",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Column(
                          children: grouped.entries
                              .map(
                                (e) => _ProviderGroup(
                                  provider: e.key,
                                  items: e.value,
                                ),
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
                  height: 168,
                  child: card.priceComparisons.isEmpty
                      ? const _EmptyHint(text: "Karşılaştırma için paket yok")
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
                  text: "Ek Hizmet Önerileri (${card.addOns.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 148,
                  child: card.addOns.isEmpty
                      ? const _EmptyHint(text: "Henüz öneri yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.addOns.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _AddOnMiniCard(addOn: card.addOns[i]),
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
  final HostingCartCard card;
  final int providerCount;
  const _Header({required this.card, required this.providerCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.cloud_outlined,
              color: HostingCartCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Hosting Sepeti",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(card.totalFirstPayment)} TRY",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "ilk ödeme toplamı · ${card.cart.items.length} paket"
          "${providerCount > 1 ? ' · $providerCount firmadan' : ''}",
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          "aylık karşılık ≈ ${_formatMoney(card.totalMonthlyEquivalent)} TRY",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
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

class _ProviderGroup extends StatelessWidget {
  final String provider;
  final List<CartItem> items;
  const _ProviderGroup({required this.provider, required this.items});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(provider);
    final subtotal = items.fold(0.0, (sum, i) => sum + i.hostingFirstPayment);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_outlined, color: color, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  provider,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                "ilk ödeme: ${_formatMoney(subtotal)} TRY",
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _PlanRow(item: item, color: color)),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final CartItem item;
  final Color color;
  const _PlanRow({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    final setupFee = item.hostingSetupFee;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                _iconFor(item.hostingPlanKind),
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.hostingPlanName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item.hostingPlanKind.label,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  if (item.hostingSpecSummary.isNotEmpty)
                    Text(
                      item.hostingSpecSummary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (item.hostingDatacenter != null)
                        _Chip(
                          text: item.hostingDatacenter!,
                          color: Colors.white54,
                        ),
                      if (item.hostingControlPanel != null)
                        _Chip(
                          text: item.hostingControlPanel!,
                          color: Colors.white54,
                        ),
                      if (item.hostingUptimeSla != null)
                        _Chip(
                          text:
                              "%${item.hostingUptimeSla!.toStringAsFixed(2)} uptime",
                          color: const Color(0xFF7FD98A),
                        ),
                      if (setupFee != null && setupFee > 0)
                        _Chip(
                          text: "Kurulum ${_formatMoney(setupFee)} TRY",
                          color: const Color(0xFFE0A030),
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
                Text(
                  item.hostingBillingCycle.label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
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

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161524),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => HostingPlanDetailSheet(item: item),
    );
  }
}

/// Paket kalemine dokununca açılan detay: tüm özellikler, kapsam ve ödeme
/// dökümü (bkz. diğer modüllerdeki detay sheet presedanı).
class HostingPlanDetailSheet extends StatelessWidget {
  final CartItem item;
  const HostingPlanDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final setupFee = item.hostingSetupFee;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.hostingPlanName,
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
              Text(
                "${item.hostingProvider} · ${item.hostingPlanKind.label}",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const _GroupLabel(text: "Özellikler"),
              if (item.hostingCpuCores != null)
                _DetailRow(
                  label: "İşlemci",
                  value: "${item.hostingCpuCores} vCPU",
                ),
              if (item.hostingRamGb != null)
                _DetailRow(
                  label: "Bellek",
                  value: "${item.hostingRamGb} GB RAM",
                ),
              if (item.hostingDiskGb != null)
                _DetailRow(label: "Disk", value: "${item.hostingDiskGb} GB"),
              _DetailRow(
                label: "Trafik",
                value: item.hostingUnlimitedBandwidth
                    ? "Sınırsız"
                    : (item.hostingBandwidthGb != null
                          ? "${item.hostingBandwidthGb} GB"
                          : "Belirtilmemiş"),
              ),
              if (item.hostingDatacenter != null)
                _DetailRow(
                  label: "Veri Merkezi",
                  value: item.hostingDatacenter!,
                ),
              if (item.hostingOs != null)
                _DetailRow(label: "İşletim Sistemi", value: item.hostingOs!),
              if (item.hostingControlPanel != null)
                _DetailRow(
                  label: "Kontrol Paneli",
                  value: item.hostingControlPanel!,
                ),
              if (item.hostingUptimeSla != null)
                _DetailRow(
                  label: "Uptime SLA",
                  value: "%${item.hostingUptimeSla!.toStringAsFixed(2)}",
                ),
              if (item.hostingFeatures.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _GroupLabel(text: "Kapsam"),
                ...item.hostingFeatures.map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 15,
                          color: Color(0xFF7FD98A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const _GroupLabel(text: "Ödeme"),
              _DetailRow(
                label: "${item.hostingBillingCycle.label} Fiyat",
                value: "${_formatMoney(item.lineTotal)} ${item.currency}",
              ),
              if (setupFee != null && setupFee > 0)
                _DetailRow(
                  label: "Kurulum Ücreti",
                  value:
                      "${_formatMoney(setupFee * item.quantity)} ${item.currency}",
                ),
              _DetailRow(
                label: "İlk Ödeme",
                value:
                    "${_formatMoney(item.hostingFirstPayment)} ${item.currency}",
              ),
              _DetailRow(
                label: "Aylık Karşılık",
                value:
                    "≈ ${_formatMoney(item.hostingLineMonthlyEquivalent)} ${item.currency}",
              ),
            ],
          ),
        );
      },
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
          color: HostingCartCardView.moduleAccent,
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
  final HostingPlanComparisonGroup group;
  const _ComparisonMiniCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(group.title);
    final cheapest = group.cheapestOffer;
    final topUptime = group.highestUptimeOffer;
    final savings = group.savingsPercentVsHighest;
    final showUptimeLine =
        topUptime != null && cheapest != null && topUptime.id != cheapest.id;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 215,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              group.planKind.label,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const Spacer(),
            if (cheapest != null) ...[
              Text(
                "${_formatMoney(cheapest.monthlyEquivalent)} ${cheapest.currency} / ay",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "en ucuz: ${cheapest.provider}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (savings != null && savings > 0)
                Text(
                  "%${savings.toStringAsFixed(0)} tasarruf",
                  style: const TextStyle(
                    color: Color(0xFF7FD98A),
                    fontSize: 11,
                  ),
                ),
              if (showUptimeLine)
                Text(
                  "en yüksek uptime: ${topUptime.provider} (%${topUptime.uptimeSla!.toStringAsFixed(2)})",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
            ] else
              const Text(
                "Müsait teklif yok",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(
              "${group.offers.length} firmada",
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
      backgroundColor: const Color(0xFF161524),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => HostingComparisonSheet(group: group),
    );
  }
}

/// Karşılaştırma mini kartına dokununca açılan tüm firma tekliflerinin
/// listesi — aylık karşılığa göre sıralı.
class HostingComparisonSheet extends StatelessWidget {
  final HostingPlanComparisonGroup group;
  const HostingComparisonSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final offers = group.sortedByMonthly;
    final cheapestId = group.cheapestOffer?.id;
    final uptimeId = group.highestUptimeOffer?.id;

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
                    group.title,
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
            const Text(
              "Fiyatlar farklı fatura dönemleri için aylık karşılığa çevrilerek sıralanır",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ...offers.map(
              (o) => _OfferRow(
                offer: o,
                isCheapest: o.id == cheapestId,
                isTopUptime: o.id == uptimeId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final HostingPlanOffer offer;
  final bool isCheapest;
  final bool isTopUptime;
  const _OfferRow({
    required this.offer,
    required this.isCheapest,
    required this.isTopUptime,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: offer.isAvailable ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${offer.provider} · ${offer.planName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (isCheapest && offer.isAvailable)
                        const _Chip(text: "En Ucuz", color: Color(0xFF7FD98A)),
                      if (isTopUptime && offer.isAvailable)
                        const _Chip(
                          text: "En Yüksek Uptime",
                          color: Color(0xFF7FD98A),
                        ),
                      if (offer.uptimeSla != null)
                        _Chip(
                          text: "%${offer.uptimeSla!.toStringAsFixed(2)} SLA",
                          color: Colors.white54,
                        ),
                      if (offer.datacenter != null)
                        _Chip(text: offer.datacenter!, color: Colors.white54),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!offer.isAvailable)
              const Text(
                "Müsait değil",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${_formatMoney(offer.monthlyEquivalent)} / ay",
                    style: TextStyle(
                      color: isCheapest
                          ? const Color(0xFF7FD98A)
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "${_formatMoney(offer.price)} ${offer.currency} · ${offer.billingCycle.label}",
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AddOnMiniCard extends StatelessWidget {
  final RecommendedHostingAddOn addOn;
  const _AddOnMiniCard({required this.addOn});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(addOn.provider);

    return Container(
      width: 178,
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
              Icon(_iconForAddOn(addOn.kind), size: 14, color: color),
              const SizedBox(width: 6),
              _Chip(text: addOn.kind.label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            addOn.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (addOn.relatedPlanName != null)
            Text(
              addOn.relatedPlanName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          const Spacer(),
          Text(
            "${_formatMoney(addOn.price)} ${addOn.currency} / ${addOn.billingCycle.label}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            addOn.provider,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(HostingPlanKind kind) => switch (kind) {
  HostingPlanKind.shared => Icons.cloud_outlined,
  HostingPlanKind.vps => Icons.dns_outlined,
  HostingPlanKind.vds => Icons.storage_outlined,
  HostingPlanKind.dedicated => Icons.memory_outlined,
};

IconData _iconForAddOn(HostingAddOnKind kind) => switch (kind) {
  HostingAddOnKind.domain => Icons.language_outlined,
  HostingAddOnKind.ssl => Icons.lock_outline,
  HostingAddOnKind.backup => Icons.backup_outlined,
  HostingAddOnKind.cdn => Icons.public_outlined,
  HostingAddOnKind.monitoring => Icons.monitor_heart_outlined,
};

// Firma/plan adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF3E3A6E),
  Color(0xFF3E4A5A),
  Color(0xFF4A3E5A),
  Color(0xFF2E4A5A),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
