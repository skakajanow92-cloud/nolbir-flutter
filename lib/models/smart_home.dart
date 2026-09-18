/// Yapı türü.
enum BuildingType { villa, house, apartment, office }

extension BuildingTypeLabel on BuildingType {
  String get label => switch (this) {
        BuildingType.villa => "Villa",
        BuildingType.house => "Ev",
        BuildingType.apartment => "Daire",
        BuildingType.office => "Ofis",
      };
}

/// Aydınlatma cihazı türü.
enum LightingType { chandelier, led, spot, bulb }

extension LightingTypeLabel on LightingType {
  String get label => switch (this) {
        LightingType.chandelier => "Avize",
        LightingType.led => "LED Şerit",
        LightingType.spot => "Spot",
        LightingType.bulb => "Ampul",
      };
}

/// Bir bölümdeki tek bir aydınlatma cihazı.
class LightingDevice {
  final String id;
  final String name; // örn. "Salon Ana Avize"
  final LightingType type;
  final bool isOn;
  final int? brightnessPercent; // 0-100, dimmer destekliyorsa

  const LightingDevice({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.brightnessPercent,
  });
}

/// Isıtma/soğutma cihazı türü.
enum HeatingType { boiler, ac, underfloor, radiator, heaterPanel }

extension HeatingTypeLabel on HeatingType {
  String get label => switch (this) {
        HeatingType.boiler => "Kombi",
        HeatingType.ac => "Klima",
        HeatingType.underfloor => "Yerden Isıtma",
        HeatingType.radiator => "Radyatör",
        HeatingType.heaterPanel => "Isıtıcı Panel",
      };
}

/// Bir bölümdeki tek bir ısıtma/soğutma cihazı.
class HeatingDevice {
  final String id;
  final String name;
  final HeatingType type;
  final bool isOn;
  final double? targetTemperature; // °C, ayarlanmışsa

  const HeatingDevice({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.targetTemperature,
  });
}

/// Bir bölümün en son ortam ölçümü.
///
/// BİLİNÇLİ TASARIM KARARI: Ölçüm bina genelinde TEK bir değer değil,
/// her `SmartRoom`un KENDİ `EnvironmentReading`i var — mutfak ile banyo
/// aynı anda çok farklı sıcaklık/nemde olabilir (bkz. SmartRoom).
class EnvironmentReading {
  final double temperatureC;
  final double humidityPercent;
  final double? pressureHpa;
  final DateTime measuredAt;

  const EnvironmentReading({
    required this.temperatureC,
    required this.humidityPercent,
    this.pressureHpa,
    required this.measuredAt,
  });
}

/// Bir yapının tek bir bölümü/odası (mutfak, salon, banyo...).
class SmartRoom {
  final String id;
  final String name; // örn. "Mutfak", "Ana Yatak Odası"
  final List<LightingDevice> lightingDevices;
  final List<HeatingDevice> heatingDevices;
  final EnvironmentReading? latestReading;

  const SmartRoom({
    required this.id,
    required this.name,
    this.lightingDevices = const [],
    this.heatingDevices = const [],
    this.latestReading,
  });

  int get lightsOnCount => lightingDevices.where((l) => l.isOn).length;
  int get heatersOnCount => heatingDevices.where((h) => h.isOn).length;
  int get deviceCount => lightingDevices.length + heatingDevices.length;
}

/// Kullanıcının yönettiği tek bir yapı (villa, ev, ofis...) ve o yapının
/// bölümleri.
class SmartBuilding {
  final String id;
  final String name; // kullanıcının verdiği ad, örn. "Yazlık Villa"
  final BuildingType type;
  final String? address;
  final List<SmartRoom> rooms;

  const SmartBuilding({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.rooms = const [],
  });

  int get totalLightsOn => rooms.fold(0, (sum, r) => sum + r.lightsOnCount);
  int get totalHeatersOn => rooms.fold(0, (sum, r) => sum + r.heatersOnCount);
  int get totalDevices => rooms.fold(0, (sum, r) => sum + r.deviceCount);
}
