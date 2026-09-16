import 'base.dart';
import '../estate.dart';

/// On üçüncü profil modülü: kullanıcının kayıtlı ikametgâh adresi ve
/// tapuda üzerine kayıtlı taşınmaz malvarlıkları (daire, arsa, dükkan...).
///
/// NOT: `registeredAddress` taşınmaz listesinden BİLİNÇLİ olarak ayrı —
/// kullanıcı sahibi olmadığı bir adreste ikamet ediyor olabilir
/// (bkz. estate.dart'taki aynı not).
class EstateProfileCard extends FeedCard implements Collectible {
  final RegisteredAddress? registeredAddress;
  final List<RealEstate> properties;

  const EstateProfileCard({
    required String id,
    this.registeredAddress,
    this.properties = const [],
  }) : super(id);

  /// Paya düşen güncel değerlerin toplamı — hisseli mülkiyette tam değer
  /// değil, kullanıcının payı toplanır (bkz. RealEstate.ownedValue).
  ///
  /// NOT: Şimdilik tüm taşınmazların TRY olduğu varsayılıyor; çoklu para
  /// birimi WalletProfileCard'daki gibi backend adımında ele alınacak.
  double get totalOwnedValue =>
      properties.fold(0.0, (sum, p) => sum + (p.ownedValue ?? 0));

  double get totalArea => properties.fold(0.0, (sum, p) => sum + p.areaSqm);

  int get rentedCount => properties.where((p) => p.isRentedOut).length;

  double get totalMonthlyRent => properties
      .where((p) => p.isRentedOut)
      .fold(0.0, (sum, p) => sum + (p.monthlyRent ?? 0));

  @override
  (String, String) toCollectionPreview() => ("Gayrimenkul Profili", "");
}