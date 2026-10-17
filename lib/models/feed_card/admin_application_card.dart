import 'base.dart';

/// Admin Başvurusu giriş kartı — profil akışında görünen, başvuru
/// durumunu gösteren ve sihirbazı başlatan kart.
///
/// VerificationProfileCard/ShareholderApplicationCard ile aynı desen: veri
/// TAŞIMIYOR, sadece işaretçi. Gerçek durum `adminApplicationDraftProvider`'da,
/// görünüm onu canlı okuyor.
class AdminApplicationCard extends FeedCard implements Collectible {
  const AdminApplicationCard({required String id}) : super(id);

  @override
  (String, String) toCollectionPreview() => ("Admin Başvurusu", "");
}
