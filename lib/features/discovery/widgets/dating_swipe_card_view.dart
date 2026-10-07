import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'dating_filter_dialog.dart';
import 'dating_profile_detail_dialog.dart';

class DatingSwipeCardView extends StatefulWidget {
  final DatingSwipeCard card;

  const DatingSwipeCardView({super.key, required this.card});

  @override
  State<DatingSwipeCardView> createState() => _DatingSwipeCardViewState();
}

class _DatingSwipeCardViewState extends State<DatingSwipeCardView> {
  static const accent = Color(0xFFFF5864);
  static const _base = Color(0xFF17121A);
  static const _baseEnd = Color(0xFF201525);

  late List<DatingProfile> _queue;
  late DatingFilterPreferences _filters;
  int _generatedCount = 0;

  @override
  void initState() {
    super.initState();
    _queue = List.of(widget.card.seedProfiles);
    _filters = widget.card.initialFilters;
    _generatedCount = _queue.length;
    _ensureQueueFilled();
  }

  void _ensureQueueFilled() {
    if (_queue.length < 4) {
      _queue.addAll(
        _generateMoreProfiles(widget.card.id, _generatedCount, 6, _filters),
      );
      _generatedCount += 6;
    }
  }

  void _respond(bool liked) {
    if (_queue.isEmpty) return;
    setState(() {
      _queue.removeAt(0);
      // NOT: beğeni/geçme kaydı backend bağlanınca gönderilecek —
      // şimdilik sadece kuyruktan düşürülüyor.
      _ensureQueueFilled();
    });
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DatingFilterDialog(
        initialFilters: _filters,
        onApply: (f) => setState(() => _filters = f),
      ),
    );
  }

  void _openProfileDetail(DatingProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DatingProfileDetailDialog(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _queue.isNotEmpty ? _queue.first : null;

    return SizedBox.expand(
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
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune, color: Colors.white70),
                      onPressed: _openFilters,
                    ),
                    if (profile != null)
                      GestureDetector(
                        onTap: () => _openProfileDetail(profile),
                        child: _TopAvatar(profile: profile),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: profile == null
                    ? const Center(
                        child: Text(
                          "Gösterilecek profil kalmadı",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _ProfileCard(
                          key: ValueKey(profile.id),
                          profile: profile,
                          onTapAvatar: () => _openProfileDetail(profile),
                        ),
                      ),
              ),
              if (profile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SwipeButton(
                        icon: Icons.close,
                        color: Colors.redAccent,
                        size: 54,
                        onTap: () => _respond(false),
                      ),
                      const SizedBox(width: 20),
                      _SwipeButton(
                        icon: Icons.star,
                        color: Colors.amberAccent,
                        size: 42,
                        onTap: () => _respond(false), // nötr de sonuçta dislike
                      ),
                      const SizedBox(width: 20),
                      _SwipeButton(
                        icon: Icons.favorite,
                        color: accent,
                        size: 54,
                        onTap: () => _respond(true),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

List<DatingProfile> _generateMoreProfiles(
  String cardId,
  int startIndex,
  int count,
  DatingFilterPreferences filters,
) {
  final rnd = Random(cardId.hashCode + startIndex);
  const firstNames = [
    "Deniz",
    "Ece",
    "Kerem",
    "Zeynep",
    "Arda",
    "Nil",
    "Baran",
    "Elif",
  ];
  const lastNames = ["Yılmaz", "Kaya", "Demir", "Şahin", "Çelik", "Aydın"];
  const hometowns = [
    "İstanbul",
    "İzmir",
    "Ankara",
    "Bursa",
    "Antalya",
    "Eskişehir",
  ];
  const hobbyPool = [
    "Yürüyüş",
    "Fotoğrafçılık",
    "Yoga",
    "Sinema",
    "Yüzme",
    "Kitap",
    "Seyahat",
    "Yemek Yapmak",
  ];

  return List.generate(count, (i) {
    final n = startIndex + i;
    final age =
        filters.minAge +
        rnd.nextInt(max(1, filters.maxAge - filters.minAge + 1));
    final hobbies = (List.of(
      hobbyPool,
    )..shuffle(rnd)).take(2 + rnd.nextInt(3)).toList();
    return DatingProfile(
      id: "profile_${cardId}_$n",
      firstName: firstNames[rnd.nextInt(firstNames.length)],
      lastName: lastNames[rnd.nextInt(lastNames.length)],
      age: age,
      hometown: hometowns[rnd.nextInt(hometowns.length)],
      bio:
          "Hayatı dolu dolu yaşamayı seven, yeni insanlarla tanışmaktan keyif alan biriyim.",
      hobbies: hobbies,
      distanceKm: 1 + rnd.nextDouble() * filters.maxDistanceKm,
    );
  });
}

class _TopAvatar extends StatelessWidget {
  final DatingProfile profile;
  const _TopAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      child: profile.photoUrl.isEmpty
          ? const Icon(Icons.person_outline, color: Colors.white54, size: 20)
          : ClipOval(
              child: Image.network(
                profile.photoUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final DatingProfile profile;
  final VoidCallback onTapAvatar;
  const _ProfileCard({
    super.key,
    required this.profile,
    required this.onTapAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.white.withValues(alpha: 0.05),
              child: profile.photoUrl.isEmpty
                  ? const Icon(
                      Icons.person_outline,
                      color: Colors.white24,
                      size: 96,
                    )
                  : Image.network(profile.photoUrl, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.5, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: GestureDetector(
                onTap: onTapAvatar,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${profile.fullName}, ${profile.age}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.hometown,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        if (profile.distanceKm != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            "· ${profile.distanceKm!.toStringAsFixed(0)} km",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  const _SwipeButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}
