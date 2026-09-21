import 'base.dart';

/// Doğrulama Merkezi profil modülü.
///
/// BİLİNÇLİ TASARIM KARARI: Diğer profil kartlarının aksine bu kart VERİ
/// TAŞIMIYOR — sadece bir işaretçi. Gerçek doğrulama seviyesi
/// `userVerificationProvider`'da (canlı uygulama durumu) tutuluyor, mock
/// demo verisinde değil; çünkü bu, kullanıcı ilerledikçe DEĞİŞEN gerçek
/// bir durum, diğer modüllerdeki gibi sabit gösterim verisi değil.
class VerificationProfileCard extends FeedCard implements Collectible {
  const VerificationProfileCard({required String id}) : super(id);

  @override
  (String, String) toCollectionPreview() => ("Doğrulama Merkezi", "");
}
