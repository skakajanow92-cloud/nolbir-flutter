import '../streaming.dart';
import 'base.dart';

/// On ikinci profil modülü: kullanıcının video/TV yayın abonelikleri.
///
/// Netflix benzeri tek bir platforma değil, FARKLI ŞİRKETLERİN özel video
/// ve TV kanal koleksiyonlarına abonelik tutuyor — üstelik aynı şirketin
/// birden fazla paketine de abone olunabilir. Bu yüzden hiyerarşi üç
/// katmanlı: şirket > paket > kanal (bkz. streaming.dart).
///
/// `ChannelsProfileCard` (10. modül) ile karıştırılmamalı: orası
/// kullanıcının KENDİ oluşturduğu kanallar, burası başkalarının
/// içeriğine ABONE olduğu paketler.
class StreamingProfileCard extends FeedCard implements Collectible {
  final List<StreamingProvider> providers;

  const StreamingProfileCard({required String id, this.providers = const []})
      : super(id);

  /// Tüm aktif paketlerin aylık toplam maliyeti (yıllık paketler /12).
  double get totalMonthlyCost =>
      providers.fold(0.0, (sum, p) => sum + p.monthlyCost);

  int get activePackageCount =>
      providers.fold(0, (sum, p) => sum + p.activePackages.length);

  int get totalChannelCount =>
      providers.fold(0, (sum, p) => sum + p.channelCount);

  /// Tüm aktif paketler, yenileme tarihine göre sıralı.
  List<StreamingPackage> get packagesByRenewal {
    final all = <StreamingPackage>[];
    for (final p in providers) {
      all.addAll(p.activePackages);
    }
    all.sort((a, b) => a.renewalDate.compareTo(b.renewalDate));
    return all;
  }

  /// Yenilenmesine 7 günden az kalan en yakın paket — varsa uyarı
  /// banner'ı için (bkz. TravelProfileCard/AccommodationProfileCard'daki
  /// aynı eşik; bu modülde "yaklaşan ödeme" anlamına geliyor).
  StreamingPackage? get nextRenewalAlert {
    final soon = packagesByRenewal.where((p) => p.daysUntilRenewal <= 7);
    return soon.isEmpty ? null : soon.first;
  }

  @override
  (String, String) toCollectionPreview() => ("Yayın Abonelikleri", "");
}
