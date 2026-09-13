import 'package:flutter/material.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../models/feed_card.dart';
import 'edit_profile_sheet.dart';

/// Kullanıcının "Temel Bilgiler" kimlik kartı — profil akışının ilk modülü.
///
/// TASARIM NOTU: Uygulamanın geri kalanı (video/ürün kartları) canlı,
/// doygun renkler kullanıyor. Bu kart bilinçli olarak sakin, tek bir vurgu
/// rengiyle (derin bordo — kimlik/güven hissi) ayrışıyor; bilgi yoğun ama
/// gösterişsiz. İleride eklenecek diğer profil modülleri (bankacılık,
/// sağlık, seyahat...) kendi vurgu renklerini seçecek — böylece kullanıcı
/// akışta kaydırırken hangi modülde olduğunu renk üzerinden de hisseder.
class ProfileHeaderCardView extends StatelessWidget {
  final ProfileHeaderCard card;

  const ProfileHeaderCardView({super.key, required this.card});

  static const accent = Color(0xFF7C3B4D);
  static const _base = Color(0xFF121014);
  static const _baseEnd = Color(0xFF1B1720);

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _baseEnd,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditProfileSheet(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardShell(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: Center(
          child: _Avatar(url: card.avatarUrl, initials: _initials(card)),
        ),
      ),
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 26,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "@${card.username}",
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (card.country.isNotEmpty)
                _InfoChip(icon: Icons.public, label: card.country),
              if (card.gender.isNotEmpty)
                _InfoChip(icon: Icons.person_outline, label: card.gender),
            ],
          ),
          if (card.bio.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              card.bio,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            "${card.followerCount} takipçi",
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
      actions: [
        CardActionButton(
          icon: Icons.edit_outlined,
          label: "Düzenle",
          onTap: () => _openEditSheet(context),
        ),
        CardActionButton(
          icon: Icons.settings_outlined,
          label: "Ayarlar",
          onTap: () {},
        ),
      ],
    );
  }

  String _initials(ProfileHeaderCard card) {
    final f = card.firstName.isNotEmpty ? card.firstName[0] : "";
    final l = card.lastName.isNotEmpty ? card.lastName[0] : "";
    final initials = "$f$l".toUpperCase();
    return initials.isNotEmpty ? initials : "?";
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final String initials;

  const _Avatar({required this.url, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [ProfileHeaderCardView.accent, Color(0xFFB5768A)],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1B1720),
        ),
        alignment: Alignment.center,
        child: url.isEmpty
            ? Text(
                initials,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              )
            : ClipOval(
                child: Image.network(
                  url,
                  width: 98,
                  height: 98,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(
                    initials,
                    style: const TextStyle(color: Colors.white70, fontSize: 32),
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

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
          Icon(icon, size: 14, color: ProfileHeaderCardView.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
