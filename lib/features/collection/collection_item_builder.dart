import '../../models/feed_card.dart';

/// Herhangi bir FeedCard'ı (video, ürün, abonelik, sepet özeti ...)
/// koleksiyona kaydedilebilir bir CollectionItemCard'a çevirir.
///
/// Kart tipine özgü başlık/önizleme burada, TEK yerde üretilir. `FeedCard`
/// sealed class olduğu için bu switch eksiksiz olmak zorunda — yeni bir
/// kart tipi eklediğinde derleyici burada bir case eksik diye uyarır,
/// yani "kaydet" butonu sessizce bozulmaz.
CollectionItemCard toCollectionItem(FeedCard card) {
  final (title, previewUrl) = switch (card) {
    VideoCard v => ("@${v.username}: ${v.description}", v.videoUrl),
    ProductCard p => (p.title, p.imageUrl),
    SubscriptionCard s => (s.serviceName, ""),
    ProfileHeaderCard pr => (pr.username, pr.avatarUrl),
    UserPostCard up => (up.caption, up.mediaUrl),
    CartSummaryCard cs => ("Sepet", ""),
    // Bir koleksiyon kartı zaten koleksiyon kartı olduğu için pratikte
    // buraya düşmez, ama sealed class'ı eksiksiz kapatmak için gerekli.
    CollectionItemCard c => (c.title, c.previewUrl),
  };

  return CollectionItemCard(
    id: "col_${card.id}",
    title: title,
    previewUrl: previewUrl,
    originalCard: card,
  );
}
