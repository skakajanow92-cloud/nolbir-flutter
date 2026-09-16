import 'package:nolbir/data/repositories/profile_mock/event_mock.dart';
import 'package:nolbir/data/repositories/profile_mock/health_mock.dart';

import '../../models/feed_card/feed_card.dart';
import 'profile_mock/profile_mock.dart';

/// Sol tab (Profil) veri kaynağı sözleşmesi.
abstract class ProfileRepository {
  Future<List<FeedCard>> fetchProfileFeed(String userId);
  Future<void> addPost(FeedCard post);
}

/// Demo verisi artık BU DOSYADA DEĞİL — her profil modülünün demo verisi
/// kendi dosyasında (`profile_mock/<modul>_mock.dart`). Bu dosya sadece
/// onları birleştiriyor.
///
/// Sıralama burada önemli DEĞİL: profil akışındaki gerçek sıra
/// `ProfileModuleOrder`'dan geliyor (bkz. core/cards/profile_module_order.dart),
/// yani kayıt sırası neyse akışta o çıkıyor. Buradaki liste sadece "hangi
/// modüllerin verisi var" sorusunu cevaplıyor.
class MockProfileRepository implements ProfileRepository {
  // Gerçek uygulamada her modül muhtemelen ayrı bir servise/API'ye gider;
  // burada demo amaçlı oturum boyunca bellekte tutuluyor ki eklenen yeni
  // paylaşımlar kalıcı görünsün.
  final List<FeedCard> _cards = [
    buildHeaderMock(),
    buildWalletMock(),
    buildInsuranceMock(),
    buildTravelMock(),
    buildAccommodationMock(),
    buildFoodMock(),
    buildDonationMock(),
    buildEngagementMock(),
    buildCareerMock(),
    buildDatingMock(),
    buildChannelsMock(),
    buildStreamingMock(),
    buildHealthMock(),
    buildEventMock(),
    ...buildPostsMock(),
  ];

  @override
  Future<List<FeedCard>> fetchProfileFeed(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_cards);
  }

  @override
  Future<void> addPost(FeedCard post) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cards.add(post);
  }
}
