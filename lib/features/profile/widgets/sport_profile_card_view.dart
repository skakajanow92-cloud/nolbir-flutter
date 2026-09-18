import 'package:flutter/material.dart';
import 'package:nolbir/core/widgets/page_aware_scroll_view.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/sport.dart';

/// Spor Profili — yirminci profil modülü.
///
/// TASARIM NOTU: Dört alt bölümü var (antrenman geçmişi, tutulan
/// takımlar, sevilen spor dalları, takip edilen kaynaklar) — Food/Career/
/// Health/Taxi modüllerindeki aynı gerekçeyle dikey
/// `SingleChildScrollView` kullanıldı.
///
/// Başlıkta bu haftaki toplam antrenman süresi VE ardışık gün serisi
/// (streak) gösteriliyor — "günlük antrenman takibi" vurgusunu somut
/// kılmak için (bkz. sport.dart'taki SportProfileCard.currentStreakDays).
///
/// Modül vurgu rengi: çim yeşili — Cüzdan modülünün mavimsi zümrüdünden
/// (0xFF1F6F5C) ayrışan, daha doygun/canlı bir yeşil.
class SportProfileCardView extends StatelessWidget {
  final SportProfileCard card;

  const SportProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF5AA33A);
  static const _base = Color(0xFF0E130C);
  static const _baseEnd = Color(0xFF161D13);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sessions = card.sortedSessions;
    final streak = card.currentStreakDays;

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
                if (streak > 0) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _StreakBanner(days: streak),
                  ),
                ],
                const SizedBox(height: 22),
                _SectionLabel(text: "Antrenman Geçmişim (${sessions.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: sessions.isEmpty
                      ? const _EmptyHint(text: "Henüz antrenman kaydedilmedi")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: sessions.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _SessionMiniCard(session: sessions[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Tuttuğum Takımlar (${card.favoriteTeams.length})",
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: card.favoriteTeams.isEmpty
                      ? const Text(
                          "Henüz tutulan takım eklenmedi",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: card.favoriteTeams
                              .map((t) => _TeamChip(team: t))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Sevdiğim Spor Dalları (${card.favoriteSports.length})",
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: card.favoriteSports.isEmpty
                      ? const Text(
                          "Henüz favori spor dalı eklenmedi",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: card.favoriteSports
                              .map((s) => _SportChip(sport: s))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Takip Ettiğim Kaynaklar (${card.newsSources.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: card.newsSources.isEmpty
                      ? const _EmptyHint(text: "Henüz takip edilen kaynak yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.newsSources.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _SourceMiniCard(source: card.newsSources[i]),
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
  final SportProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              color: SportProfileCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text("Spor", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${card.thisWeekTotalMinutes} dk",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "bu hafta · ${card.thisWeekSessions.length} seans",
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int days;
  const _StreakBanner({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SportProfileCardView.moduleAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: SportProfileCardView.moduleAccent.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_outlined,
            color: SportProfileCardView.moduleAccent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            "$days gündür ardışık antrenman yapıyorsun",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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

class _SessionMiniCard extends StatelessWidget {
  final WorkoutSession session;
  const _SessionMiniCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(session.type.label);

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
          Row(
            children: [
              Icon(_iconFor(session.type), color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  session.type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "${session.durationMinutes} dk",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (session.distanceKm != null)
            Text(
              "${session.distanceKm!.toStringAsFixed(1)} km",
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          if (session.caloriesBurned != null)
            Text(
              "${session.caloriesBurned} kcal",
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          const SizedBox(height: 4),
          Text(
            _formatDate(session.date),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TeamChip extends StatelessWidget {
  final FavoriteTeam team;
  const _TeamChip({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: SportProfileCardView.moduleAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SportProfileCardView.moduleAccent.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        team.sinceYear != null
            ? "${team.name} · ${team.sportBranch} · ${team.sinceYear}'den beri"
            : "${team.name} · ${team.sportBranch}",
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  final FavoriteSport sport;
  const _SportChip({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: SportProfileCardView.moduleAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SportProfileCardView.moduleAccent.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        sport.note != null ? "${sport.name} · ${sport.note}" : sport.name,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class _SourceMiniCard extends StatelessWidget {
  final SportsNewsSource source;
  const _SourceMiniCard({required this.source});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(source.name);

    return Container(
      width: 172,
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
              Icon(_iconForSource(source.type), color: color, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  source.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            source.type.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(WorkoutType type) => switch (type) {
  WorkoutType.running => Icons.directions_run,
  WorkoutType.cycling => Icons.directions_bike_outlined,
  WorkoutType.swimming => Icons.pool_outlined,
  WorkoutType.weightlifting => Icons.fitness_center_outlined,
  WorkoutType.football => Icons.sports_soccer_outlined,
  WorkoutType.basketball => Icons.sports_basketball_outlined,
  WorkoutType.tennis => Icons.sports_tennis_outlined,
  WorkoutType.yoga => Icons.self_improvement_outlined,
  WorkoutType.walking => Icons.directions_walk,
  WorkoutType.other => Icons.sports_outlined,
};

IconData _iconForSource(SportsSourceType type) => switch (type) {
  SportsSourceType.website => Icons.language_outlined,
  SportsSourceType.journalist => Icons.badge_outlined,
  SportsSourceType.podcast => Icons.podcasts_outlined,
  SportsSourceType.tvProgram => Icons.tv_outlined,
  SportsSourceType.magazine => Icons.menu_book_outlined,
};

// Kaynak adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF2E5A1F),
  Color(0xFF3E4A5A),
  Color(0xFF5A4A1F),
  Color(0xFF3E5A45),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
