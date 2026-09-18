import '../../../models/feed_card/feed_card.dart';
import '../../../models/taxi.dart';

TaxiProfileCard buildTaxiMock() {
  return TaxiProfileCard(
    id: "taxi1",
    currentLocation: CurrentLocation(
      label: "Bağdat Cad., Kadıköy, İstanbul",
      latitude: 40.9695,
      longitude: 29.0733,
      updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    savedPlaces: const [
      SavedPlace(
        id: "sp1",
        category: PlaceCategory.home,
        label: "Ev",
        address: "Moda Cad. No:42, Kadıköy",
        latitude: 40.9827,
        longitude: 29.0272,
      ),
      SavedPlace(
        id: "sp2",
        category: PlaceCategory.work,
        label: "Ofis",
        address: "Levent, Beşiktaş",
        latitude: 41.0814,
        longitude: 29.0113,
      ),
      SavedPlace(
        id: "sp3",
        category: PlaceCategory.entertainment,
        label: "Sahne Bar",
        address: "Kadıköy Barlar Sokağı",
        latitude: 40.9902,
        longitude: 29.0284,
      ),
    ],
    frequentRoutes: const [
      FrequentRoute(
        id: "fr1",
        fromLabel: "Ev",
        toLabel: "Ofis",
        avgDistanceKm: 18.4,
        avgDurationMinutes: 42,
        tripCount: 86,
      ),
      FrequentRoute(
        id: "fr2",
        fromLabel: "Ofis",
        toLabel: "Sahne Bar",
        avgDistanceKm: 12.1,
        avgDurationMinutes: 28,
        tripCount: 21,
      ),
    ],
    hourlyActivity: const [
      HourlyRideActivity(hour: 8, rideCount: 14, avgWaitMinutes: 6),
      HourlyRideActivity(hour: 9, rideCount: 9, avgWaitMinutes: 4),
      HourlyRideActivity(hour: 18, rideCount: 22, avgWaitMinutes: 9),
      HourlyRideActivity(hour: 19, rideCount: 11, avgWaitMinutes: 5),
      HourlyRideActivity(hour: 23, rideCount: 6, avgWaitMinutes: 3),
    ],
    scheduledRides: const [
      ScheduledRide(
        id: "sr1",
        label: "İşe Gidiş",
        daysOfWeek: [1, 2, 3, 4, 5],
        hour: 8,
        minute: 15,
        fromLabel: "Ev",
        toLabel: "Ofis",
      ),
    ],
    favoriteDrivers: const [
      FavoriteTaxiDriver(
        id: "fd1",
        name: "Hasan Usta",
        phone: "0532 xxx xx xx",
        vehiclePlate: "34 AB 1234",
        rating: 4.9,
        timesUsed: 34,
        note: "Sabah rotasını çok iyi bilir",
      ),
      FavoriteTaxiDriver(
        id: "fd2",
        name: "Kadıköy Taksi Durağı",
        rating: 4.5,
        timesUsed: 12,
      ),
    ],
  );
}
