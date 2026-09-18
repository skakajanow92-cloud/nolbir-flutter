/// Antrenman türü.
enum WorkoutType {
  running,
  cycling,
  swimming,
  weightlifting,
  football,
  basketball,
  tennis,
  yoga,
  walking,
  other,
}

extension WorkoutTypeLabel on WorkoutType {
  String get label => switch (this) {
        WorkoutType.running => "Koşu",
        WorkoutType.cycling => "Bisiklet",
        WorkoutType.swimming => "Yüzme",
        WorkoutType.weightlifting => "Ağırlık Antrenmanı",
        WorkoutType.football => "Futbol",
        WorkoutType.basketball => "Basketbol",
        WorkoutType.tennis => "Tenis",
        WorkoutType.yoga => "Yoga",
        WorkoutType.walking => "Yürüyüş",
        WorkoutType.other => "Diğer",
      };
}

/// Kullanıcının kaydettiği tek bir antrenman seansı (günlük takip).
class WorkoutSession {
  final String id;
  final DateTime date;
  final WorkoutType type;
  final int durationMinutes;
  final int? caloriesBurned;
  final double? distanceKm; // koşu/bisiklet/yüzme gibi türlerde anlamlı
  final String? note;

  const WorkoutSession({
    required this.id,
    required this.date,
    required this.type,
    required this.durationMinutes,
    this.caloriesBurned,
    this.distanceKm,
    this.note,
  });

  /// İki tarihin aynı takvim gününe denk gelip gelmediği — streak
  /// hesaplaması için kullanılır.
  bool isSameDayAs(DateTime other) =>
      date.year == other.year && date.month == other.month && date.day == other.day;
}

/// Kullanıcının sevdiği bir spor dalı (Food modülündeki FavoriteFood ile
/// aynı sadelikte — kategori zorunluluğu yok, sadece ad + opsiyonel not).
class FavoriteSport {
  final String id;
  final String name;
  final String? note;

  const FavoriteSport({required this.id, required this.name, this.note});
}

/// Kullanıcının tuttuğu bir takım.
class FavoriteTeam {
  final String id;
  final String name;
  final String sportBranch; // örn. "Futbol", "Basketbol"
  final int? sinceYear;

  const FavoriteTeam({
    required this.id,
    required this.name,
    required this.sportBranch,
    this.sinceYear,
  });
}

/// Takip edilen spor habercisi/kaynağının türü.
enum SportsSourceType { website, journalist, podcast, tvProgram, magazine }

extension SportsSourceTypeLabel on SportsSourceType {
  String get label => switch (this) {
        SportsSourceType.website => "Web Sitesi",
        SportsSourceType.journalist => "Gazeteci",
        SportsSourceType.podcast => "Podcast",
        SportsSourceType.tvProgram => "TV Programı",
        SportsSourceType.magazine => "Dergi",
      };
}

/// Kullanıcının takip ettiği bir spor habercisi/kaynağı.
class SportsNewsSource {
  final String id;
  final String name;
  final SportsSourceType type;
  final String? note;

  const SportsNewsSource({
    required this.id,
    required this.name,
    required this.type,
    this.note,
  });
}
