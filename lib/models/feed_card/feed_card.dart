/// Bu dosya artık sınıf tanımı BARINDIRMIYOR — sadece bu klasördeki
/// (models/feed_card/) tüm dosyaları tek noktadan dışa açan bir barrel
/// (export) dosyası. Eskiden bu dosyanın olduğu yerden
/// `import 'feed_card.dart';` diyen kodların artık
/// `import 'feed_card/feed_card.dart';` demesi yeterli — tüm kart
/// tiplerine (FeedCard, Collectible, VideoCard, ProductCard, ...) yine
/// tek bir import ile erişilir.
///
/// Yeni bir kart tipi eklerken: bu klasöre yeni dosyayı ekle, aşağıya
/// bir `export` satırı ekle. Merkezi bir switch'e dokunmana gerek yok
/// (bkz. base.dart'taki FeedCard/Collectible yorumları).
library;

export 'base.dart';

// --- ORTA TAB (Genel Akış) ---
export 'video_card.dart';
export 'product_card.dart';
export 'subscription_card.dart';

// --- SOL TAB (Profil) ---
export 'profile_header_card.dart';
export 'user_post_card.dart';
export 'wallet_profile_card.dart';
export 'insurance_profile_card.dart';
export 'travel_profile_card.dart';
export 'accommodation_profile_card.dart';
export 'food_profile_card.dart';
export 'donation_profile_card.dart';
export 'engagement_profile_card.dart';
export 'career_profile_card.dart';
export 'dating_profile_card.dart';
export 'cart_summary_card.dart';
export 'collection_item_card.dart';
export 'channels_profile_card.dart';
export 'streaming_profile_card.dart';
export 'education_profile_card.dart';
export 'health_profile_card.dart';
export 'event_profile_card.dart';
export 'estate_profile_card.dart';
export 'taxi_profile_card.dart';
