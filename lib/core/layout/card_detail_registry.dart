import 'package:flutter/widgets.dart';
import '../../models/feed_card/feed_card.dart';

typedef CardDetailBuilder<T extends FeedCard> = Widget Function(
    BuildContext context, T card);

/// Masaüstündeki detay paneli için `CardViewRegistry`'nin paralel karşılığı.
/// Aynı kayıt/fallback ilkesi: bir kart türü panelde ek bilgi göstermek
/// istiyorsa SADECE buraya kayıt olur; kayıt etmeyen türler otomatik olarak
/// genel bir önizleme alır (bkz. detail_panel.dart). Merkezi switch yok.
class CardDetailRegistry {
  CardDetailRegistry._();

  static final Map<Type, Widget Function(BuildContext, FeedCard)> _builders =
      {};

  static void register<T extends FeedCard>(CardDetailBuilder<T> builder) {
    _builders[T] = (context, card) => builder(context, card as T);
  }

  /// Kayıtlı bir detay görünümü varsa üretir, yoksa `null` döner.
  /// Koleksiyondaki kartlar (`CollectionItemCard`) sarmalayıcıdır: kendi
  /// kaydı yoksa içindeki orijinal kartın detayı gösterilir.
  static Widget? build(BuildContext context, FeedCard card) {
    final builder = _builders[card.runtimeType];
    if (builder != null) return builder(context, card);
    if (card is CollectionItemCard) return build(context, card.originalCard);
    return null;
  }
}
