import 'package:flutter/material.dart';
import 'package:nolbir/core/widgets/page_aware_scroll_view.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/donation.dart';

/// Bağış Profili — yedinci profil modülü.
///
/// TASARIM NOTU: Yemek modülünde iyi çalıştığı doğrulanan
/// `SingleChildScrollView` + yatay kaydırmalı bölümler deseni burada da
/// kullanıldı — birden fazla bölüm bir ekrana sığmayacağında bu artık
/// projenin standart yaklaşımı.
///
/// GİZLİLİK NOTU: `politicalParty` alanı bilinçli olarak opsiyonel.
/// Kullanıcı bunu paylaşmamayı seçebilir; boş/null olduğunda bu satır
/// arayüzde HİÇ görünmez (aşağıdaki koşullu render'a bakın).
///
/// Modül vurgu rengi: derin turkuaz — önceki altı modülden ayrışan
/// yedinci renk, "paylaşma/topluluk" hissi veriyor.
class DonationProfileCardView extends StatelessWidget {
  final DonationProfileCard card;

  const DonationProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF2E7D82);
  static const _base = Color(0xFF0D1414);
  static const _baseEnd = Color(0xFF141C1C);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                const SizedBox(height: 24),
                _SectionLabel(
                    text: "Kuruluşlarım & Topluluklarım (${card.affiliations.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 122,
                  child: card.affiliations.isEmpty
                      ? const _EmptyHint(text: "Henüz eklenmiş kuruluş/topluluk yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.affiliations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _AffiliationMiniCard(affiliation: card.affiliations[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Bağışlarım (${card.donations.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 134,
                  child: card.donations.isEmpty
                      ? const _EmptyHint(text: "Henüz kayıtlı bağış yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.donations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _DonationMiniCard(donation: card.donations[i]),
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
  final DonationProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    final hasParty = card.politicalParty != null && card.politicalParty!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.volunteer_activism_outlined,
                color: DonationProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Bağış", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${_formatMoney(card.totalDonated)} TRY",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 2),
        const Text("toplam bağış", style: TextStyle(color: Colors.white38, fontSize: 13)),
        if (hasParty) ...[
          const SizedBox(height: 10),
          _PartyChip(name: card.politicalParty!),
        ],
      ],
    );
  }
}

class _PartyChip extends StatelessWidget {
  final String name;
  const _PartyChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.how_to_vote_outlined,
              size: 14, color: DonationProfileCardView.moduleAccent),
          const SizedBox(width: 6),
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      ),
    );
  }
}

class _AffiliationMiniCard extends StatelessWidget {
  final Affiliation affiliation;
  const _AffiliationMiniCard({required this.affiliation});

  @override
  Widget build(BuildContext context) {
    final color = _orgColor(affiliation.name);

    return Container(
      width: 176,
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
              Icon(Icons.groups_outlined, color: color, size: 18),
              const SizedBox(width: 6),
              _TypeBadge(label: affiliation.type.label, color: color),
            ],
          ),
          const Spacer(),
          Text(
            affiliation.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          if (affiliation.role != null) ...[
            const SizedBox(height: 2),
            Text(affiliation.role!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

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

class _DonationMiniCard extends StatelessWidget {
  final Donation donation;
  const _DonationMiniCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final color = _orgColor(donation.organization);

    return Container(
      width: 192,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.55)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  donation.organization,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const Icon(Icons.favorite, color: Colors.white70, size: 16),
            ],
          ),
          const Spacer(),
          Text(
            "${_formatMoney(donation.amount)} ${donation.currency}",
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(_formatDate(donation.date),
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          if (donation.isRecurring) ...[
            const SizedBox(height: 4),
            const Text("Düzenli bağış",
                style: TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

// Kuruluş başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _orgPalette = <Color>[
  Color(0xFF2E5A55),
  Color(0xFF3E4A5A),
  Color(0xFF5A4E33),
  Color(0xFF3E5A45),
];

Color _orgColor(String name) {
  final index = name.hashCode.abs() % _orgPalette.length;
  return _orgPalette[index];
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
