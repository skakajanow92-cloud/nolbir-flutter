import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/vehicle.dart';

/// Akıllı Araç Profili — yirmi üçüncü profil modülü.
///
/// TASARIM NOTU: SmartHome modülündeki aynı gerekçeyle, araç mini kartı
/// sadece özet (yakıt/uyarı durumu) gösteriyor; kabin/motor okumaları ve
/// cihaz kontrolü dokununca açılan `VehicleControlSheet`te (Insurance/
/// Channels/Estate/SmartHome'daki detay sheet presedanı) listeleniyor.
///
/// Modül vurgu rengi: çelik mavisi — Sigorta modülünün indigosundan
/// (0xFF3A4E7A) ve Kargo modülünün lojistik mavisinden (0xFF2E7BA6)
/// ayrışan, "gösterge paneli" hissi veren ton.
class VehicleProfileCardView extends StatelessWidget {
  final VehicleProfileCard card;

  const VehicleProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF4A6FA5);
  static const _base = Color(0xFF0E1116);
  static const _baseEnd = Color(0xFF161B23);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Header(card: card),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsRow(card: card),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Araçlarım (${card.vehicles.length})",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: card.vehicles.isEmpty
                    ? const _EmptyHint(text: "Henüz araç eklenmedi")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: card.vehicles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) =>
                            _VehicleMiniCard(vehicle: card.vehicles[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VehicleProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.directions_car_filled_outlined,
              color: VehicleProfileCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Akıllı Araç",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${card.vehicles.length} araç",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final VehicleProfileCard card;
  const _StatsRow({required this.card});

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String)>[
      ("Kayıtlı", "${card.registeredToUserCount}"),
      ("Kullanılan", "${card.vehicles.length - card.registeredToUserCount}"),
      ("Açık Cihaz", "${card.totalDevicesOn}"),
      ("Uyarı", "${card.totalActiveAlerts}"),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: stats.map((s) => _StatChip(label: s.$1, value: s.$2)).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: VehicleProfileCardView.moduleAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: VehicleProfileCardView.moduleAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ),
    );
  }
}

class _VehicleMiniCard extends StatelessWidget {
  final SmartVehicle vehicle;
  const _VehicleMiniCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(vehicle.plate);
    final alerts = vehicle.activeAlerts;
    final engine = vehicle.engineReading;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: alerts.isNotEmpty
                ? const Color(0xFFE0A030).withValues(alpha: 0.6)
                : color.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFor(vehicle.type), color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vehicle.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (alerts.isNotEmpty)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE0A030),
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "${vehicle.plate} · ${vehicle.type.label}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            _OwnershipBadge(vehicle: vehicle),
            const Spacer(),
            if (engine != null) ...[
              _MiniGauge(
                label: "Yakıt",
                percent: engine.fuelPercent,
                color: color,
              ),
              const SizedBox(height: 4),
              _MiniGauge(
                label: "Yağ",
                percent: engine.oilQualityPercent,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B23),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VehicleControlSheet(vehicle: vehicle),
    );
  }
}

class _OwnershipBadge extends StatelessWidget {
  final SmartVehicle vehicle;
  const _OwnershipBadge({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final text = vehicle.isRegisteredToUser
        ? "Adıma Kayıtlı"
        : (vehicle.registeredOwnerName != null
              ? "${vehicle.registeredOwnerName} adına"
              : "Kullanıyorum");

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.white38, fontSize: 11),
    );
  }
}

class _MiniGauge extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _MiniGauge({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0, 1),
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                percent < 20 ? const Color(0xFFD98A7F) : color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "%${percent.toStringAsFixed(0)}",
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

/// Araç mini kartına dokununca açılan tam kontrol paneli — kabin/motor
/// okumaları ve cihaz durumu (bkz. SmartHomeProfileCardView'daki
/// BuildingControlSheet presedanı).
class VehicleControlSheet extends StatelessWidget {
  final SmartVehicle vehicle;
  const VehicleControlSheet({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final cabin = vehicle.cabinReading;
    final engine = vehicle.engineReading;
    final alerts = vehicle.activeAlerts;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      vehicle.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                "${vehicle.plate} · ${vehicle.type.label}",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 14),
                ...alerts.map((a) => _AlertRow(text: a)),
              ],
              if (engine != null) ...[
                const SizedBox(height: 18),
                const _GroupLabel(text: "Motor"),
                _DetailRow(
                  label: "Motor Sıcaklığı",
                  value: "${engine.temperatureC.toStringAsFixed(0)}°C",
                ),
                _DetailRow(
                  label: "Yağ Kalitesi",
                  value: "%${engine.oilQualityPercent.toStringAsFixed(0)}",
                ),
                _DetailRow(
                  label: "Yakıt Miktarı",
                  value: "%${engine.fuelPercent.toStringAsFixed(0)}",
                ),
              ],
              if (cabin != null) ...[
                const SizedBox(height: 18),
                const _GroupLabel(text: "Kabin Konforu"),
                _DetailRow(
                  label: "Sıcaklık",
                  value: "${cabin.temperatureC.toStringAsFixed(1)}°C",
                ),
                _DetailRow(
                  label: "Nem",
                  value: "%${cabin.humidityPercent.toStringAsFixed(0)}",
                ),
                if (cabin.pressureHpa != null)
                  _DetailRow(
                    label: "Basınç",
                    value: "${cabin.pressureHpa!.toStringAsFixed(0)} hPa",
                  ),
                if (cabin.airQualityIndex != null)
                  _DetailRow(
                    label: "Hava Kalitesi İndeksi",
                    value: "${cabin.airQualityIndex}",
                  ),
                _DetailRow(
                  label: "Duman Algılama",
                  value: cabin.smokeDetected ? "Algılandı" : "Temiz",
                ),
                if (cabin.alcoholLevel != null)
                  _DetailRow(
                    label: "Alkol Seviyesi",
                    value: "${cabin.alcoholLevel!.toStringAsFixed(2)} mg/L",
                  ),
              ],
              if (vehicle.devices.isNotEmpty) ...[
                const SizedBox(height: 18),
                const _GroupLabel(text: "Cihazlar"),
                ...vehicle.devices.map((d) => _DeviceRow(device: d)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String text;
  const _AlertRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE0A030),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFFE0A030), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: VehicleProfileCardView.moduleAccent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final VehicleDevice device;
  const _DeviceRow({required this.device});

  @override
  Widget build(BuildContext context) {
    final color = device.isOn
        ? VehicleProfileCardView.moduleAccent
        : Colors.white24;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(_iconForDevice(device.type), size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${device.name} (${device.type.label})",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: device.isOn ? Colors.white : Colors.white38,
                fontSize: 13,
              ),
            ),
          ),
          if (device.level != null) ...[
            Text(
              "%${device.level}",
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(VehicleType type) => switch (type) {
  VehicleType.suv => Icons.directions_car_filled_outlined,
  VehicleType.car => Icons.directions_car_outlined,
  VehicleType.motorcycle => Icons.two_wheeler_outlined,
  VehicleType.heavyEquipment => Icons.agriculture_outlined,
};

IconData _iconForDevice(VehicleDeviceType type) => switch (type) {
  VehicleDeviceType.airPurifier => Icons.air_outlined,
  VehicleDeviceType.climate => Icons.ac_unit_outlined,
  VehicleDeviceType.seatHeater => Icons.event_seat_outlined,
};

// Plaka başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF2E4A6F),
  Color(0xFF4A3E5A),
  Color(0xFF2E5A4A),
  Color(0xFF5A3E3E),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}
