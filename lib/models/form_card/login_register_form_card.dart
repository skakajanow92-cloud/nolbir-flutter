import 'base.dart';

/// İlk form kartı: temel giriş/kayıt formu.
///
/// Bu kart normal profil akışının İÇİNDE bir kart olarak YER ALMAZ —
/// `isUserProvider` (bkz. features/auth/application/auth_providers.dart)
/// false olduğunda ProfileTab, normal `VerticalCardFeed` akışının
/// YERİNE bunu gösterir. Kayıt boş — şu an taşıdığı bir veri yok, sadece
/// "hangi form gösterilecek" bilgisini FormViewRegistry'ye taşıyor.
class LoginRegisterFormCard extends FormCard {
  const LoginRegisterFormCard({required String id}) : super(id);
}
