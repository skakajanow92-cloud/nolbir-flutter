import '../../../models/feed_card/feed_card.dart';
import '../../../models/vehicle.dart';

VehicleProfileCard buildVehicleMock() {
  return VehicleProfileCard(
    id: "vehicle1",
    vehicles: [
      SmartVehicle(
        id: "veh1",
        brand: "Volkswagen",
        model: "Tiguan",
        type: VehicleType.suv,
        plate: "34 XYZ 456",
        color: "Gri",
        isRegisteredToUser: true,
        cabinReading: CabinReading(
          temperatureC: 22.5,
          humidityPercent: 42,
          pressureHpa: 1012,
          airQualityIndex: 38,
          smokeDetected: false,
          alcoholLevel: 0.0,
          measuredAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        engineReading: EngineReading(
          temperatureC: 91,
          oilQualityPercent: 68,
          fuelPercent: 54,
          measuredAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        devices: const [
          VehicleDevice(
            id: "vd1",
            name: "Ön Panel Klima",
            type: VehicleDeviceType.climate,
            isOn: true,
            level: 60,
          ),
          VehicleDevice(
            id: "vd2",
            name: "Kabin Hava Temizleyici",
            type: VehicleDeviceType.airPurifier,
            isOn: false,
          ),
        ],
      ),
      SmartVehicle(
        id: "veh2",
        brand: "Honda",
        model: "PCX 150",
        type: VehicleType.motorcycle,
        plate: "34 ABC 789",
        isRegisteredToUser: true,
        engineReading: EngineReading(
          temperatureC: 88,
          oilQualityPercent: 12,
          fuelPercent: 9,
          measuredAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ),
      SmartVehicle(
        id: "veh3",
        brand: "Ford",
        model: "Transit",
        type: VehicleType.heavyEquipment,
        plate: "06 FLT 021",
        isRegisteredToUser: false,
        registeredOwnerName: "Şirket Filosu",
        cabinReading: CabinReading(
          temperatureC: 26.1,
          humidityPercent: 50,
          smokeDetected: true,
          measuredAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        engineReading: EngineReading(
          temperatureC: 96,
          oilQualityPercent: 74,
          fuelPercent: 61,
          measuredAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
      ),
    ],
  );
}
