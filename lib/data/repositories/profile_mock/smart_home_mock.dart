import '../../../models/feed_card/feed_card.dart';
import '../../../models/smart_home.dart';

SmartHomeProfileCard buildSmartHomeMock() {
  return SmartHomeProfileCard(
    id: "smarthome1",
    buildings: [
      SmartBuilding(
        id: "bld1",
        name: "Yazlık Villa",
        type: BuildingType.villa,
        address: "Bodrum, Muğla",
        rooms: [
          SmartRoom(
            id: "rm1",
            name: "Salon",
            lightingDevices: const [
              LightingDevice(
                id: "lt1",
                name: "Salon Ana Avize",
                type: LightingType.chandelier,
                isOn: true,
                brightnessPercent: 70,
              ),
              LightingDevice(
                id: "lt2",
                name: "Tavan Spotları",
                type: LightingType.spot,
                isOn: false,
              ),
            ],
            heatingDevices: const [
              HeatingDevice(
                id: "ht1",
                name: "Salon Klima",
                type: HeatingType.ac,
                isOn: true,
                targetTemperature: 23,
              ),
            ],
            latestReading: EnvironmentReading(
              temperatureC: 24.2,
              humidityPercent: 48,
              pressureHpa: 1013,
              measuredAt: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
          ),
          SmartRoom(
            id: "rm2",
            name: "Mutfak",
            lightingDevices: const [
              LightingDevice(
                id: "lt3",
                name: "Tezgah Üstü LED",
                type: LightingType.led,
                isOn: true,
                brightnessPercent: 90,
              ),
            ],
            latestReading: EnvironmentReading(
              temperatureC: 25.6,
              humidityPercent: 55,
              measuredAt: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
          ),
          SmartRoom(
            id: "rm3",
            name: "Banyo",
            heatingDevices: const [
              HeatingDevice(
                id: "ht2",
                name: "Yerden Isıtma",
                type: HeatingType.underfloor,
                isOn: false,
              ),
            ],
            latestReading: EnvironmentReading(
              temperatureC: 22.1,
              humidityPercent: 62,
              measuredAt: DateTime.now().subtract(const Duration(minutes: 20)),
            ),
          ),
        ],
      ),
      SmartBuilding(
        id: "bld2",
        name: "Ofis",
        type: BuildingType.office,
        address: "Levent, İstanbul",
        rooms: [
          SmartRoom(
            id: "rm4",
            name: "Toplantı Odası",
            lightingDevices: const [
              LightingDevice(
                id: "lt4",
                name: "Tavan LED Paneli",
                type: LightingType.led,
                isOn: true,
                brightnessPercent: 100,
              ),
            ],
            latestReading: EnvironmentReading(
              temperatureC: 21.8,
              humidityPercent: 40,
              pressureHpa: 1011,
              measuredAt: DateTime.now().subtract(const Duration(minutes: 2)),
            ),
          ),
        ],
      ),
    ],
  );
}
