import '../../../models/feed_card/feed_card.dart';
import '../../../models/channel.dart';

/// Kanallar modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
ChannelsProfileCard buildChannelsMock() {
  return ChannelsProfileCard(
    id: "channels1",
    channels: [
      Channel(
        id: "ch1",
        name: "Kod ve Kahve",
        description: "Yazılım geliştirme üzerine haftalık videolar.",
        category: "Teknoloji",
        subscriberCount: 48200,
        totalViews: 1850000,
        createdDate: DateTime(2022, 3, 12),
        videos: [
          ChannelVideo(
            id: "v1",
            title: "Flutter ile Sıfırdan Uygulama - Bölüm 12",
            duration: const Duration(minutes: 24, seconds: 18),
            viewCount: 15400,
            commentCount: 312,
            likeCount: 980,
            publishedDate: DateTime.now().subtract(const Duration(days: 3)),
          ),
          ChannelVideo(
            id: "v2",
            title: "State Management Karşılaştırması",
            duration: const Duration(minutes: 18, seconds: 42),
            viewCount: 9800,
            commentCount: 156,
            likeCount: 640,
            publishedDate: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
        pendingComments: [
          ChannelComment(
            id: "cm1",
            videoTitle: "Flutter ile Sıfırdan Uygulama - Bölüm 12",
            authorUsername: "ahmet_dev",
            text: "13. bölüm ne zaman geliyor?",
            date: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          ChannelComment(
            id: "cm2",
            videoTitle: "State Management Karşılaştırması",
            authorUsername: "zeynepp",
            text: "Riverpod örneği çok işime yaradı, teşekkürler!",
            date: DateTime.now().subtract(const Duration(hours: 20)),
            isReviewed: true,
          ),
        ],
      ),
      Channel(
        id: "ch2",
        name: "Mutfaktan Notlar",
        description: "Pratik tarifler ve mutfak ipuçları.",
        category: "Yemek",
        subscriberCount: 12900,
        totalViews: 402000,
        createdDate: DateTime(2023, 8, 1),
        videos: [
          ChannelVideo(
            id: "v3",
            title: "15 Dakikada Mercimek Çorbası",
            duration: const Duration(minutes: 9, seconds: 5),
            viewCount: 22100,
            commentCount: 89,
            likeCount: 1450,
            publishedDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        pendingComments: [
          ChannelComment(
            id: "cm3",
            videoTitle: "15 Dakikada Mercimek Çorbası",
            authorUsername: "burcu.k",
            text: "Tarçın yerine ne kullanabilirim?",
            date: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
    ],
  );
}
