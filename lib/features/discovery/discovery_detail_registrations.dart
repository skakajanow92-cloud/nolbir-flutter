import '../../../core/layout/card_detail_registry.dart';
import '../../../models/feed_card/feed_card.dart';
import 'details/product_detail.dart';
import 'details/subscription_detail.dart';
import 'details/video_detail.dart';

/// Genel Akış (Discovery) kartlarının masaüstü detay paneli kayıtları. Bu
/// dosya SADECE kayıt satırlarını tutar; her kartın görünümü `details/`
/// altında kendi dosyasındadır.
///
/// Yeni bir kart türü için: `details/<kart>_detail.dart` içine
/// `build<Kart>Detail` yaz, buraya bir import ve bir `register` satırı ekle.
void registerDiscoveryCardDetails() {
  CardDetailRegistry.register<VideoCard>(buildVideoDetail);
  CardDetailRegistry.register<ProductCard>(buildProductDetail);
  CardDetailRegistry.register<SubscriptionCard>(buildSubscriptionDetail);
}
