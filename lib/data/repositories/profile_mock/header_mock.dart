import '../../../models/feed_card/feed_card.dart';

/// Temel Bilgiler (kimlik) modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
ProfileHeaderCard buildHeaderMock() {
  return const ProfileHeaderCard(
    id: "p1",
    username: "kullanici_adi",
    avatarUrl: "",
    bio: "Kısa biyografi burada",
    firstName: "Ayşe",
    lastName: "Yılmaz",
    country: "Türkiye",
    gender: "Kadın",
    followerCount: 128,
  );
}
