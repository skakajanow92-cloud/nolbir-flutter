import 'package:flutter/material.dart';
import '../../models/feed_card/feed_card.dart';

typedef CardViewBuilder =
    Widget Function(BuildContext context, FeedCard card, bool isActive);

/// TÜM kart türleri için tek merkezi kayıt noktası.
///
/// BİLİNÇLİ TASARIM KARARI: `FeedCard` artık `sealed` DEĞİL, kasıtlı olarak
/// açık (`abstract`) bir sınıf. Kart türü sayısı büyük ve açık uçlu —
/// profil modülleri (bankacılık, sağlık, seyahat, yemek, konaklama,
/// eğitim...) ve akış kaynakları (video, satıcı ürün karuseli, kurumsal
/// ders listesi, otel rezervasyonu...) zamanla sınırsız artacak. `sealed` +
/// switch kullansaydık her yeni kart türünde bu dosyaya VE başka
/// switch'lere (bkz. eski collection_item_builder) dokunman gerekirdi.
/// Bunun yerine `CartType`/`CartVisuals`/`CartItemRegistry`'de kullandığımız
/// registry+fallback felsefesini burada da uyguluyoruz: her feature kendi
/// kart görünümünü kaydeder, bu dosya hiç büyümez.
///
/// Kayıt yoksa bile `UnknownCardView` devreye girer — yani "bugün
/// bilmediğimiz" bir kart türü bile UI'ı çökertmeden çalışır.
class CardViewRegistry {
  CardViewRegistry._();

  static final Map<Type, CardViewBuilder> _builders = {};

  /// Belirli bir `FeedCard` alt türü için görünüm kaydet.
  /// Örnek:
  /// ```dart
  /// CardViewRegistry.register<HotelBookingCard>(
  ///   (context, card, isActive) =>
  ///       HotelBookingCardView(card: card as HotelBookingCard),
  /// );
  /// ```
  static void register<T extends FeedCard>(CardViewBuilder builder) {
    _builders[T] = builder;
  }

  static Widget build(BuildContext context, FeedCard card, bool isActive) {
    final builder = _builders[card.runtimeType];
    if (builder != null) return builder(context, card, isActive);
    return UnknownCardView(card: card); // fallback — kod değişikliği gerekmez
  }
}

/// Kayıtlı bir görünümü olmayan kart türleri için fallback.
/// Üretimde bunu görüyorsan o kart türü için henüz
/// `CardViewRegistry.register` çağrılmamış demektir — geliştirme sırasında
/// fark edilsin diye bilerek göze çarpan bir görünüm.
class UnknownCardView extends StatelessWidget {
  final FeedCard card;
  const UnknownCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.help_outline, color: Colors.white38, size: 48),
          const SizedBox(height: 12),
          Text(
            "Görünüm kayıtlı değil: ${card.runtimeType}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
