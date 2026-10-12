import 'base.dart';

/// Ortaklık Başvurusu giriş kartı — profil akışında görünen, başvuru
/// durumunu gösteren ve sihirbazı başlatan kart.
///
/// BİLİNÇLİ TASARIM KARARI: VerificationProfileCard ile aynı desen — bu
/// kart VERİ TAŞIMIYOR, sadece bir işaretçi. Gerçek başvuru durumu
/// `shareholderApplicationDraftProvider`'da (canlı uygulama durumu)
/// tutuluyor; görünüm kendi state'ini CANLI okuyor, bu yüzden profil
/// akışının tamamı değil sadece bu kart yeniden çizilir.
class ShareholderApplicationCard extends FeedCard implements Collectible {
  const ShareholderApplicationCard({required String id}) : super(id);

  @override
  (String, String) toCollectionPreview() => ("Ortaklık Başvurusu", "");
}
