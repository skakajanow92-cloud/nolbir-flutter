import 'cart.dart';

/// Tüm feed kartlarının ortak temeli.
/// Yeni bir kart tipi eklemek için buraya yeni bir sınıf eklemen yeterli;
/// ortak iskelete (VerticalCardFeed) dokunmana gerek yok.
sealed class FeedCard {
  final String id;
  const FeedCard(this.id);
}

/// --- ORTA TAB (Genel Akış) için kart tipleri ---

class VideoCard extends FeedCard {
  final String videoUrl;
  final String username;
  final String description;
  final int likeCount;

  const VideoCard({
    required String id,
    required this.videoUrl,
    required this.username,
    required this.description,
    this.likeCount = 0,
  }) : super(id);
}

class ProductCard extends FeedCard {
  final String title;
  final String imageUrl;
  final double price;
  final String currency;
  /// "Sepete ekle" basılınca hangi sepete (market, ikinci el, spor
  /// malzemeleri, toptan ticaret ...) gideceğini belirler. Yeni bir
  /// dikey için CartType'a yeni bir sabit eklemen yeterli, bu kart
  /// sınıfına dokunman gerekmez (bkz. models/cart.dart).
  final CartType cartType;

  const ProductCard({
    required String id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.currency = "TRY",
    this.cartType = CartType.market,
  }) : super(id);
}

class SubscriptionCard extends FeedCard {
  final String serviceName;
  final String description;
  final double monthlyPrice;

  const SubscriptionCard({
    required String id,
    required this.serviceName,
    required this.description,
    required this.monthlyPrice,
  }) : super(id);
}

/// --- SOL TAB (Profil) için kart tipleri ---

class ProfileHeaderCard extends FeedCard {
  final String username;
  final String avatarUrl;
  final String bio;
  final int followerCount;

  const ProfileHeaderCard({
    required String id,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    this.followerCount = 0,
  }) : super(id);
}

class UserPostCard extends FeedCard {
  final String mediaUrl;
  final String caption;

  const UserPostCard({
    required String id,
    required this.mediaUrl,
    required this.caption,
  }) : super(id);
}

/// Kullanıcının dolu her sepeti (market, eczane, bilet, sigorta, ...) için
/// profil akışında birer tam ekran özet kart olarak gösterilir. Hangi sepet
/// türü olduğu `cartType` alanında tutulur; görünüm/ikon fallback destekli
/// CartVisuals'tan gelir (bkz. core/cart/cart_visuals.dart) — bu sayede yeni
/// bir sepet türü eklendiğinde bu sınıfa dokunmana gerek kalmaz.
class CartSummaryCard extends FeedCard {
  final CartType cartType;
  final int itemCount;
  final double subtotal;
  final String currency;

  const CartSummaryCard({
    required String id,
    required this.cartType,
    required this.itemCount,
    required this.subtotal,
    this.currency = "TRY",
  }) : super(id);
}

class CollectionItemCard extends FeedCard {
  final String title;
  final String previewUrl;
  final FeedCard originalCard; // koleksiyona eklenen orijinal kart referansı

  const CollectionItemCard({
    required String id,
    required this.title,
    required this.previewUrl,
    required this.originalCard,
  }) : super(id);
}
