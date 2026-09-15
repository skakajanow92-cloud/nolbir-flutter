import '../../../models/feed_card/feed_card.dart';

/// Kullanıcının kendi paylaşımlarının demo verisi.
List<FeedCard> buildPostsMock() {
  return [
    const UserPostCard(id: "post1", mediaUrl: "", caption: "İlk paylaşım"),
    const UserPostCard(id: "post2", mediaUrl: "", caption: "İkinci paylaşım"),
    const UserPostCard(id: "post3", mediaUrl: "", caption: "Üçüncü paylaşım"),
  ];
}
