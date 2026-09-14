import 'base.dart';

/// --- SOL TAB (Profil) için kart tipleri ---

class ProfileHeaderCard extends FeedCard implements Collectible {
  final String username;
  final String avatarUrl;
  final String bio;
  final int followerCount;
  final String firstName;
  final String lastName;
  final String country;
  final String gender;

  const ProfileHeaderCard({
    required String id,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.gender,
    this.followerCount = 0,
  }) : super(id);

  String get fullName => "$firstName $lastName".trim();

  ProfileHeaderCard copyWith({
    String? username,
    String? avatarUrl,
    String? bio,
    String? firstName,
    String? lastName,
    String? country,
    String? gender,
    int? followerCount,
  }) {
    return ProfileHeaderCard(
      id: id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      followerCount: followerCount ?? this.followerCount,
    );
  }

  @override
  (String, String) toCollectionPreview() => (fullName, avatarUrl);
}
