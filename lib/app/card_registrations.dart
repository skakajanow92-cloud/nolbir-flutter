import '../features/auth/widgets/form_registrations.dart';
import '../features/discovery/widgets/discovery_card_registrations.dart';
import '../features/profile/widgets/profile_card_registrations.dart';
import '../features/collection/widgets/collection_card_registrations.dart';
import '../features/cart/widgets/cart_card_registrations.dart';

/// Uygulama açılışında TEK SEFER çağrılır (main.dart).
/// Yeni bir feature/kart türü eklediğinde buraya sadece BİR satır
/// eklersin — CardViewRegistry'nin kendisine veya diğer feature'lara
/// dokunmana gerek kalmaz.
void registerAllCardViews() {
  registerDiscoveryCardViews();
  registerProfileCardViews();
  registerCollectionCardViews();
  registerCartCardViews();
  registerFormViews();
}
