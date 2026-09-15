import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/streaming.dart';

/// Yayın Abonelikleri Profili — on ikinci profil modülü.
///
/// TASARIM NOTU: Diğer modüllerin çoğu tek seviyeli bir liste gösteriyor
/// (hesaplar, poliçeler, biletler...). Burada hiyerarşi İKİ seviyeli:
/// her ŞİRKET kendi başlığıyla bir bölüm açıyor, o bölümün içinde o
/// şirketten alınan PAKETLER yatay kaydırmalı duruyor. Böylece "aynı
/// şirketin birden fazla paketi" durumu görsel olarak da doğru okunuyor.
///
/// !!! DEĞİŞTİRİLECEK NOKTA: Aşağıdaki `SingleChildScrollView`'ı senin
/// PageAware sarmalayıcınla değiştir — o widget'ın kaynağı bende olmadığı
/// için buraya standart haliyle yazıldı. Tek satırlık bir değişiklik.
class StreamingProfileCardView extends StatelessWidget {
  final StreamingProfileCard card;

  const StreamingProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF5A3D8A);
  static const _base = Color(0xFF110E16);
  static const _baseEnd = Color(0xFF1A1622);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final alert = card.nextRenewalAlert;

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
          // <<< PageAware sarmalayıcını buraya koy
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
                if (alert != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _RenewalAlert(package: alert),
                  ),
                ],
                const SizedBox(height: 24),
                if (card.providers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Henüz bir yayın aboneliğin yok",
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                  )
                else
                  for (final provider in card.providers) ...[
                    _ProviderSection(provider: provider),
                    const SizedBox(height: 22),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final StreamingProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.subscriptions_outlined,
                color: StreamingProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Yayın Abonelikleri",
                style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(card.totalMonthlyCost)} TRY",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.1),
        ),
        const SizedBox(height: 2),
        Text(
          "aylık toplam · ${card.providers.length} şirket · "
          "${card.activePackageCount} paket · ${card.totalChannelCount} kanal",
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }
}

class _RenewalAlert extends StatelessWidget {
  final StreamingPackage package;
  const _RenewalAlert({required this.package});

  @override
  Widget build(BuildContext context) {
    final days = package.daysUntilRenewal;
    final whenText = days <= 0 ? "Bugün" : "$days gün sonra";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: StreamingProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: StreamingProfileCardView.moduleAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_repeat_outlined,
              color: StreamingProfileCardView.moduleAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$whenText yenileniyor: ${package.name} · "
              "${_formatMoney(package.price)} ${package.currency}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bir şirketin başlığı + o şirketten alınan paketler.
class _ProviderSection extends StatelessWidget {
  final StreamingProvider provider;
  const _ProviderSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = _providerColor(provider.name);
    final packages = provider.activePackages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                "${_formatMoney(provider.monthlyCost)} TRY/ay",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "${packages.length} paket · ${provider.channelCount} kanal",
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 186,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: packages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _PackageCard(package: packages[i], color: color),
          ),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final StreamingPackage package;
  final Color color;
  const _PackageCard({required this.package, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      padding: const EdgeInsets.all(14),
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
              Expanded(
                child: Text(
                  package.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
              _Badge(label: package.quality.label, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "${_formatMoney(package.price)} ${package.currency} · "
            "${package.billingPeriod.label}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            "${package.maxScreens} ekran · "
            "${_formatDate(package.renewalDate)} yenilenir",
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 10),
          if (package.channels.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: package.channels
                      .map((c) => _ChannelChip(channel: c))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChannelChip extends StatelessWidget {
  final StreamingChannel channel;
  const _ChannelChip({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(channel.name,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// Şirket başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _providerPalette = <Color>[
  Color(0xFF4A2E6B),
  Color(0xFF2E4A6B),
  Color(0xFF6B2E45),
  Color(0xFF2E6B5A),
  Color(0xFF6B5A2E),
];

Color _providerColor(String name) {
  final index = name.hashCode.abs() % _providerPalette.length;
  return _providerPalette[index];
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
