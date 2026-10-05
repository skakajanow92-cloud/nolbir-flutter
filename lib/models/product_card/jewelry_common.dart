enum JewelryCategory { ring, necklace, bracelet, earring, watch, other }

extension JewelryCategoryLabel on JewelryCategory {
  String get label {
    switch (this) {
      case JewelryCategory.ring:
        return "Yüzük";
      case JewelryCategory.necklace:
        return "Kolye";
      case JewelryCategory.bracelet:
        return "Bilezik/Bileklik";
      case JewelryCategory.earring:
        return "Küpe";
      case JewelryCategory.watch:
        return "Saat";
      case JewelryCategory.other:
        return "Diğer";
    }
  }
}

enum MetalType { gold, whiteGold, roseGold, silver, platinum }

extension MetalTypeLabel on MetalType {
  String get label {
    switch (this) {
      case MetalType.gold:
        return "Sarı Altın";
      case MetalType.whiteGold:
        return "Beyaz Altın";
      case MetalType.roseGold:
        return "Rose Altın";
      case MetalType.silver:
        return "Gümüş";
      case MetalType.platinum:
        return "Platin";
    }
  }
}