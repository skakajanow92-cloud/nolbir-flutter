import 'package:flutter/material.dart';
import '../feed_card/base.dart';

enum TransportMode { flight, bus, train, ferry }

extension TransportModeLabel on TransportMode {
  String get label {
    switch (this) {
      case TransportMode.flight:
        return "Uçak";
      case TransportMode.bus:
        return "Otobüs";
      case TransportMode.train:
        return "Tren";
      case TransportMode.ferry:
        return "Feribot";
    }
  }

  IconData get icon {
    switch (this) {
      case TransportMode.flight:
        return Icons.flight_takeoff;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.train:
        return Icons.train;
      case TransportMode.ferry:
        return Icons.directions_boat;
    }
  }
}

/// Orta tab için: bir bilet platformunun arama formunu sunan kart.
/// Form doldurulup "Bilet ara" basıldığında sonuçlar bir dialog/bottom
/// sheet içinde listelenir — seçim ve sepete ekleme oradan devam eder.
/// Bu adımda sadece form + sonuç listesi akışı var; gerçek rezervasyon/
/// ödeme akışı kapsam dışı.
class TicketSearchCard extends FeedCard {
  final String platformName;
  final String platformLogoUrl;
  final TransportMode transportMode;
  final String description;

  /// Hızlı seçim için öneri şehirler (serbest metin alanının yanında
  /// dokunulabilir çipler olarak gösterilir).
  final List<String> popularCities;

  const TicketSearchCard({
    required String id,
    required this.platformName,
    required this.platformLogoUrl,
    required this.transportMode,
    required this.description,
    this.popularCities = const [],
  }) : super(id);
}
