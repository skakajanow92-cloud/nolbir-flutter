import 'cart.dart';

/// FeedCard tipleri için "koleksiyona kaydedilebilir" opsiyonel yeteneği.
/// Bir kart türü koleksiyona eklenebilir olmak istiyorsa sadece bu arayüzü
/// implemente eder — merkezi bir switch'e dokunmasına gerek yoktur.
/// Implemente etmeyen kart türleri (ör. CartSummaryCard'ın kendisi hariç
/// tuttuğun ileride eklenecek türler) otomatik olarak generic bir önizleme
/// alır (bkz. collection_item_builder.dart).
abstract interface class Collectible {
  /// Koleksiyon listesinde gösterilecek başlık ve önizleme URL'i.
  (String title, String previewUrl) toCollectionPreview();
}

/// Tüm feed kartlarının ortak temeli.
///
/// BİLİNÇLİ TASARIM KARARI: Artık `sealed` DEĞİL — bilerek açık bırakıldı.
/// Yeni bir kart tipi eklemek için buraya yeni bir sınıf ekleyip
/// `CardViewRegistry.register<YeniKart>(...)` çağırman yeterli; merkezi
/// hiçbir switch'e dokunmana gerek yok (bkz. core/cards/card_view_registry.dart).
abstract class FeedCard {
  final String id;
  const FeedCard(this.id);
}

/// --- ORTA TAB (Genel Akış) için kart tipleri ---

class VideoCard extends FeedCard implements Collectible {
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

  @override
  (String, String) toCollectionPreview() =>
      ("@$username: $description", videoUrl);
}

class ProductCard extends FeedCard implements Collectible {
  final String title;
  final String imageUrl;
  final double price;
  final String currency;
  final CartType cartType;

  const ProductCard({
    required String id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.currency = "TRY",
    this.cartType = CartType.market,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (title, imageUrl);
}

class SubscriptionCard extends FeedCard implements Collectible {
  final String serviceName;
  final String description;
  final double monthlyPrice;

  const SubscriptionCard({
    required String id,
    required this.serviceName,
    required this.description,
    required this.monthlyPrice,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (serviceName, "");
}

/// --- SOL TAB (Profil) için kart tipleri ---

class ProfileHeaderCard extends FeedCard implements Collectible {
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

  @override
  (String, String) toCollectionPreview() => (username, avatarUrl);
}

class UserPostCard extends FeedCard implements Collectible {
  final String mediaUrl;
  final String caption;

  const UserPostCard({
    required String id,
    required this.mediaUrl,
    required this.caption,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (caption, mediaUrl);
}

/// Kullanıcının dolu her sepeti için profil akışında gösterilen özet kart.
/// Bilerek `Collectible` implemente ediyor (eski switch'teki davranışla
/// birebir aynı) ama pratikte SaveToCollectionButton bu kartla hiç
/// kullanılmıyor — ileride kullanılırsa diye hazır bekliyor.
class CartSummaryCard extends FeedCard implements Collectible {
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

  @override
  (String, String) toCollectionPreview() => ("Sepet", "");
}

class CollectionItemCard extends FeedCard implements Collectible {
  final String title;
  final String previewUrl;
  final FeedCard originalCard;

  const CollectionItemCard({
    required String id,
    required this.title,
    required this.previewUrl,
    required this.originalCard,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (title, previewUrl);
}
