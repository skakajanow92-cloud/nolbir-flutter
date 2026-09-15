import 'base.dart';
import '../donation.dart';

/// Yedinci profil modülü: kullanıcının ait olduğunu belirttiği kuruluş/
/// topluluklar ve yaptığı bağışlar.
///
/// GİZLİLİK NOTU: `politicalParty` bilinçli olarak opsiyonel/nullable —
/// birçok kullanıcı bunu paylaşmak istemeyebilir. Boş bırakıldığında
/// görünümde bu satır HİÇ gösterilmiyor, "belirtilmedi" gibi bir
/// placeholder bile yok (bkz. donation_profile_card_view.dart).
class DonationProfileCard extends FeedCard implements Collectible {
  final List<Affiliation> affiliations;
  final String? politicalParty;
  final List<Donation> donations;

  const DonationProfileCard({
    required String id,
    this.affiliations = const [],
    this.politicalParty,
    this.donations = const [],
  }) : super(id);

  double get totalDonated => donations.fold(0.0, (sum, d) => sum + d.amount);

  @override
  (String, String) toCollectionPreview() => ("Bağış Profili", "");
}
