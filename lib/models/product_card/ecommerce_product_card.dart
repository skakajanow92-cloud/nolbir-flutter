import '../cart.dart';
import '../feed_card/base.dart';

/// Kapsamlı ama kapalı bir küme değil — yeni bir iş kolu eklenince buraya
/// yeni bir değer eklenir, kart yapısına dokunulmaz.
enum ProductCategory {
  construction,
  clothing,
  grocery,
  stationery,
  autoParts,
  electrical,
  appliances,
  furniture,
  kitchenware,
  powerTools,
  mobileDevices,
  computerParts,
  gardenOutdoor,
  seeds,
  chemicals,
  decor,
  other,
}

extension ProductCategoryLabel on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.construction:
        return "İnşaat Malzemeleri";
      case ProductCategory.clothing:
        return "Giyim";
      case ProductCategory.grocery:
        return "Gıda";
      case ProductCategory.stationery:
        return "Kırtasiye";
      case ProductCategory.autoParts:
        return "Yedek Parça";
      case ProductCategory.electrical:
        return "Elektrik Malzemeleri";
      case ProductCategory.appliances:
        return "Beyaz Eşya";
      case ProductCategory.furniture:
        return "Mobilya";
      case ProductCategory.kitchenware:
        return "Mutfak Malzemeleri";
      case ProductCategory.powerTools:
        return "Elektrikli El Aletleri";
      case ProductCategory.mobileDevices:
        return "Mobil Cihaz";
      case ProductCategory.computerParts:
        return "Bilgisayar Parçaları";
      case ProductCategory.gardenOutdoor:
        return "Ev & Bahçe";
      case ProductCategory.seeds:
        return "Tohum";
      case ProductCategory.chemicals:
        return "Kimyasal Ürünler";
      case ProductCategory.decor:
        return "Dekoratif Ürünler";
      case ProductCategory.other:
        return "Diğer";
    }
  }
}

enum StockStatus { inStock, lowStock, outOfStock, preOrder }

extension StockStatusLabel on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.inStock:
        return "Stokta";
      case StockStatus.lowStock:
        return "Son ürünler";
      case StockStatus.outOfStock:
        return "Tükendi";
      case StockStatus.preOrder:
        return "Ön sipariş";
    }
  }
}

/// Genel seçenek grubu — "Beden": [S, M, L] ya da "Renk": [Kırmızı, Mavi]
/// ya da "Güç": [600W, 900W]. Kategoriye özel alan açmak yerine her ürün
/// kendi grup setini taşır.
class ProductVariantGroup {
  final String name;
  final List<String> options;

  const ProductVariantGroup({required this.name, required this.options});
}

/// Teknik özellik satırı — "Malzeme: Çelik", "Ekran: 6.1 inç" gibi.
/// Kategoriler arası ortak paydayı bu genel anahtar-değer yapısı sağlar.
class ProductSpec {
  final String label;
  final String value;

  const ProductSpec({required this.label, required this.value});
}

/// Orta tab için: herhangi bir mağaza/işletmenin, herhangi bir kategorideki
/// kargo ile gönderilebilir ürününü tanıtan tek, geniş kapsamlı kart tipi.
///
/// TASARIM KARARI: Kategoriye özel sabit alanlar (beden, renk, güç, vade
/// vb.) yerine `variantGroups` ve `specs` genel listeleri kullanılıyor.
/// Bankacılık/sigorta kartlarının aksine burada ürün türü sayısı pratikte
/// sınırsız — bu yüzden o iki kartta kullanılan "productType'a göre sabit
/// gövde" yaklaşımı burada ölçeklenmez.
class EcommerceProductCard extends FeedCard implements Collectible {
  final String storeName;
  final String storeLogoUrl;

  /// Mağazanın sattığı ürünün markası — mağaza adıyla aynı olabilir
  /// (kendi markası) ya da farklı olabilir (çok markalı mağaza).
  final String? brandName;

  final ProductCategory category;
  final String title;
  final String description;
  final List<String> imageUrls;

  final double price;
  final double? discountedPrice;
  final String currency;

  final double rating;
  final int reviewCount;
  final StockStatus stockStatus;

  final List<ProductVariantGroup> variantGroups;
  final List<ProductSpec> specs;

  final CartType cartType;
  final String? detailUrl;

  const EcommerceProductCard({
    required String id,
    required this.storeName,
    required this.storeLogoUrl,
    required this.category,
    required this.title,
    required this.description,
    required this.price,
    this.brandName,
    this.imageUrls = const [],
    this.discountedPrice,
    this.currency = "TRY",
    this.rating = 0,
    this.reviewCount = 0,
    this.stockStatus = StockStatus.inStock,
    this.variantGroups = const [],
    this.specs = const [],
    this.cartType = CartType.market,
    this.detailUrl,
  }) : super(id);

  double get effectivePrice => discountedPrice ?? price;

  int? get discountPercent {
    if (discountedPrice == null || discountedPrice! >= price || price == 0) {
      return null;
    }
    return (((price - discountedPrice!) / price) * 100).round();
  }

  @override
  (String, String) toCollectionPreview() => (
        "$storeName · $title",
        imageUrls.isNotEmpty ? imageUrls.first : storeLogoUrl,
      );
}