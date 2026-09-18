import 'base.dart';
import '../vehicle.dart';

/// Yirmi üçüncü profil modülü: kullanıcının adına kayıtlı olan ya da
/// kullandığı araçlar (SUV/otomobil/motosiklet/iş makinesi) — sensör/
/// mikrokontrolcü üzerinden kabin konforu ve motor bilgileri, ayrıca
/// hava temizleyici/klima gibi kontrol edilebilir cihazlar.
///
/// NOT: Mülkiyet ile kullanım BİLİNÇLİ olarak ayrı (bkz. vehicle.dart'taki
/// isRegisteredToUser/registeredOwnerName) — araç şirket ya da aile
/// aracı olabilir, kullanıcının adına kayıtlı olmak zorunda değil.
class VehicleProfileCard extends FeedCard implements Collectible {
  final List<SmartVehicle> vehicles;

  const VehicleProfileCard({required String id, this.vehicles = const []})
    : super(id);

  int get registeredToUserCount =>
      vehicles.where((v) => v.isRegisteredToUser).length;

  int get totalDevicesOn =>
      vehicles.fold(0, (sum, v) => sum + v.devicesOnCount);

  int get totalActiveAlerts =>
      vehicles.fold(0, (sum, v) => sum + v.activeAlerts.length);

  @override
  (String, String) toCollectionPreview() => ("Akıllı Araç Profili", "");
}
