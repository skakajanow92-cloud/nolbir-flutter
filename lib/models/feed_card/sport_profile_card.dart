import 'base.dart';
import '../sport.dart';

/// Yirminci profil modülü: kullanıcının spor hayatı — günlük antrenman
/// takibi, tuttuğu takımlar, sevdiği spor dalları ve takip ettiği spor
/// habercileri/kaynakları.
class SportProfileCard extends FeedCard implements Collectible {
  final List<WorkoutSession> workoutSessions;
  final List<FavoriteTeam> favoriteTeams;
  final List<FavoriteSport> favoriteSports;
  final List<SportsNewsSource> newsSources;

  const SportProfileCard({
    required String id,
    this.workoutSessions = const [],
    this.favoriteTeams = const [],
    this.favoriteSports = const [],
    this.newsSources = const [],
  }) : super(id);

  List<WorkoutSession> get sortedSessions => workoutSessions.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<WorkoutSession> get thisWeekSessions => workoutSessions.where(
      (s) => DateTime.now().difference(s.date).inDays < 7).toList();

  int get thisWeekTotalMinutes =>
      thisWeekSessions.fold(0, (sum, s) => sum + s.durationMinutes);

  /// Bugünden geriye doğru, en az bir antrenman yapılan ardışık gün
  /// sayısı — bir gün boşluk olduğunda seri kesilir.
  int get currentStreakDays {
    if (workoutSessions.isEmpty) return 0;
    var streak = 0;
    var day = DateTime.now();
    while (workoutSessions.any((s) => s.isSameDayAs(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  (String, String) toCollectionPreview() => ("Spor Profili", "");
}