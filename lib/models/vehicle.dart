/// Araç türü.
enum VehicleType { suv, car, motorcycle, heavyEquipment }

extension VehicleTypeLabel on VehicleType {
  String get label => switch (this) {
        VehicleType.suv => "SUV",
        VehicleType.car => "Otomobil",
        VehicleType.motorcycle => "Motosiklet",
        VehicleType.heavyEquipment => "İş Makinesi",
      };
}

/// Aracın en güncel kabin konforu ölçümü.
///
/// BİLİNÇLİ TASARIM KARARI: Liste değil TEK bir nesne — Taksi
/// modülündeki `CurrentLocation` ile aynı mantık: sensör her okumada
/// bu alanı günceller, geçmiş okumaların tutulması bu modülün kapsamı
/// dışında (araç "şu an" durumunu gösteriyor).
class CabinReading {
  final double temperatureC;
  final double humidityPercent;
  final double? pressureHpa;
  final int? airQualityIndex; // 0-500, düşük daha temiz hava
  final bool smokeDetected;
  final double? alcoholLevel; // mg/L, kabin havası alkol sensörü
  final DateTime measuredAt;

  const CabinReading({
    required this.temperatureC,
    required this.humidityPercent,
    this.pressureHpa,
    this.airQualityIndex,
    this.smokeDetected = false,
    this.alcoholLevel,
    required this.measuredAt,
  });
}

/// Aracın en güncel motor bilgileri.
class EngineReading {
  final double temperatureC;
  final double oilQualityPercent; // 0-100, yağ ömrü/kalitesi
  final double fuelPercent; // 0-100
  final DateTime measuredAt;

  const EngineReading({
    required this.temperatureC,
    required this.oilQualityPercent,
    required this.fuelPercent,
    required this.measuredAt,
  });
}

/// Araca takılı, kontrol edilebilir bir cihaz türü.
enum VehicleDeviceType { airPurifier, climate, seatHeater }

extension VehicleDeviceTypeLabel on VehicleDeviceType {
  String get label => switch (this) {
        VehicleDeviceType.airPurifier => "Hava Temizleyici",
        VehicleDeviceType.climate => "Klima",
        VehicleDeviceType.seatHeater => "Koltuk Isıtıcı",
      };
}

/// Araca takılı tek bir kontrol edilebilir cihaz (sensör/mikrokontrolcü
/// üzerinden yönetilen).
class VehicleDevice {
  final String id;
  final String name;
  final VehicleDeviceType type;
  final bool isOn;
  final int? level; // 0-100, fan/ısıtma seviyesi gibi

  const VehicleDevice({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.level,
  });
}

/// Kullanıcının kendi adına kayıtlı olan ya da sadece kullandığı tek bir
/// araç (marka/model/tür fark etmeksizin).
class SmartVehicle {
  final String id;
  final String brand;
  final String model;
  final VehicleType type;
  final String plate;
  final String? color;

  /// NOT: Araç kullanıcının ADINA kayıtlı olmayabilir (şirket aracı,
  /// aile aracı vb.) — bu yüzden mülkiyet ile kullanım BİLİNÇLİ olarak
  /// ayrı tutuluyor (bkz. estate.dart'taki RegisteredAddress/mülkiyet
  /// ayrımıyla aynı yaklaşım).
  final bool isRegisteredToUser;
  final String? registeredOwnerName; // isRegisteredToUser == false ise anlamlı

  final CabinReading? cabinReading;
  final EngineReading? engineReading;
  final List<VehicleDevice> devices;

  const SmartVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    required this.plate,
    this.color,
    this.isRegisteredToUser = true,
    this.registeredOwnerName,
    this.cabinReading,
    this.engineReading,
    this.devices = const [],
  });

  String get fullName => "$brand $model";

  int get devicesOnCount => devices.where((d) => d.isOn).length;

  /// Basit eşik tabanlı uyarı listesi — TEŞHİS değil, nötr bir kontrol
  /// listesi. Eşikler kasten muhafazakâr/genel tutuldu.
  List<String> get activeAlerts {
    final alerts = <String>[];
    final engine = engineReading;
    final cabin = cabinReading;

    if (engine != null) {
      if (engine.fuelPercent < 15) alerts.add("Düşük yakıt seviyesi");
      if (engine.oilQualityPercent < 20) alerts.add("Yağ kalitesi düşük");
      if (engine.temperatureC > 105) alerts.add("Motor sıcaklığı yüksek");
    }
    if (cabin != null) {
      if (cabin.smokeDetected) alerts.add("Kabin içinde duman algılandı");
      if (cabin.alcoholLevel != null && cabin.alcoholLevel! > 0) {
        alerts.add("Kabin havasında alkol algılandı");
      }
    }
    return alerts;
  }
}
