import '../../models/feed_card.dart';

/// Sol tab (Profil) veri kaynağı sözleşmesi.
abstract class ProfileRepository {
  Future<List<FeedCard>> fetchProfileFeed(String userId);
  Future<void> addPost(FeedCard post);
}

class MockProfileRepository implements ProfileRepository {
  // Gerçek uygulamada bu bir API/DB olurdu; burada oturum boyunca
  // bellekte tutuluyor ki eklenen yeni paylaşımlar kalıcı görünsün.
  final List<FeedCard> _cards = [
    const ProfileHeaderCard(
      id: "p1",
      username: "kullanici_adi",
      avatarUrl: "",
      bio: "Kısa biyografi burada",
      followerCount: 128,
    ),
    const UserPostCard(id: "post1", mediaUrl: "", caption: "İlk paylaşım"),
    const UserPostCard(id: "post2", mediaUrl: "", caption: "İkinci paylaşım"),
    const UserPostCard(id: "post3", mediaUrl: "", caption: "Üçüncü paylaşım"),
  ];

  @override
  Future<List<FeedCard>> fetchProfileFeed(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_cards);
  }

  @override
  Future<void> addPost(FeedCard post) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cards.add(post);
  }
}
