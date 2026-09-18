import '../../../models/feed_card/feed_card.dart';
import '../../../models/cargo.dart';

CargoProfileCard buildCargoMock() {
  return CargoProfileCard(
    id: "cargo1",
    shipments: [
      // Geçmiş gönderiler — sabit tarihler, teslim edilmiş/iade edilmiş.
      Shipment(
        id: "sh1",
        trackingNumber: "YK123456789TR",
        company: "Yurtiçi Kargo",
        senderName: "Trendyol Mağaza",
        receiverName: "Ben",
        contentDescription: "Kış Montu",
        originCity: "İstanbul",
        destinationCity: "İstanbul",
        createdDate: DateTime(2026, 2, 3),
        estimatedDeliveryDate: DateTime(2026, 2, 6),
        status: ShipmentStatus.delivered,
        isOutgoing: false,
        trackingEvents: [
          TrackingEvent(
            id: "te1",
            status: ShipmentStatus.pickedUp,
            locationLabel: "İstanbul Anadolu Aktarma Merkezi",
            timestamp: DateTime(2026, 2, 3, 14, 20),
          ),
          TrackingEvent(
            id: "te2",
            status: ShipmentStatus.outForDelivery,
            locationLabel: "Kadıköy Şube",
            timestamp: DateTime(2026, 2, 6, 9, 10),
          ),
          TrackingEvent(
            id: "te3",
            status: ShipmentStatus.delivered,
            locationLabel: "Kadıköy, İstanbul",
            timestamp: DateTime(2026, 2, 6, 15, 42),
          ),
        ],
      ),
      Shipment(
        id: "sh2",
        trackingNumber: "AR987654321TR",
        company: "Aras Kargo",
        senderName: "Ben",
        receiverName: "Zeynep Kaya",
        contentDescription: "Doğum Günü Hediyesi",
        originCity: "İstanbul",
        destinationCity: "Ankara",
        createdDate: DateTime(2025, 12, 10),
        estimatedDeliveryDate: DateTime(2025, 12, 13),
        status: ShipmentStatus.delivered,
        isOutgoing: true,
        trackingEvents: const [],
      ),
      // Devam eden gönderiler — bilerek DateTime.now() bazlı, sabit
      // tarih değil (diğer modüllerdeki gelecek-olay yaklaşımıyla
      // tutarlı olsun diye), ama esas ayrım STATUS bazlı.
      Shipment(
        id: "sh3",
        trackingNumber: "MNG445566778TR",
        company: "MNG Kargo",
        senderName: "Hepsiburada Mağaza",
        receiverName: "Ben",
        contentDescription: "Kablosuz Kulaklık",
        originCity: "İzmir",
        destinationCity: "İstanbul",
        createdDate: DateTime.now().subtract(const Duration(days: 2)),
        estimatedDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        status: ShipmentStatus.inTransit,
        isOutgoing: false,
        trackingEvents: [
          TrackingEvent(
            id: "te4",
            status: ShipmentStatus.pickedUp,
            locationLabel: "İzmir Aktarma Merkezi",
            timestamp: DateTime.now().subtract(
              const Duration(days: 2, hours: 4),
            ),
          ),
          TrackingEvent(
            id: "te5",
            status: ShipmentStatus.inTransit,
            locationLabel: "Bursa Transfer Merkezi",
            timestamp: DateTime.now().subtract(const Duration(hours: 10)),
          ),
        ],
      ),
      Shipment(
        id: "sh4",
        trackingNumber: "SUR112233445TR",
        company: "Sürat Kargo",
        senderName: "Ben",
        receiverName: "Mehmet Can",
        contentDescription: "Kitap Paketi",
        originCity: "İstanbul",
        destinationCity: "Bursa",
        createdDate: DateTime.now().subtract(const Duration(hours: 6)),
        estimatedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
        status: ShipmentStatus.preparing,
        isOutgoing: true,
        trackingEvents: [
          TrackingEvent(
            id: "te6",
            status: ShipmentStatus.preparing,
            locationLabel: "Şube Kabul Noktası, Kadıköy",
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          ),
        ],
      ),
    ],
    favoriteCompanies: const [
      FavoriteCargoCompany(
        id: "fc1",
        name: "Yurtiçi Kargo",
        timesUsed: 41,
        rating: 4.6,
      ),
      FavoriteCargoCompany(
        id: "fc2",
        name: "MNG Kargo",
        timesUsed: 18,
        rating: 4.3,
      ),
    ],
    favoriteCouriers: const [
      FavoriteCourier(
        id: "fcu1",
        name: "Yusuf Demir",
        company: "Yurtiçi Kargo",
        rating: 4.9,
        timesUsed: 15,
        note: "Kapıya kadar getiriyor, çok nazik",
      ),
    ],
  );
}
