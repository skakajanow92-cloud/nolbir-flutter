/// Taşınmaz türü.
enum PropertyType { apartment, house, land, field, shop, office, warehouse, parking }

extension PropertyTypeLabel on PropertyType {
  String get label => switch (this) {
        PropertyType.apartment => "Daire",
        PropertyType.house => "Müstakil Ev",
        PropertyType.land => "Arsa",
        PropertyType.field => "Tarla",
        PropertyType.shop => "Dükkan",
        PropertyType.office => "Ofis",
        PropertyType.warehouse => "Depo",
        PropertyType.parking => "Otopark",
      };
}

/// Mülkiyet türü.
enum OwnershipType { full, shared, usufruct }

extension OwnershipTypeLabel on OwnershipType {
  String get label => switch (this) {
        OwnershipType.full => "Tam Mülkiyet",
        OwnershipType.shared => "Hisseli Mülkiyet",
        OwnershipType.usufruct => "İntifa Hakkı",
      };
}

/// Tapu kaydı bilgileri.
///
/// BİLİNÇLİ TASARIM KARARI: Tapu alanları (ada/parsel/yevmiye/bağımsız
/// bölüm) doğrudan `RealEstate` içine düz alanlar olarak konmadı — kendi
/// değer nesnesinde toplandı. Bunlar birlikte anlamlı bir bütün
/// (bir taşınmazın resmi kimliği) ve ileride tapu sorgu/doğrulama
/// entegrasyonu eklenirse tek bir tip olarak taşınabilir.
class DeedInfo {
  final String deedNumber; // tapu/yevmiye no
  final String? block; // ada
  final String? parcel; // parsel
  final String? independentSection; // bağımsız bölüm no
  final String landRegistryOffice; // tapu müdürlüğü
  final DateTime registrationDate; // tescil tarihi

  const DeedInfo({
    required this.deedNumber,
    this.block,
    this.parcel,
    this.independentSection,
    required this.landRegistryOffice,
    required this.registrationDate,
  });

  /// "Ada 1234 · Parsel 56 · B.B. 7" gibi kısa gösterim — boş alanlar
  /// otomatik atlanır (arsa/tarlada bağımsız bölüm olmaz).
  String get parcelSummary {
    final parts = <String>[
      if (block != null && block!.isNotEmpty) "Ada $block",
      if (parcel != null && parcel!.isNotEmpty) "Parsel $parcel",
      if (independentSection != null && independentSection!.isNotEmpty)
        "B.B. $independentSection",
    ];
    return parts.join(" · ");
  }
}

/// Tapuda kullanıcının üzerine kayıtlı tek bir taşınmaz.
class RealEstate {
  final String id;
  final String title; // kullanıcının verdiği ad, örn. "Kadıköy Daire"
  final PropertyType type;
  final String city;
  final String district;
  final String? neighborhood;
  final String? fullAddress;
  final double areaSqm; // brüt/yüzölçümü (m²)
  final OwnershipType ownershipType;
  final double? sharePercent; // hisseli mülkiyette pay yüzdesi
  final DeedInfo deed;
  final DateTime acquisitionDate;
  final double? acquisitionPrice;
  final double? currentValue;
  final String currency;
  final bool isRentedOut;
  final double? monthlyRent;

  const RealEstate({
    required this.id,
    required this.title,
    required this.type,
    required this.city,
    required this.district,
    this.neighborhood,
    this.fullAddress,
    required this.areaSqm,
    this.ownershipType = OwnershipType.full,
    this.sharePercent,
    required this.deed,
    required this.acquisitionDate,
    this.acquisitionPrice,
    this.currentValue,
    this.currency = "TRY",
    this.isRentedOut = false,
    this.monthlyRent,
  });

  String get locationSummary =>
      neighborhood != null && neighborhood!.isNotEmpty
          ? "$neighborhood, $district / $city"
          : "$district / $city";

  /// Hisseli mülkiyette kullanıcının payına düşen değer; tam mülkiyette
  /// değerin tamamı.
  double? get ownedValue {
    if (currentValue == null) return null;
    if (ownershipType == OwnershipType.shared && sharePercent != null) {
      return currentValue! * (sharePercent! / 100);
    }
    return currentValue;
  }

  /// Edinme bedeli ile güncel değer arasındaki fark (yüzde).
  double? get appreciationPercent {
    if (acquisitionPrice == null ||
        acquisitionPrice == 0 ||
        currentValue == null) {
      return null;
    }
    return ((currentValue! - acquisitionPrice!) / acquisitionPrice!) * 100;
  }
}

/// Kullanıcının kayıtlı ikametgâh adresi.
///
/// NOT: Taşınmaz listesinden BİLİNÇLİ olarak ayrı — kullanıcı sahibi
/// olmadığı bir adreste (kirada, aile yanında) ikamet ediyor olabilir.
class RegisteredAddress {
  final String city;
  final String district;
  final String neighborhood;
  final String addressLine;
  final String? postalCode;

  const RegisteredAddress({
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.addressLine,
    this.postalCode,
  });

  String get oneLine => "$addressLine, $neighborhood, $district / $city";
}
