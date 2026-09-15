/// Faturalandırma dönemi.
enum BillingPeriod { monthly, yearly }

extension BillingPeriodLabel on BillingPeriod {
  String get label => switch (this) {
        BillingPeriod.monthly => "Aylık",
        BillingPeriod.yearly => "Yıllık",
      };
}

/// Görüntü kalitesi — paketler arası farkın en görünür olduğu alan.
enum StreamQuality { sd, hd, fullHd, uhd4k }

extension StreamQualityLabel on StreamQuality {
  String get label => switch (this) {
        StreamQuality.sd => "SD",
        StreamQuality.hd => "HD",
        StreamQuality.fullHd => "Full HD",
        StreamQuality.uhd4k => "4K UHD",
      };
}

/// Bir paketin içinde gelen tek bir kanal ya da içerik koleksiyonu.
/// (örn. "BeIN Sports 1", "Belgesel Koleksiyonu", "Çocuk Kanalları")
class StreamingChannel {
  final String id;
  final String name;
  final String category; // örn. "Spor", "Dizi", "Belgesel", "Çocuk"

  const StreamingChannel({
    required this.id,
    required this.name,
    required this.category,
  });
}

/// Bir şirketten alınmış TEK bir abonelik paketi.
///
/// TASARIM NOTU: Kullanıcı aynı şirketten BİRDEN FAZLA pakete abone
/// olabilir (örn. temel paket + spor paketi), bu yüzden paket ayrı bir
/// varlık — şirketin altında liste olarak duruyor.
class StreamingPackage {
  final String id;
  final String name;
  final double price;
  final String currency;
  final BillingPeriod billingPeriod;
  final DateTime renewalDate;
  final int maxScreens;
  final StreamQuality quality;
  final List<StreamingChannel> channels;
  final bool isActive;

  const StreamingPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.renewalDate,
    this.currency = "TRY",
    this.billingPeriod = BillingPeriod.monthly,
    this.maxScreens = 1,
    this.quality = StreamQuality.hd,
    this.channels = const [],
    this.isActive = true,
  });

  /// Yıllık paketleri aylık maliyete çevirir — farklı dönemlerdeki
  /// paketleri toplayabilmek için (bkz. StreamingProfileCard.totalMonthlyCost).
  double get monthlyEquivalent =>
      billingPeriod == BillingPeriod.yearly ? price / 12 : price;

  /// Yenilemeye kaç gün kaldı (geçmişse negatif).
  int get daysUntilRenewal =>
      renewalDate.difference(DateTime.now()).inDays;
}

/// Bir yayın şirketi (Netflix benzeri bir platform) ve kullanıcının o
/// şirketten aldığı paketler.
class StreamingProvider {
  final String id;
  final String name;
  final List<StreamingPackage> packages;

  const StreamingProvider({
    required this.id,
    required this.name,
    this.packages = const [],
  });

  List<StreamingPackage> get activePackages =>
      packages.where((p) => p.isActive).toList();

  double get monthlyCost =>
      activePackages.fold(0.0, (sum, p) => sum + p.monthlyEquivalent);

  int get channelCount =>
      activePackages.fold(0, (sum, p) => sum + p.channels.length);
}
