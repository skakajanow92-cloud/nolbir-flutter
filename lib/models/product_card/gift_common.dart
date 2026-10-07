enum GiftCategory {
  flowerBouquet,
  flowerArrangement,
  plant,
  giftBasket,
  chocolate,
  toy,
  personalizedGift,
  balloon,
  other,
}

extension GiftCategoryLabel on GiftCategory {
  String get label {
    switch (this) {
      case GiftCategory.flowerBouquet:
        return "Çiçek Buketi";
      case GiftCategory.flowerArrangement:
        return "Aranjman";
      case GiftCategory.plant:
        return "Saksı Bitkisi";
      case GiftCategory.giftBasket:
        return "Hediye Sepeti";
      case GiftCategory.chocolate:
        return "Çikolata";
      case GiftCategory.toy:
        return "Oyuncak";
      case GiftCategory.personalizedGift:
        return "Kişiye Özel Hediye";
      case GiftCategory.balloon:
        return "Balon";
      case GiftCategory.other:
        return "Diğer";
    }
  }
}

enum Occasion {
  birthday,
  anniversary,
  wedding,
  newBorn,
  getWell,
  congratulations,
  apology,
  justBecause,
  other,
}

extension OccasionLabel on Occasion {
  String get label {
    switch (this) {
      case Occasion.birthday:
        return "Doğum Günü";
      case Occasion.anniversary:
        return "Yıl Dönümü";
      case Occasion.wedding:
        return "Düğün";
      case Occasion.newBorn:
        return "Yeni Doğan";
      case Occasion.getWell:
        return "Geçmiş Olsun";
      case Occasion.congratulations:
        return "Tebrik";
      case Occasion.apology:
        return "Özür";
      case Occasion.justBecause:
        return "Sebepsiz";
      case Occasion.other:
        return "Diğer";
    }
  }
}
