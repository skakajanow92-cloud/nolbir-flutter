import 'package:flutter/material.dart';
import '../../../models/feed_card.dart';
import '../../../models/dating.dart';

/// Tanışma/Eşleşme Profili — dokuzuncu profil modülü.
///
/// NOT: Bu kart Profil tab'ındaki diğer modüllerle aynı dikey akışta
/// gösteriliyor; sağa/sola kaydırmalı eşleşme ekranının kendisi burada
/// TANIMLANMIYOR — bu modül sadece o ekranda (ya da başka bir eşleşme
/// akışında) kullanılacak profil verisini taşıyor ve önizliyor.
///
/// Diğer modüllerin aksine tam ekran fotoğraf zemin + alt gradyan
/// overlay kullanıyor (tanışma/eşleşme kartı hissi için bilinçli tercih).
///
/// Modül vurgu rengi: doygun gül-kırmızısı — Konaklama modülünün soluk
/// mor tonundan (0xFF6B4258) bilerek ayrışan, daha canlı/tutkulu bir renk.
class DatingProfileCardView extends StatelessWidget {
  final DatingProfileCard card;

  const DatingProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFFB23A56);
  static const _base = Color(0xFF160E12);
  static const _baseEnd = Color(0xFF1F1418);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final photoUrl = card.photoUrls.isNotEmpty ? card.photoUrls.first : null;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _PhotoBackground(photoUrl: photoUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE6160E12)],
                stops: [0.35, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_outline, color: moduleAccent, size: 20),
                      SizedBox(width: 8),
                      Text("Tanışma",
                          style: TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    card.tagline.isNotEmpty ? card.tagline : "Henüz tanıtım yazısı yok",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PreferencePill(
                        icon: Icons.person_outline,
                        label: card.sexualOrientation.label,
                      ),
                      _PreferencePill(
                        icon: Icons.favorite_border,
                        label: card.relationshipGoal.label,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "İlgi Alanları (${card.interests.length})",
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: card.interests.isEmpty
                      ? const Text("Henüz ilgi alanı eklenmedi",
                          style: TextStyle(color: Colors.white38, fontSize: 13))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              card.interests.map((t) => _InterestChip(tag: t)).toList(),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoBackground extends StatelessWidget {
  final String? photoUrl;
  const _PhotoBackground({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DatingProfileCardView._base,
              DatingProfileCardView._baseEnd,
            ],
          ),
        ),
        child: Center(
          child: Icon(Icons.person_outline, color: Colors.white24, size: 88),
        ),
      );
    }
    return Image.network(
      photoUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(color: DatingProfileCardView._base),
        child: Center(
          child: Icon(Icons.person_outline, color: Colors.white24, size: 88),
        ),
      ),
    );
  }
}

class _PreferencePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PreferencePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: DatingProfileCardView.moduleAccent),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final InterestTag tag;
  const _InterestChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: DatingProfileCardView.moduleAccent.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: DatingProfileCardView.moduleAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(tag.category), size: 13, color: Colors.white70),
          const SizedBox(width: 6),
          Text(tag.label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

IconData _iconFor(InterestCategory category) {
  if (category == InterestCategory.hobby) return Icons.palette_outlined;
  if (category == InterestCategory.sport) return Icons.sports_soccer_outlined;
  if (category == InterestCategory.artist) return Icons.mic_external_on_outlined;
  if (category == InterestCategory.movie) return Icons.movie_outlined;
  if (category == InterestCategory.game) return Icons.sports_esports_outlined;
  if (category == InterestCategory.book) return Icons.menu_book_outlined;
  if (category == InterestCategory.music) return Icons.music_note_outlined;
  return Icons.label_outline; // kayıtlı olmayan yeni bir kategori için fallback
}
