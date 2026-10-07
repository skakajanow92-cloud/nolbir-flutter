import '../feed_card/base.dart';

enum GenderPreference { male, female, everyone }

extension GenderPreferenceLabel on GenderPreference {
  String get label {
    switch (this) {
      case GenderPreference.male:
        return "Erkek";
      case GenderPreference.female:
        return "Kadın";
      case GenderPreference.everyone:
        return "Herkes";
    }
  }
}

class DatingProfile {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final String hometown;
  final String bio;
  final String photoUrl;
  final List<String> hobbies;
  final double? distanceKm;

  const DatingProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.hometown,
    required this.bio,
    this.photoUrl = "",
    this.hobbies = const [],
    this.distanceKm,
  });

  String get fullName => "$firstName $lastName";
}

class DatingFilterPreferences {
  final int minAge;
  final int maxAge;
  final double maxDistanceKm;
  final GenderPreference genderPreference;

  const DatingFilterPreferences({
    this.minAge = 18,
    this.maxAge = 45,
    this.maxDistanceKm = 50,
    this.genderPreference = GenderPreference.everyone,
  });
}

/// Orta tab için: Tinder tarzı eşleşme kartı. Yatay "kaydırma" gerçek bir
/// drag gesture DEĞİL — beğen/geç/nötr butonları ile yapılıyor, bu yüzden
/// dış dikey `PageView` ile hiçbir gesture çakışması yok; kart normal
/// şekilde yukarı/aşağı kaydırılabilir kalıyor.
class DatingSwipeCard extends FeedCard {
  final List<DatingProfile> seedProfiles;
  final DatingFilterPreferences initialFilters;

  const DatingSwipeCard({
    required String id,
    required this.seedProfiles,
    this.initialFilters = const DatingFilterPreferences(),
  }) : super(id);
}
