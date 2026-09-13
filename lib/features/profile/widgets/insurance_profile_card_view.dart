import 'package:flutter/material.dart';
import '../../../models/feed_card.dart';
import '../../../models/insurance.dart';

/// Sigorta Profili — üçüncü profil modülü.
/// Modül vurgu rengi: koyu lacivert-indigo — Temel Bilgiler'in bordosundan,
/// Cüzdan'ın zümrüdünden bilinçli olarak farklı, "güvence/koruma" hissi.
class InsuranceProfileCardView extends StatelessWidget {
  final InsuranceProfileCard card;

  const InsuranceProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF3A4E7A);
  static const _base = Color(0xFF101218);
  static const _baseEnd = Color(0xFF171B24);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final activeCount = card.activeCount;
    final expiredCount = card.policies.length - activeCount;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Header(activeCount: activeCount, expiredCount: expiredCount),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Poliçelerim (${card.policies.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 176,
                child: card.policies.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Henüz kayıtlı poliçe yok",
                            style: TextStyle(color: Colors.white38, fontSize: 13)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: card.policies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) =>
                            _PolicyMiniCard(policy: card.policies[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int activeCount;
  final int expiredCount;
  const _Header({required this.activeCount, required this.expiredCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.shield_outlined,
                color: InsuranceProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Sigorta", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "$activeCount aktif poliçe",
          style: const TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, height: 1.1),
        ),
        if (expiredCount > 0) ...[
          const SizedBox(height: 2),
          Text("$expiredCount süresi dolmuş",
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ],
    );
  }
}

class _PolicyMiniCard extends StatelessWidget {
  final InsurancePolicy policy;
  const _PolicyMiniCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final color = _companyColor(policy.company);

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
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
                Icon(_iconFor(policy.type), color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    policy.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(policy.type.label,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const Spacer(),
            Text(
              "${_formatMoney(policy.coverageAmount)} ${policy.currency}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const Text("teminat",
                style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 8),
            _StatusPill(isActive: policy.isActive),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171B24),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PolicyDetailSheet(policy: policy),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;
  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF7FD98A) : Colors.white54;
    final bgAlpha = isActive ? 0.22 : 0.10;
    final label = isActive ? "Aktif" : "Süresi Doldu";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

/// "Kısa özet"e dokununca açılan tam detay sayfası.
class PolicyDetailSheet extends StatelessWidget {
  final InsurancePolicy policy;
  const PolicyDetailSheet({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
                    policy.company,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Row(
              children: [
                Icon(_iconFor(policy.type),
                    color: InsuranceProfileCardView.moduleAccent, size: 16),
                const SizedBox(width: 6),
                Text(policy.type.label,
                    style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(label: "Poliçe No", value: policy.policyNumber),
            _DetailRow(
                label: "Durum", value: policy.isActive ? "Aktif" : "Süresi Doldu"),
            _DetailRow(
                label: "Teminat",
                value: "${_formatMoney(policy.coverageAmount)} ${policy.currency}"),
            _DetailRow(
                label: "Prim", value: "${_formatMoney(policy.premium)} ${policy.currency}"),
            _DetailRow(label: "Başlangıç", value: _formatDate(policy.startDate)),
            _DetailRow(label: "Bitiş", value: _formatDate(policy.endDate)),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

IconData _iconFor(InsurancePolicyType type) => switch (type) {
      InsurancePolicyType.health => Icons.local_hospital_outlined,
      InsurancePolicyType.vehicle => Icons.directions_car_outlined,
      InsurancePolicyType.home => Icons.home_outlined,
      InsurancePolicyType.life => Icons.favorite_outline,
      InsurancePolicyType.travel => Icons.flight_outlined,
    };

// Şirket başına sabit, elle seçilmiş uyumlu bir palet (bkz. wallet
// modülündeki aynı yaklaşım — rastgele renk karmaşasından kaçınmak için).
const _companyPalette = <Color>[
  Color(0xFF33456B),
  Color(0xFF5A3E52),
  Color(0xFF3E5A4A),
  Color(0xFF5A4E33),
];

Color _companyColor(String company) {
  final index = company.hashCode.abs() % _companyPalette.length;
  return _companyPalette[index];
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

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
