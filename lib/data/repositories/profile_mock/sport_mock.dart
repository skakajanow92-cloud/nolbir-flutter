import '../../../models/feed_card/feed_card.dart';
import '../../../models/sport.dart';

SportProfileCard buildSportMock() {
  return SportProfileCard(
    id: "sport1",
    workoutSessions: [
      WorkoutSession(
        id: "ws1",
        date: DateTime.now(),
        type: WorkoutType.running,
        durationMinutes: 35,
        caloriesBurned: 310,
        distanceKm: 5.2,
      ),
      WorkoutSession(
        id: "ws2",
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: WorkoutType.weightlifting,
        durationMinutes: 55,
        caloriesBurned: 260,
      ),
      WorkoutSession(
        id: "ws3",
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: WorkoutType.swimming,
        durationMinutes: 40,
        caloriesBurned: 300,
        distanceKm: 1.5,
      ),
    ],
    favoriteTeams: const [
      FavoriteTeam(
        id: "ft1",
        name: "Fenerbahçe",
        sportBranch: "Futbol",
        sinceYear: 2001,
      ),
      FavoriteTeam(
        id: "ft2",
        name: "Anadolu Efes",
        sportBranch: "Basketbol",
        sinceYear: 2016,
      ),
    ],
    favoriteSports: const [
      FavoriteSport(id: "fs1", name: "Koşu", note: "Haftada 3 gün"),
      FavoriteSport(id: "fs2", name: "Yüzme"),
      FavoriteSport(id: "fs3", name: "Tenis", note: "Amatör seviye"),
    ],
    newsSources: const [
      SportsNewsSource(
        id: "ns1",
        name: "Fanatik",
        type: SportsSourceType.website,
      ),
      SportsNewsSource(
        id: "ns2",
        name: "Bugün Futbol Var",
        type: SportsSourceType.podcast,
      ),
    ],
  );
}
