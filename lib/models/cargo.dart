/// Gönderi durumu.
enum ShipmentStatus {
  preparing,
  pickedUp,
  inTransit,
  atDistributionCenter,
  outForDelivery,
  delivered,
  returned,
  cancelled,
}

extension ShipmentStatusLabel on ShipmentStatus {
  String get label => switch (this) {
        ShipmentStatus.preparing => "Hazırlanıyor",
        ShipmentStatus.pickedUp => "Kargoya Verildi",
        ShipmentStatus.inTransit => "Yolda",
        ShipmentStatus.atDistributionCenter => "Dağıtım Merkezinde",
        ShipmentStatus.outForDelivery => "Dağıtıma Çıktı",
        ShipmentStatus.delivered => "Teslim Edildi",
        ShipmentStatus.returned => "İade Edildi",
        ShipmentStatus.cancelled => "İptal Edildi",
      };

  bool get isFinal =>
      this == ShipmentStatus.delivered ||
      this == ShipmentStatus.returned ||
      this == ShipmentStatus.cancelled;
}

/// Bir gönderinin geçtiği tek bir takip kaydı (konum + durum + zaman).
/// Gönderinin "hikayesi" bu kayıtların sıralı listesinden oluşur.
class TrackingEvent {
  final String id;
  final ShipmentStatus status;
  final String locationLabel; // örn. "İstanbul Aktarma Merkezi"
  final DateTime timestamp;
  final String? note;

  const TrackingEvent({
    required this.id,
    required this.status,
    required this.locationLabel,
    required this.timestamp,
    this.note,
  });
}

/// Kullanıcının gönderdiği ya da kendisine gönderilen tek bir kargo.
///
/// BİLİNÇLİ TASARIM KARARI: Anlık "şu an nerede" konumu AYRI bir alan
/// olarak TUTULMUYOR — `latestEvent` ile `trackingEvents` listesinden
/// türetiliyor (bkz. taxi.dart'taki CurrentLocation.distanceKmTo ile
/// aynı "saklamak yerine türet" yaklaşımı). Böylece konum bilgisi tek
/// bir kaynaktan (takip geçmişinden) gelir, iki yerde senkron tutulmaz.
class Shipment {
  final String id;
  final String trackingNumber;
  final String company;
  final String senderName;
  final String receiverName;
  final String contentDescription;
  final String originCity;
  final String destinationCity;
  final DateTime createdDate;
  final DateTime? estimatedDeliveryDate;
  final ShipmentStatus status;
  final bool isOutgoing; // true: kullanıcı gönderen, false: kullanıcı alıcı
  final List<TrackingEvent> trackingEvents;

  const Shipment({
    required this.id,
    required this.trackingNumber,
    required this.company,
    required this.senderName,
    required this.receiverName,
    required this.contentDescription,
    required this.originCity,
    required this.destinationCity,
    required this.createdDate,
    this.estimatedDeliveryDate,
    required this.status,
    this.isOutgoing = true,
    this.trackingEvents = const [],
  });

  bool get isActive => !status.isFinal;

  List<TrackingEvent> get sortedEvents => trackingEvents.toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  /// En son takip kaydı — "şu an nerede" bilgisi buradan türetilir.
  TrackingEvent? get latestEvent {
    if (trackingEvents.isEmpty) return null;
    return trackingEvents.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }
}

/// Kullanıcının favori/sık kullandığı bir kargo firması.
class FavoriteCargoCompany {
  final String id;
  final String name;
  final int timesUsed;
  final double rating; // 0-5
  final String? note;

  const FavoriteCargoCompany({
    required this.id,
    required this.name,
    this.timesUsed = 0,
    this.rating = 0,
    this.note,
  });
}

/// Kullanıcının favori/güvendiği bir kurye.
class FavoriteCourier {
  final String id;
  final String name;
  final String company;
  final String? phone;
  final double rating; // 0-5
  final int timesUsed;
  final String? note;

  const FavoriteCourier({
    required this.id,
    required this.name,
    required this.company,
    this.phone,
    this.rating = 0,
    this.timesUsed = 0,
    this.note,
  });
}
