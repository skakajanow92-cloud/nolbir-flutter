import '../features/discovery/widgets/discovery_detail_registrations.dart';
import '../features/profile/widgets/profile_detail_registrations.dart';

/// Detay paneli görünümlerini kaydeder — `registerAllCardViews()` ile aynı
/// ilke: yeni bir feature'ın detaylarını eklediğinde buraya sadece BİR satır
/// eklersin. main.dart'ta `registerAllCardViews()`'dan hemen sonra çağrılır.
void registerAllCardDetails() {
  registerDiscoveryCardDetails();
  registerProfileCardDetails();
}
