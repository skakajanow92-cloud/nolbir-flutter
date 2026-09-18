import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/smart_home.dart';

/// Akıllı Ev Yönetim Paneli — yirmi ikinci profil modülü.
///
/// TASARIM NOTU: Üç seviyeli veri (yapı → bölüm → cihaz) tek ekranda
/// gösterilemeyecek kadar derin — bu yüzden mini kart sadece yapı
/// özetini (bölüm sayısı, açık ışık/ısıtıcı sayısı) gösteriyor, bölüm
/// bölüm cihaz durumu ve ortam ölçümleri dokununca açılan
/// `BuildingControlSheet`te (Insurance/Channels/Estate'deki detay sheet
/// presedanı) listeleniyor.
///
/// Modül vurgu rengi: parlak turkuaz — Engagement modülünün soluk
/// tealinden (0xFF2E6E7A) ve Kargo modülünün lojistik mavisinden
/// (0xFF2E7BA6) ayrışan, daha canlı/"akıllı teknoloji" hissi veren ton.
class SmartHomeProfileCardView extends StatelessWidget {
  final SmartHomeProfileCard card;

  const SmartHomeProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF2FA8A3);
  static const _base = Color(0xFF0B1413);
  static const _baseEnd = Color(0xFF121D1C);

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
                  "Yapılarım (${card.buildings.length})",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: card.buildings.isEmpty
                    ? const _EmptyHint(text: "Henüz yapı eklenmedi")
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: card.buildings.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, i) =>
                            _BuildingMiniCard(building: card.buildings[i]),
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
  final SmartHomeProfileCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.home_max_outlined,
                color: SmartHomeProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Akıllı Ev", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${card.buildings.length} yapı",
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1.1),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final SmartHomeProfileCard card;
  const _StatsRow({required this.card});

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String)>[
      ("Bölüm", "${card.totalRooms}"),
      ("Açık Işık", "${card.totalLightsOn}"),
      ("Açık Isıtıcı", "${card.totalHeatersOn}"),
      ("Cihaz", "${card.totalDevices}"),
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
        color: SmartHomeProfileCardView.moduleAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: SmartHomeProfileCardView.moduleAccent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
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
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      ),
    );
  }
}

class _BuildingMiniCard extends StatelessWidget {
  final SmartBuilding building;
  const _BuildingMiniCard({required this.building});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(building.name);

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFor(building.type), color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(building.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(building.type.label,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const Spacer(),
            Text("${building.rooms.length} bölüm",
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 14, color: color),
                const SizedBox(width: 4),
                Text("${building.totalLightsOn} açık",
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Icon(Icons.thermostat_outlined, size: 14, color: color),
                const SizedBox(width: 4),
                Text("${building.totalHeatersOn} açık",
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121D1C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BuildingControlSheet(building: building),
    );
  }
}

/// Yapı mini kartına dokununca açılan bölüm bölüm kontrol paneli
/// (bkz. InsuranceProfileCardView/ChannelsProfileCardView'daki detay
/// sheet presedanı).
class BuildingControlSheet extends StatelessWidget {
  final SmartBuilding building;
  const BuildingControlSheet({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
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
                    child: Text(building.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              if (building.address != null) ...[
                const SizedBox(height: 4),
                Text(building.address!,
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              if (building.rooms.isEmpty)
                const Text("Henüz bölüm eklenmedi",
                    style: TextStyle(color: Colors.white38, fontSize: 13))
              else
                ...building.rooms.map((r) => _RoomSection(room: r)),
            ],
          ),
        );
      },
    );
  }
}

class _RoomSection extends StatelessWidget {
  final SmartRoom room;
  const _RoomSection({required this.room});

  @override
  Widget build(BuildContext context) {
    final reading = room.latestReading;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.meeting_room_outlined,
                    color: SmartHomeProfileCardView.moduleAccent, size: 17),
                const SizedBox(width: 8),
                Text(room.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
            if (reading != null) ...[
              const SizedBox(height: 8),
              _ReadingRow(reading: reading),
            ],
            if (room.lightingDevices.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...room.lightingDevices.map((l) => _DeviceRow(
                    icon: Icons.lightbulb_outline,
                    label: "${l.name} (${l.type.label})",
                    isOn: l.isOn,
                    extra: l.brightnessPercent != null ? "%${l.brightnessPercent}" : null,
                  )),
            ],
            if (room.heatingDevices.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...room.heatingDevices.map((h) => _DeviceRow(
                    icon: Icons.thermostat_outlined,
                    label: "${h.name} (${h.type.label})",
                    isOn: h.isOn,
                    extra: h.targetTemperature != null
                        ? "${h.targetTemperature!.toStringAsFixed(0)}°C"
                        : null,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  final EnvironmentReading reading;
  const _ReadingRow({required this.reading});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _ReadingItem(
            icon: Icons.device_thermostat,
            text: "${reading.temperatureC.toStringAsFixed(1)}°C"),
        _ReadingItem(
            icon: Icons.water_drop_outlined,
            text: "%${reading.humidityPercent.toStringAsFixed(0)} nem"),
        if (reading.pressureHpa != null)
          _ReadingItem(
              icon: Icons.speed_outlined,
              text: "${reading.pressureHpa!.toStringAsFixed(0)} hPa"),
      ],
    );
  }
}

class _ReadingItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ReadingItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: SmartHomeProfileCardView.moduleAccent),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final String? extra;
  const _DeviceRow({
    required this.icon,
    required this.label,
    required this.isOn,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOn ? SmartHomeProfileCardView.moduleAccent : Colors.white24;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isOn ? Colors.white : Colors.white38, fontSize: 13)),
          ),
          if (extra != null) ...[
            Text(extra!,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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

IconData _iconFor(BuildingType type) => switch (type) {
      BuildingType.villa => Icons.villa_outlined,
      BuildingType.house => Icons.house_outlined,
      BuildingType.apartment => Icons.apartment_outlined,
      BuildingType.office => Icons.business_outlined,
    };

// Yapı adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF1F5A55),
  Color(0xFF3E4A5A),
  Color(0xFF4A5A3E),
  Color(0xFF5A4A3E),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}
