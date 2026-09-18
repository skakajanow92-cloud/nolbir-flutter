import 'base.dart';
import '../smart_home.dart';

/// Yirmi ikinci profil modülü: kullanıcının akıllı ev yönetimi — yapıları
/// (villa/ev/ofis), her yapının bölümleri (mutfak/salon/banyo), bölüm
/// bazlı aydınlatma/ısıtma cihazları ve ortam ölçümleri (sıcaklık/nem/
/// basınç).
///
/// NOT: Üç seviyeli veri (yapı → bölüm → cihaz) — bkz. smart_home.dart.
/// Ortam ölçümü bina genelinde tek değer değil, her bölümün kendi
/// `EnvironmentReading`i var.
class SmartHomeProfileCard extends FeedCard implements Collectible {
  final List<SmartBuilding> buildings;

  const SmartHomeProfileCard({required String id, this.buildings = const []})
    : super(id);

  int get totalRooms => buildings.fold(0, (sum, b) => sum + b.rooms.length);

  int get totalLightsOn =>
      buildings.fold(0, (sum, b) => sum + b.totalLightsOn);

  int get totalHeatersOn =>
      buildings.fold(0, (sum, b) => sum + b.totalHeatersOn);

  int get totalDevices => buildings.fold(0, (sum, b) => sum + b.totalDevices);

  @override
  (String, String) toCollectionPreview() => ("Akıllı Ev Profili", "");
}