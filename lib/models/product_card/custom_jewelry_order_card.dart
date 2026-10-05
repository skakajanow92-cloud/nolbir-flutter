import '../feed_card/base.dart';
import 'jewelry_common.dart';

/// Orta tab için: isme özel/belirli ayarda özel kuyumculuk siparişi
/// formunu sunan kart. Arama formlarından (bilet/otel/yemek) farkı:
/// sonuçta anında eşleşen bir envanter yok — form "talep özeti"
/// dialog'una gider, oradan gönderilir; hazır bir seçenek listesi dönmez.
class CustomJewelryOrderCard extends FeedCard {
  final String brandName;
  final String brandLogoUrl;
  final String description;
  final List<JewelryCategory> availableCategories;
  final List<MetalType> availableMetals;
  final List<int> availableKarats;
  final double minBudget;
  final double maxBudget;
  final String currency;

  const CustomJewelryOrderCard({
    required String id,
    required this.brandName,
    required this.brandLogoUrl,
    required this.description,
    this.availableCategories = const [],
    this.availableMetals = const [],
    this.availableKarats = const [],
    this.minBudget = 0,
    this.maxBudget = 0,
    this.currency = "TRY",
  }) : super(id);
}
