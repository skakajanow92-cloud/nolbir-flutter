import 'package:flutter/material.dart';
import 'package:nolbir/core/widgets/page_aware_scroll_view.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/hosting.dart';

/// Hosting Profili — yirmi dördüncü profil modülü.
///
/// TASARIM NOTU: Dört alt bölümü var (sunucular, hosting paketleri,
/// domainler, SSL sertifikaları) — Food/Career/Health/Taxi/Sport
/// modüllerindeki aynı gerekçeyle dikey `SingleChildScrollView`
/// kullanıldı.
///
/// Başlıktaki alarm banner'ı dört farklı varlık türünü (sunucu/paket/
/// domain/SSL) TEK bir listede birleştirip en yakın ödeme/yenilemeyi
/// gösteriyor — sunucu/paket için 7, domain/SSL için 30 günlük eşikle
/// (bkz. hosting.dart'taki HostingProfileCard.nextAlertPayment).
///
/// Modül vurgu rengi: mor-gri sunucu tonu — Tanışma modülünün menekşe
/// morundan (0xFF6A4E9C) ve Konaklama modülünün pembe-morundan
/// (0xFF6B4258) ayrışan, "sunucu kabini/veri merkezi" hissi veren nötr
/// ton.
class HostingProfileCardView extends StatelessWidget {
  final HostingProfileCard card;

  const HostingProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF52466B);
  static const _base = Color(0xFF100E14);
  static const _baseEnd = Color(0xFF19151E);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final alert = card.nextAlertPayment;

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
                if (alert != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _AlertBanner(label: alert.label, date: alert.date),
                  ),
                ],
                const SizedBox(height: 22),
                _SectionLabel(text: "Sunucularım (${card.servers.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 172,
                  child: card.servers.isEmpty
                      ? const _EmptyHint(text: "Kayıtlı sunucu yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.servers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _ServerMiniCard(server: card.servers[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Hosting Paketlerim (${card.hostingPackages.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: card.hostingPackages.isEmpty
                      ? const _EmptyHint(text: "Kayıtlı hosting paketi yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.hostingPackages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _PackageMiniCard(
                            package: card.hostingPackages[i],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Domainlerim (${card.domains.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: card.domains.isEmpty
                      ? const _EmptyHint(text: "Kayıtlı domain yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.domains.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _DomainMiniCard(domain: card.domains[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "SSL Sertifikalarım (${card.sslCertificates.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: card.sslCertificates.isEmpty
                      ? const _EmptyHint(text: "Kayıtlı SSL sertifikası yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.sslCertificates.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _SslMiniCard(cert: card.sslCertificates[i]),
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
  final HostingProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.dns_outlined,
              color: HostingProfileCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Hosting",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(card.totalMonthlyOutlay)} TRY",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          "aylık toplam gider (normalize)",
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String label;
  final DateTime date;
  const _AlertBanner({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    final days = date.difference(DateTime.now()).inDays;
    final whenText = days <= 0 ? "Bugün" : "$days gün sonra";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: HostingProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HostingProfileCardView.moduleAccent.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available_outlined,
            color: HostingProfileCardView.moduleAccent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$whenText: $label",
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

class _StatusPill extends StatelessWidget {
  final HostingStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      HostingStatus.active => const Color(0xFF7FD98A),
      HostingStatus.suspended => const Color(0xFFE0A030),
      HostingStatus.expired => const Color(0xFFD98A7F),
      HostingStatus.provisioning => Colors.white54,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ServerMiniCard extends StatelessWidget {
  final HostedServer server;
  const _ServerMiniCard({required this.server});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(server.provider);

    return Container(
      width: 210,
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
              Icon(Icons.dns_outlined, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  server.type.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusPill(status: server.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            server.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "${server.provider} · ${server.ipAddress}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            "${server.cpuCores} vCPU · ${server.ramGb} GB RAM · ${server.diskGb} GB",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const Spacer(),
          Text(
            "${_formatMoney(server.paymentAmount)} ${server.currency} / ${server.billingCycle.label}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            _formatDate(server.nextPaymentDate),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PackageMiniCard extends StatelessWidget {
  final HostingPackage package;
  const _PackageMiniCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(package.provider);

    return Container(
      width: 200,
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
              Expanded(
                child: Text(
                  package.provider,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusPill(status: package.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            package.packageName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            package.scopeDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const Spacer(),
          Text(
            "${_formatMoney(package.paymentAmount)} ${package.currency} / ${package.billingCycle.label}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            _formatDate(package.nextPaymentDate),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DomainMiniCard extends StatelessWidget {
  final Domain domain;
  const _DomainMiniCard({required this.domain});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(domain.domainName);

    return Container(
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
              Icon(Icons.language_outlined, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  domain.domainName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            domain.registrar,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const Spacer(),
          Text(
            "Yenileme: ${_formatDate(domain.expiryDate)}",
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            domain.autoRenew
                ? "Otomatik yenileme açık"
                : "Otomatik yenileme kapalı",
            style: TextStyle(
              color: domain.autoRenew
                  ? const Color(0xFF7FD98A)
                  : Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SslMiniCard extends StatelessWidget {
  final SslCertificate cert;
  const _SslMiniCard({required this.cert});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(cert.domainName);

    return Container(
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
              Icon(Icons.lock_outline, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  cert.domainName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                cert.certType.label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            cert.provider,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const Spacer(),
          Text(
            "Bitiş: ${_formatDate(cert.expiryDate)}",
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            cert.paymentAmount > 0
                ? "${_formatMoney(cert.paymentAmount)} ${cert.currency} / yıl"
                : "Ücretsiz",
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// Sağlayıcı/domain adı başına sabit, elle seçilmiş uyumlu bir palet
// (bkz. diğer modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF3E3752),
  Color(0xFF3E4A5A),
  Color(0xFF4A3E52),
  Color(0xFF3E524A),
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
