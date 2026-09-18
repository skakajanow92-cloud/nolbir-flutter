import 'base.dart';
import '../cargo.dart';

/// On sekizinci profil modülü: kullanıcının kargo gönderileri — geçmiş
/// gönderiler ve devam eden gönderilerin takip/konum bilgisi, favori
/// kargo firmaları ve kuryeler.
///
/// NOT: Devam eden/geçmiş ayrımı `Shipment.status.isFinal`e dayanır —
/// Travel/Accommodation/Health/Event modüllerindeki tarih bazlı geçmiş/
/// yaklaşan ayrımından FARKLI olarak burada durum (status) belirleyici,
/// çünkü kargonun "ne zaman" değil "nerede/hangi aşamada" olduğu önemli.
class CargoProfileCard extends FeedCard implements Collectible {
  final List<Shipment> shipments;
  final List<FavoriteCargoCompany> favoriteCompanies;
  final List<FavoriteCourier> favoriteCouriers;

  const CargoProfileCard({
    required String id,
    this.shipments = const [],
    this.favoriteCompanies = const [],
    this.favoriteCouriers = const [],
  }) : super(id);

  List<Shipment> get activeShipments =>
      shipments.where((s) => s.isActive).toList()
        ..sort((a, b) => a.createdDate.compareTo(b.createdDate));

  List<Shipment> get pastShipments =>
      shipments.where((s) => !s.isActive).toList()
        ..sort((a, b) => b.createdDate.compareTo(a.createdDate));

  @override
  (String, String) toCollectionPreview() => ("Kargo Profili", "");
}
