import 'base.dart';
import '../bet.dart';

/// Yirmi birinci profil modülü: kullanıcının bahis kuponları — geçmiş ve
/// gelecekte oynanacak kuponlar, bahis için ayrılan toplam bütçe.
///
/// NOT: `remainingBudget` SAKLANMIYOR — `totalBudget` ile henüz
/// sonuçlanmamış (pending) kuponların stake toplamından türetiliyor
/// (bkz. bet.dart'taki gerekçe). Geçmiş/gelecek ayrımı kuponun
/// oluşturulma tarihine değil `eventDateTime`e dayanır (Travel/Event
/// modülleriyle tutarlı).
class BetProfileCard extends FeedCard implements Collectible {
  final double totalBudget;
  final String currency;
  final List<BetCoupon> coupons;

  const BetProfileCard({
    required String id,
    this.totalBudget = 0,
    this.currency = "TRY",
    this.coupons = const [],
  }) : super(id);

  List<BetCoupon> get upcomingCoupons => coupons.where((c) => c.isUpcoming).toList()
    ..sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));

  List<BetCoupon> get pastCoupons => coupons.where((c) => !c.isUpcoming).toList()
    ..sort((a, b) => b.eventDateTime.compareTo(a.eventDateTime));

  /// Henüz sonuçlanmamış (pending) kuponların stake toplamı — bütçeden
  /// "ayrılmış/rezerve" kabul edilir.
  double get pendingStakeTotal => coupons
      .where((c) => c.status == BetStatus.pending)
      .fold(0.0, (sum, c) => sum + c.stake);

  double get remainingBudget => totalBudget - pendingStakeTotal;

  /// Sonuçlanmış kuponların net kâr/zararı — hiç sonuçlanmış kupon
  /// yoksa `null`.
  double? get netResult {
    final resolved = coupons.where((c) => c.status != BetStatus.pending);
    if (resolved.isEmpty) return null;
    return resolved.fold(0.0, (sum, c) => sum! + (c.netResult ?? 0));
  }

  @override
  (String, String) toCollectionPreview() => ("Bahis Profili", "");
}