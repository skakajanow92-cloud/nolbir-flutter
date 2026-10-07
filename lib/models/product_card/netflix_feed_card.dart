import '../feed_card/base.dart';

enum StreamingContentType { movie, series, liveChannel }

extension StreamingContentTypeLabel on StreamingContentType {
  String get label {
    switch (this) {
      case StreamingContentType.movie:
        return "Film";
      case StreamingContentType.series:
        return "Dizi";
      case StreamingContentType.liveChannel:
        return "Canlı Yayın";
    }
  }
}

/// Sıralı — erişim kontrolü `subscribedTier.index >= requiredTier.index`
/// karşılaştırmasıyla yapılıyor (bkz. view).
enum SubscriptionTier { basic, standard, premium }

extension SubscriptionTierLabel on SubscriptionTier {
  String get label {
    switch (this) {
      case SubscriptionTier.basic:
        return "Temel";
      case SubscriptionTier.standard:
        return "Standart";
      case SubscriptionTier.premium:
        return "Premium";
    }
  }
}

class StreamingTitle {
  final String id;
  final String name;
  final String posterUrl;
  final StreamingContentType type;
  final String synopsis;
  final List<String>
  languageOptions; // "Türkçe Dublaj", "İngilizce Altyazılı" vb.
  final SubscriptionTier requiredTier;
  final bool isAdult;
  final double rating; // 0-10
  final int releaseYear;

  const StreamingTitle({
    required this.id,
    required this.name,
    required this.type,
    required this.synopsis,
    this.posterUrl = "",
    this.languageOptions = const [],
    this.requiredTier = SubscriptionTier.basic,
    this.isAdult = false,
    this.rating = 0,
    this.releaseYear = 2024,
  });
}

class StreamingCollection {
  final String id;
  final String name;
  final List<StreamingTitle> titles;
  final bool isAdultCollection;

  const StreamingCollection({
    required this.id,
    required this.name,
    required this.titles,
    this.isAdultCollection = false,
  });
}

class SubscriptionPlan {
  final SubscriptionTier tier;
  final String name;
  final double monthlyPrice;
  final List<String> perks;
  final bool isAdultAddon;

  const SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.monthlyPrice,
    this.perks = const [],
    this.isAdultAddon = false,
  });
}

/// Orta tab için: Netflix tarzı ücretli içerik platformu kartı. Geçen
/// turdaki YouTube kartıyla aynı iskelet (dikey kaydırmalı satırlar,
/// `NavArrowOverlay` ile dış akışta gezinme) ama koleksiyonlar düz bir
/// video listesi değil — film/dizi/canlı yayın karışık, abonelik
/// katmanına (`requiredTier`) ve yaş kısıtına (`isAdult`) göre erişim
/// kontrollü. Abonelik, tıpkı bir ürün gibi satın alınır (bkz. view'daki
/// `SubscriptionPlansDialog`, mevcut `CartType.subscription` akışını
/// kullanıyor).
class NetflixFeedCard extends FeedCard implements Collectible, LiveCollectible {
  final String platformName;
  final List<StreamingCollection> collections;
  final List<SubscriptionPlan> plans;
  final String currency;

  const NetflixFeedCard({
    required String id,
    required this.platformName,
    required this.collections,
    required this.plans,
    this.currency = "TRY",
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (
    platformName,
    collections.isNotEmpty && collections.first.titles.isNotEmpty
        ? collections.first.titles.first.posterUrl
        : "",
  );
}
