import 'cart.dart';
import 'wallet.dart';
import 'insurance.dart';
import 'travel.dart';

/// FeedCard tipleri için "koleksiyona kaydedilebilir" opsiyonel yeteneği.
/// Bir kart türü koleksiyona eklenebilir olmak istiyorsa sadece bu arayüzü
/// implemente eder — merkezi bir switch'e dokunmasına gerek yoktur.
/// Implemente etmeyen kart türleri otomatik olarak generic bir önizleme
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

  /// "Sepete ekle" basılınca hangi sepete gideceğini belirler.
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

/// İkinci profil modülü: kullanıcının farklı bankalardaki hesapları ve
/// kredi kartları. Diğer profil modüllerinden (Temel Bilgiler vb.)
/// tamamen bağımsız — kendi rengi, kendi görünümü, kendi veri kaynağı
/// olacak (bkz. wallet_profile_card_view.dart).
class WalletProfileCard extends FeedCard implements Collectible {
  final List<BankAccount> accounts;
  final List<BankCreditCard> creditCards;

  const WalletProfileCard({
    required String id,
    this.accounts = const [],
    this.creditCards = const [],
  }) : super(id);

  // NOT: Şimdilik tüm hesapların TRY olduğu varsayılıyor — çoklu para
  // birimi toplamı (döviz kuru çevrimi) backend adımında ele alınacak.
  double get totalBalance => accounts.fold(0.0, (sum, a) => sum + a.balance);

  @override
  (String, String) toCollectionPreview() => ("Cüzdan Profili", "");
}

/// Üçüncü profil modülü: kullanıcının farklı şirketlerden aldığı aktif
/// sigorta poliçeleri. Diğer profil modüllerinden tamamen bağımsız.
class InsuranceProfileCard extends FeedCard implements Collectible {
  final List<InsurancePolicy> policies;

  const InsuranceProfileCard({required String id, this.policies = const []})
    : super(id);

  int get activeCount => policies.where((p) => p.isActive).length;

  @override
  (String, String) toCollectionPreview() => ("Sigorta Profili", "");
}

/// Dördüncü profil modülü: kullanıcının farklı şirketlerden aldığı araç
/// biletleri (uçak/otobüs/tren/feribot) — hem geçmiş hem yaklaşan.
/// Konaklama bilerek kapsam dışı; ayrı bir modül olarak eklenecek.
class TravelProfileCard extends FeedCard implements Collectible {
  final List<TravelTicket> tickets;

  const TravelProfileCard({required String id, this.tickets = const []})
    : super(id);

  List<TravelTicket> get upcoming =>
      tickets.where((t) => t.isUpcoming).toList()
        ..sort((a, b) => a.departureDateTime.compareTo(b.departureDateTime));

  List<TravelTicket> get past =>
      tickets.where((t) => !t.isUpcoming).toList()
        ..sort((a, b) => b.departureDateTime.compareTo(a.departureDateTime));

  /// Kalkışa 7 günden az kalan en yakın yolculuk — varsa uyarı banner'ı
  /// için kullanılır.
  TravelTicket? get nextAlertTicket {
    final soon = upcoming.where(
      (t) => t.departureDateTime.difference(DateTime.now()).inDays <= 7,
    );
    return soon.isEmpty ? null : soon.first;
  }

  @override
  (String, String) toCollectionPreview() => ("Seyahat Profili", "");
}

/// Kullanıcının dolu her sepeti için profil akışında gösterilen özet kart.
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
  final FeedCard originalCard; // koleksiyona eklenen orijinal kart referansı

  const CollectionItemCard({
    required String id,
    required this.title,
    required this.previewUrl,
    required this.originalCard,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (title, previewUrl);
}
