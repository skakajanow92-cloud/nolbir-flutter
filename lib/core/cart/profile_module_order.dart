import '../../models/feed_card.dart';

/// Profil akışındaki kart türlerinin görüntülenme SIRASINI belirleyen
/// registry. `CardViewRegistry`'nin sıralama karşılığı.
///
/// KURAL: Bir türü hangi sırada `register<T>()` edersen, profil akışında
/// o türe ait kartlar o sırada çıkar. Ayrı bir "öncelik numarası" tutmaya
/// gerek yok — kayıt sırası zaten sıralamanın kendisi.
///
/// Örnek: `registerAllCardViews()` içinde
/// `registerProfileCardViews()` (Kimlik, Cüzdan, Sigorta, Paylaşımlar sırayla
/// register ediyor) `registerCartCardViews()`'ten (CartSummaryCard'ı
/// register ediyor) ÖNCE çağrıldığı için, sepet özetleri otomatik olarak
/// en sonda çıkar — `ProfileFeed`'in kendisine hiç dokunmadan.
///
/// Kayıtlı olmayan bir tür varsa (yeni bir modül eklenip register etmeyi
/// unutursan), o kartlar listenin EN SONUNA, orijinal sıralarını koruyarak
/// eklenir — akış çökmez, sadece istediğin konumda çıkmaz (geliştirme
/// sırasında fark edilsin diye sessizce yutulmaz, sadece sona düşer).
class ProfileModuleOrder {
  ProfileModuleOrder._();

  static final List<Type> _order = [];

  static void register<T extends FeedCard>() {
    if (!_order.contains(T)) _order.add(T);
  }

  static List<FeedCard> sort(List<FeedCard> cards) {
    final grouped = <Type, List<FeedCard>>{};
    final unregistered = <FeedCard>[];

    for (final card in cards) {
      final type = card.runtimeType;
      if (_order.contains(type)) {
        grouped.putIfAbsent(type, () => []).add(card);
      } else {
        unregistered.add(card);
      }
    }

    final result = <FeedCard>[];
    for (final type in _order) {
      result.addAll(grouped[type] ?? const []);
    }
    result.addAll(unregistered);
    return result;
  }
}
