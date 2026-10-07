import '../feed_card/base.dart';
import '../pharmacy_cart.dart';
import '../cart.dart';

/// Sepet Kartları ailesinin yedinci üyesi: İlaç Sepeti. Diğer sepetlerden
/// üç noktada kasıtlı olarak ayrılıyor: reçeteli kalemler reçete
/// numarasına ve izin verilen adede bağlı; her reçeteli kalem dijital
/// imzalı bir `DigitalPrescription`a bağlanıyor; satıcılar ülkelere göre
/// alınan özel eczane lisansına sahip (`PharmacyOffer.licenseNumber`).
///
/// NOT: `cart` alanı `Cart`/`CartItem`/`CartType` modelini (`CartType.
/// pharmacy`) kullanıyor; ürüne özel alanlar `CartItem.metadata`
/// üzerinden `PharmacyCartItemExtras` extension'ıyla okunuyor (bkz.
/// pharmacy_cart.dart). Fiyat karşılaştırması SADECE aynı ilaç için;
/// öneri bölümü SADECE reçetesiz (OTC) ürünleri kapsar — klinik ilaç
/// ikamesi önerilmiyor.
class PharmacyCartCard extends FeedCard implements Collectible {
  final Cart cart;
  final List<DigitalPrescription> prescriptions;
  final List<MedicineComparisonGroup> priceComparisons;
  final List<RecommendedPharmacyProduct> recommendations;

  const PharmacyCartCard({
    required String id,
    required this.cart,
    this.prescriptions = const [],
    this.priceComparisons = const [],
    this.recommendations = const [],
  }) : super(id);

  List<CartItem> get prescriptionItems =>
      cart.items.where((i) => i.requiresPrescription).toList();

  List<CartItem> get otcItems =>
      cart.items.where((i) => !i.requiresPrescription).toList();

  /// Geçerliliği 7 gün içinde dolacak, hâlâ kullanılabilir reçeteler —
  /// alarm banner'ı için (bkz. diğer modüllerdeki aynı eşik).
  List<DigitalPrescription> get expiringPrescriptions =>
      prescriptions.where((p) => p.isExpiringSoon).toList()
        ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

  DigitalPrescription? prescriptionFor(CartItem item) {
    final number = item.prescriptionNumber;
    if (number == null) return null;
    for (final p in prescriptions) {
      if (p.prescriptionNumber == number) return p;
    }
    return null;
  }

  @override
  (String, String) toCollectionPreview() => ("İlaç Sepeti", "");
}
