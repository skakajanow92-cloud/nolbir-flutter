import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/taxi.dart';

/// Taksi Profili — on dördüncü profil modülü.
///
/// TASARIM NOTU: Beş alt bölümü var (konum/mesafeler, sık rotalar,
/// saatlik yoğunluk, planlı yolculuklar, favori sürücüler) — Food/Career/
/// Health modüllerindeki aynı gerekçeyle dikey `SingleChildScrollView`
/// kullanıldı.
///
/// Saatlik yoğunluk, harici bir grafik kütüphanesi kullanılmadan basit
/// renk-yoğunluğu kartlarıyla gösteriliyor (bkz. diğer modüllerdeki
/// LinearProgressIndicator tercihi — projede zaten grafik kütüphanesi
/// kullanılmıyor).
///
/// Modül vurgu rengi: taksi sarısı — projede ilk kez kullanılan sıcak/
/// parlak ton, bilerek "taksi" çağrışımı için seçildi.
class TaxiProfileCardView extends StatelessWidget {
  final TaxiProfileCard card;

  const TaxiProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFFD9A62E);
  static const _base = Color(0xFF13110A);
  static const _baseEnd = Color(0xFF1C1810);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final location = card.currentLocation;
    final busiest = card.busiestHour;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(location: location),
                ),
                if (busiest != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _BusiestHourBanner(activity: busiest),
                  ),
                ],
                const SizedBox(height: 22),
                _SectionLabel(text: "Kayıtlı Yerlere Mesafe (${card.savedPlaces.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 108,
                  child: (location == null || card.savedPlaces.isEmpty)
                      ? const _EmptyHint(text: "Konum ya da kayıtlı yer yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.savedPlaces.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => _DistanceMiniCard(
                              place: card.savedPlaces[i], location: location),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Sık Kullandığım Rotalar (${card.frequentRoutes.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: card.frequentRoutes.isEmpty
                      ? const _EmptyHint(text: "Henüz sık kullanılan rota yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.frequentRoutes.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _RouteMiniCard(route: card.frequentRoutes[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Saatlik Yoğunluk"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 96,
                  child: card.hourlyActivity.isEmpty
                      ? const _EmptyHint(text: "Henüz yolculuk geçmişi yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.hourlyActivity.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => _HourBar(
                            activity: card.hourlyActivity[i],
                            maxCount: card.maxHourlyRideCount,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Planlı Yolculuklarım (${card.scheduledRides.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 108,
                  child: card.scheduledRides.isEmpty
                      ? const _EmptyHint(text: "Planlı/düzenli yolculuk yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.scheduledRides.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _ScheduledRideMiniCard(ride: card.scheduledRides[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: "Favori Sürücülerim (${card.favoriteDrivers.length})"),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: card.favoriteDrivers.isEmpty
                      ? const _EmptyHint(text: "Henüz favori sürücü eklenmedi")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.favoriteDrivers.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _DriverMiniCard(driver: card.favoriteDrivers[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CurrentLocation? location;
  const _Header({required this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.local_taxi_outlined,
                color: TaxiProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Taksi", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          location?.label ?? "Konum paylaşılmıyor",
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, height: 1.15),
        ),
        if (location != null) ...[
          const SizedBox(height: 2),
          Text("son güncelleme: ${_formatDateTime(location!.updatedAt)}",
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ],
    );
  }
}

class _BusiestHourBanner extends StatelessWidget {
  final HourlyRideActivity activity;
  const _BusiestHourBanner({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TaxiProfileCardView.moduleAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: TaxiProfileCardView.moduleAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up,
              color: TaxiProfileCardView.moduleAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "En yoğun saatin: ${activity.hourLabel} · "
              "ort. ${activity.avgWaitMinutes} dk bekleme",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
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

class _DistanceMiniCard extends StatelessWidget {
  final SavedPlace place;
  final CurrentLocation location;
  const _DistanceMiniCard({required this.place, required this.location});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(place.label);
    final distance = location.distanceKmTo(place);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconFor(place.category), color: color, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(place.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Spacer(),
          Text("${distance.toStringAsFixed(1)} km",
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RouteMiniCard extends StatelessWidget {
  final FrequentRoute route;
  const _RouteMiniCard({required this.route});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor("${route.fromLabel}${route.toLabel}");

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${route.fromLabel} → ${route.toLabel}",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text("${route.avgDistanceKm.toStringAsFixed(1)} km · ${route.avgDurationMinutes} dk",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text("${route.tripCount} sefer",
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HourBar extends StatelessWidget {
  final HourlyRideActivity activity;
  final int maxCount;
  const _HourBar({required this.activity, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final intensity = maxCount == 0 ? 0.0 : activity.rideCount / maxCount;

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: TaxiProfileCardView.moduleAccent.withValues(alpha: 0.10 + intensity * 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: TaxiProfileCardView.moduleAccent.withValues(alpha: 0.3 + intensity * 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("${activity.rideCount}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(activity.hourLabel,
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ScheduledRideMiniCard extends StatelessWidget {
  final ScheduledRide ride;
  const _ScheduledRideMiniCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(ride.label);
    const dayLabels = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: color, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(ride.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              Text(ride.timeLabel,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text("${ride.fromLabel} → ${ride.toLabel}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          Text(
            ride.daysOfWeek.map((d) => dayLabels[d - 1]).join(" · "),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DriverMiniCard extends StatelessWidget {
  final FavoriteTaxiDriver driver;
  const _DriverMiniCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final color = _seedColor(driver.name);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_circle_outlined, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(driver.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFE0B23A), size: 13),
              const SizedBox(width: 3),
              Text(driver.rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          if (driver.vehiclePlate != null) ...[
            const SizedBox(height: 2),
            Text(driver.vehiclePlate!,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
          const Spacer(),
          Text("${driver.timesUsed} kez kullanıldı",
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

IconData _iconFor(PlaceCategory category) => switch (category) {
      PlaceCategory.home => Icons.home_outlined,
      PlaceCategory.work => Icons.work_outline,
      PlaceCategory.entertainment => Icons.celebration_outlined,
      PlaceCategory.custom => Icons.place_outlined,
    };

// Kaynak adı başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _seedPalette = <Color>[
  Color(0xFF5A4A1F),
  Color(0xFF3E4A5A),
  Color(0xFF4A5A3E),
  Color(0xFF5A3E45),
];

Color _seedColor(String seed) {
  final index = seed.hashCode.abs() % _seedPalette.length;
  return _seedPalette[index];
}

String _formatDateTime(DateTime d) {
  final date =
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  final time =
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  return "$date · $time";
}
