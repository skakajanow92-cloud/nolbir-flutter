import '../../models/feed_card/feed_card.dart';
import '../../models/cart.dart';
import '../../models/product_card/product_card.dart';

abstract class DiscoveryRepository {
  Future<List<FeedCard>> fetchFeed({required int page, int pageSize = 10});
}

class MockDiscoveryRepository implements DiscoveryRepository {
  static const _demoCartTypes = [
    CartType.market,
    CartType.secondHand,
    CartType.sportsGear,
    CartType.wholesale,
  ];

  // Banka ürünü örnekleri — id'yi dışarıdan (üretim sırasında) alan
  // birer "şablon" fonksiyonu: aynı içerik farklı sayfalarda farklı id
  // ile tekrar kullanılabilsin diye.
  static final List<BankProductCard Function(String id)>
  _bankProductBuilders = [
    (id) => BankProductCard(
      id: id,
      bankName: "Kuzey Bankası",
      bankLogoUrl: "",
      title: "İhtiyaç Kredisi",
      description:
          "Hızlı onaylı, düşük faizli ihtiyaç kredisi — başvuru 5 dakika sürer.",
      productType: BankProductType.loan,
      rating: 4.3,
      reviewCount: 1280,
      detailUrl: "https://example.com/kuzeybank/ihtiyac-kredisi",
      loanDetails: const LoanDetails(
        interestRate: 3.49,
        maxTermMonths: 36,
        maxAmount: 250000,
        hasDigitalCard: true,
      ),
    ),
    (id) => BankProductCard(
      id: id,
      bankName: "Liman Bankası",
      bankLogoUrl: "",
      title: "Taşıt Kredisi",
      description: "0 km ve ikinci el taşıtlar için uygun vadeli kredi paketi.",
      productType: BankProductType.loan,
      rating: 3.9,
      reviewCount: 512,
      loanDetails: const LoanDetails(
        interestRate: 2.89,
        maxTermMonths: 48,
        maxAmount: 900000,
        hasDigitalCard: false,
      ),
    ),
    (id) => BankProductCard(
      id: id,
      bankName: "Kuzey Bankası",
      bankLogoUrl: "",
      title: "Vadesiz Hesap",
      description: "Maaş hesabı avantajlarıyla ücretsiz vadesiz hesap.",
      productType: BankProductType.checkingAccount,
      rating: 4.6,
      reviewCount: 3040,
      checkingAccountDetails: const CheckingAccountDetails(
        hasLinkedCard: true,
        cardName: "Kuzey Bonus",
        annualFee: 0,
      ),
    ),
    (id) => BankProductCard(
      id: id,
      bankName: "Vadi Bankası",
      bankLogoUrl: "",
      title: "Dijital Vadesiz Hesap",
      description: "Sadece mobil üzerinden yönetilen, şubesiz hesap.",
      productType: BankProductType.checkingAccount,
      rating: 4.1,
      reviewCount: 208,
      checkingAccountDetails: const CheckingAccountDetails(
        hasLinkedCard: false,
      ),
    ),
    (id) => BankProductCard(
      id: id,
      bankName: "Liman Bankası",
      bankLogoUrl: "",
      title: "Vadeli Mevduat",
      description: "Farklı vade seçenekleriyle yüksek getirili mevduat hesabı.",
      productType: BankProductType.timeDeposit,
      rating: 4.4,
      reviewCount: 964,
      timeDepositDetails: const TimeDepositDetails(
        termOptions: [
          DepositTermOption(months: 1, annualInterestRate: 41.0),
          DepositTermOption(months: 3, annualInterestRate: 44.5),
          DepositTermOption(months: 6, annualInterestRate: 43.0),
          DepositTermOption(months: 12, annualInterestRate: 40.0),
        ],
      ),
    ),
  ];

  static final List<InsuranceProductCard Function(String id)>
  _insuranceProductBuilders = [
    // Doğrudan sigorta şirketinden — kendi logosu, kendi adı altında.
    (id) => InsuranceProductCard(
      id: id,
      sellerKind: InsuranceSellerKind.directInsurer,
      sellerName: "Güven Sigorta",
      sellerLogoUrl: "",
      coverageType: InsuranceCoverageType.health,
      title: "Tamamlayıcı Sağlık Sigortası",
      description:
          "SGK'lı tüm tedavi giderlerinizi özel hastanede fark ödemeden karşılar.",
      rating: 4.5,
      reviewCount: 2140,
      detailUrl: "https://example.com/guven/saglik",
      coverageHighlights: const ["Ayakta tedavi", "Yatarak tedavi", "Check-up"],
      planOptions: const [
        InsurancePlanOption(
          name: "Temel",
          monthlyPremium: 340,
          coverageSummary: "Yatarak tedavi",
        ),
        InsurancePlanOption(
          name: "Geniş",
          monthlyPremium: 590,
          coverageSummary: "Yatarak + ayakta tedavi",
        ),
      ],
    ),
    // Acente — Kolay Sigorta vitrininde, poliçeyi Anka Sigorta üstleniyor.
    (id) => InsuranceProductCard(
      id: id,
      sellerKind: InsuranceSellerKind.brokerAgent,
      sellerName: "Kolay Sigorta Acentesi",
      sellerLogoUrl: "",
      underwritingCompanyName: "Anka Sigorta",
      underwritingCompanyLogoUrl: "",
      coverageType: InsuranceCoverageType.traffic,
      title: "Trafik Sigortası",
      description: "Zorunlu trafik sigortanızı dakikalar içinde yenileyin.",
      rating: 4.1,
      reviewCount: 876,
      coverageHighlights: const ["Maddi hasar", "Bedeni zarar"],
      planOptions: const [
        InsurancePlanOption(
          name: "Standart",
          monthlyPremium: 180,
          coverageSummary: "Yasal asgari teminat",
        ),
      ],
    ),
    // Aynı acente, farklı bir şirketin kasko ürününü satıyor.
    (id) => InsuranceProductCard(
      id: id,
      sellerKind: InsuranceSellerKind.brokerAgent,
      sellerName: "Kolay Sigorta Acentesi",
      sellerLogoUrl: "",
      underwritingCompanyName: "Deniz Sigorta",
      underwritingCompanyLogoUrl: "",
      coverageType: InsuranceCoverageType.vehicle,
      title: "Kasko",
      description: "Çarpma, çalınma ve doğal afetlere karşı tam koruma.",
      rating: 4.3,
      reviewCount: 431,
      deductible: 2500,
      coverageHighlights: const [
        "Çarpma",
        "Çalınma",
        "Cam kırılması",
        "Yol yardım",
      ],
      planOptions: const [
        InsurancePlanOption(
          name: "Standart",
          monthlyPremium: 420,
          coverageSummary: "Muafiyetli temel kasko",
        ),
        InsurancePlanOption(
          name: "Mini Onarım Hariç",
          monthlyPremium: 510,
          coverageSummary: "Düşük muafiyetli kasko",
        ),
        InsurancePlanOption(
          name: "Tam Kapsam",
          monthlyPremium: 690,
          coverageSummary: "Muafiyetsiz, yol yardım dahil",
        ),
      ],
    ),
    // Doğrudan farklı bir sigorta şirketinden, konut sigortası.
    (id) => InsuranceProductCard(
      id: id,
      sellerKind: InsuranceSellerKind.directInsurer,
      sellerName: "Anka Sigorta",
      sellerLogoUrl: "",
      coverageType: InsuranceCoverageType.home,
      title: "Konut Sigortası",
      description: "Yangın, hırsızlık ve doğal afetlere karşı eviniz güvende.",
      rating: 4.0,
      reviewCount: 305,
      coverageHighlights: const ["Yangın", "Hırsızlık", "Deprem", "Su baskını"],
      planOptions: const [
        InsurancePlanOption(
          name: "Temel",
          monthlyPremium: 95,
          coverageSummary: "Yangın + hırsızlık",
        ),
        InsurancePlanOption(
          name: "Geniş",
          monthlyPremium: 160,
          coverageSummary: "Tüm doğal afetler dahil",
        ),
      ],
    ),
  ];

  static final List<EcommerceProductCard Function(String id)>
  _ecommerceProductBuilders = [
    (id) => EcommerceProductCard(
      id: id,
      storeName: "Moda Dükkanı",
      storeLogoUrl: "",
      brandName: "Nordline",
      category: ProductCategory.clothing,
      title: "Yünlü Kaban",
      description: "Kışlık, su itici kumaşlı, astarlı kaban.",
      price: 1299.0,
      discountedPrice: 899.0,
      rating: 4.4,
      reviewCount: 612,
      stockStatus: StockStatus.lowStock,
      imageUrls: const ["", ""],
      variantGroups: const [
        ProductVariantGroup(name: "Beden", options: ["S", "M", "L", "XL"]),
        ProductVariantGroup(
          name: "Renk",
          options: ["Siyah", "Kamel", "Lacivert"],
        ),
      ],
      specs: const [
        ProductSpec(label: "Kumaş", value: "%70 Yün, %30 Polyester"),
        ProductSpec(label: "Astar", value: "Var"),
      ],
    ),
    (id) => EcommerceProductCard(
      id: id,
      storeName: "Teknoloji Merkezi",
      storeLogoUrl: "",
      brandName: "Orion",
      category: ProductCategory.mobileDevices,
      title: "Orion X12 Akıllı Telefon",
      description: "6.5 inç ekran, üçlü kamera, hızlı şarj desteği.",
      price: 24999.0,
      rating: 4.6,
      reviewCount: 3480,
      imageUrls: const [""],
      variantGroups: const [
        ProductVariantGroup(
          name: "Depolama",
          options: ["128GB", "256GB", "512GB"],
        ),
        ProductVariantGroup(name: "Renk", options: ["Grafit", "Gümüş"]),
      ],
      specs: const [
        ProductSpec(label: "Ekran", value: "6.5\" AMOLED"),
        ProductSpec(label: "İşlemci", value: "Octa-core 2.8GHz"),
        ProductSpec(label: "Batarya", value: "5000 mAh"),
        ProductSpec(label: "Kamera", value: "50MP + 12MP + 8MP"),
      ],
      cartType: CartType.secondHand,
    ),
    (id) => EcommerceProductCard(
      id: id,
      storeName: "Usta Hırdavat",
      storeLogoUrl: "",
      brandName: "PowerMax",
      category: ProductCategory.powerTools,
      title: "PowerMax 900W Matkap",
      description: "Darbeli, değişken hız kontrollü profesyonel matkap.",
      price: 1850.0,
      rating: 4.2,
      reviewCount: 198,
      stockStatus: StockStatus.inStock,
      imageUrls: const [""],
      specs: const [
        ProductSpec(label: "Güç", value: "900W"),
        ProductSpec(label: "Mandren", value: "13mm"),
        ProductSpec(label: "Ağırlık", value: "2.1 kg"),
        ProductSpec(label: "Kutu İçeriği", value: "Çanta + 5 uç"),
      ],
      cartType: CartType.wholesale,
    ),
    (id) => EcommerceProductCard(
      id: id,
      storeName: "Yapı Market",
      storeLogoUrl: "",
      category: ProductCategory.construction,
      title: "Alçıpan Levha",
      description: "Standart iç mekan alçıpan levha, nem direnci yüksek.",
      price: 189.0,
      rating: 3.9,
      reviewCount: 74,
      stockStatus: StockStatus.preOrder,
      imageUrls: const [""],
      variantGroups: const [
        ProductVariantGroup(
          name: "Ölçü",
          options: ["120x200cm", "120x250cm", "120x300cm"],
        ),
      ],
      specs: const [
        ProductSpec(label: "Kalınlık", value: "12.5mm"),
        ProductSpec(label: "Kenar Tipi", value: "Düz kenar"),
      ],
      cartType: CartType.wholesale,
    ),
  ];

  static const _gridThemes = [
    "Bu haftanın fırsatları",
    "Ofis ve kırtasiye ihtiyaçları",
    "Ev yenileme seçenekleri",
  ];

  List<EcommerceProductCard> _buildGridItems(int seed, int count) {
    return List.generate(count, (i) {
      final n = seed * 100 + i;
      final builder =
          _ecommerceProductBuilders[n % _ecommerceProductBuilders.length];
      return builder("grid_${seed}_$n");
    });
  }

  static final List<TicketSearchCard Function(String id)>
  _ticketSearchBuilders = [
    (id) => TicketSearchCard(
      id: id,
      platformName: "FlyNow",
      platformLogoUrl: "",
      transportMode: TransportMode.flight,
      description:
          "Yurt içi ve yurt dışı uçuşlarda en uygun fiyatları karşılaştır.",
      popularCities: const ["İstanbul", "Ankara", "İzmir", "Antalya"],
    ),
    (id) => TicketSearchCard(
      id: id,
      platformName: "Otobüsüm",
      platformLogoUrl: "",
      transportMode: TransportMode.bus,
      description: "Yüzlerce firma arasından en uygun otobüs biletini bul.",
      popularCities: const ["İstanbul", "Bursa", "Eskişehir", "Konya"],
    ),
  ];

  static final List<PopularRoutesCard Function(String id)>
  _popularRoutesBuilders = [
    (id) => PopularRoutesCard(
      id: id,
      title: "Bu Hafta Trend",
      subtitle: "Popüler rotalar",
      routes: const [
        PopularRouteItem(
          destinationName: "Kapadokya",
          imageUrl: "",
          fromCity: "İstanbul",
          toCity: "Nevşehir",
          startingPrice: 650,
          tag: "Trend",
        ),
        PopularRouteItem(
          destinationName: "Bodrum",
          imageUrl: "",
          fromCity: "İzmir",
          toCity: "Bodrum",
          startingPrice: 420,
          tag: "Kampanyalı",
        ),
        PopularRouteItem(
          destinationName: "Trabzon",
          imageUrl: "",
          fromCity: "Ankara",
          toCity: "Trabzon",
          startingPrice: 580,
        ),
      ],
    ),
  ];

  static final List<HotelSearchCard Function(String id)> _hotelSearchBuilders =
      [
        (id) => HotelSearchCard(
          id: id,
          platformName: "KalacakYer",
          platformLogoUrl: "",
          description: "Otel, pansiyon ve butik konaklamaları karşılaştır.",
          popularDestinations: const [
            "Antalya",
            "Kapadokya",
            "İstanbul",
            "Bodrum",
          ],
        ),
      ];

  static final List<PopularHotelsCard Function(String id)>
  _popularHotelsBuilders = [
    (id) => PopularHotelsCard(
      id: id,
      title: "Size Özel Seçildi",
      subtitle: "Akıllı öneriler",
      hotels: const [
        PopularHotelItem(
          name: "Mavi Koy Otel",
          imageUrl: "",
          location: "Bodrum, Muğla",
          rating: 4.5,
          reviewCount: 842,
          pricePerNight: 1450,
          tags: ["Wi-Fi", "Evcil Hayvan Dostu"],
          smartBadge: "Rotanıza yakın",
        ),
        PopularHotelItem(
          name: "Yeşil Vadi Resort",
          imageUrl: "",
          location: "Kapadokya, Nevşehir",
          rating: 4.2,
          reviewCount: 311,
          pricePerNight: 980,
          tags: ["Kahvaltı Dahil"],
        ),
      ],
    ),
  ];

  static final List<FoodItemCard Function(String id)> _foodItemBuilders = [
    (id) => FoodItemCard(
      id: id,
      businessName: "Napoli Pizzeria",
      businessLogoUrl: "",
      businessType: "Lokanta",
      itemName: "Margherita Pizza",
      description: "Taş fırında, taze fesleğen ve mozzarella ile.",
      price: 240,
      discountedPrice: 190,
      rating: 4.6,
      reviewCount: 980,
      category: FoodCategory.mainCourse,
      dietaryTags: const [DietaryTag.vegetarian],
      prepTimeMinutes: 25,
    ),
  ];

  static final List<BusinessMenuCard Function(String id)>
  _businessMenuBuilders = [
    (id) => BusinessMenuCard(
      id: id,
      businessName: "Köy Sofrası",
      businessLogoUrl: "",
      businessType: "Ev Yemekleri",
      rating: 4.4,
      reviewCount: 540,
      deliveryTimeMinutes: 35,
      deliveryFee: 0,
      minOrderAmount: 150,
      distanceKm: 2.3,
      items: const [
        MenuItem(
          id: "m1",
          name: "Mercimek Çorbası",
          description: "Ev yapımı, tereyağlı",
          price: 60,
          category: FoodCategory.starter,
        ),
        MenuItem(
          id: "m2",
          name: "Kuru Fasulye",
          description: "Pilav eşliğinde",
          price: 120,
          category: FoodCategory.mainCourse,
        ),
        MenuItem(
          id: "m3",
          name: "Künefe",
          description: "Sıcak servis",
          price: 95,
          discountedPrice: 80,
          category: FoodCategory.dessert,
          dietaryTags: [DietaryTag.vegetarian],
        ),
      ],
    ),
  ];

  static final List<FoodPlaceSearchCard Function(String id)>
  _foodPlaceSearchBuilders = [
    (id) => FoodPlaceSearchCard(
      id: id,
      platformName: "YemekYolda",
      platformLogoUrl: "",
      description: "Çevrendeki kafe ve lokantalardan sipariş ver.",
      cuisineTypes: const ["Türk Mutfağı", "İtalyan", "Fast Food", "Tatlı"],
      popularLocations: const ["Kadıköy", "Beşiktaş", "Çankaya"],
    ),
  ];

  static final List<JewelryItemCard Function(String id)> _jewelryItemBuilders =
      [
        (id) => JewelryItemCard(
          id: id,
          brandName: "Altın Kesif",
          brandLogoUrl: "",
          itemName: "Tektaş Yüzük",
          description: "El işçiliği detaylı, zarif tektaş pırlanta yüzük.",
          category: JewelryCategory.ring,
          metalType: MetalType.whiteGold,
          karat: 18,
          weightGrams: 3.2,
          gemstones: const ["Pırlanta"],
          price: 18500,
          discountedPrice: 16900,
          rating: 4.8,
          reviewCount: 212,
        ),
      ];

  static final List<JewelryCatalogCard Function(String id)>
  _jewelryCatalogBuilders = [
    (id) => JewelryCatalogCard(
      id: id,
      brandName: "Vera Kuyumculuk",
      brandLogoUrl: "",
      rating: 4.5,
      reviewCount: 640,
      items: const [
        JewelryCatalogItem(
          id: "j1",
          name: "İnce Zincir Kolye",
          category: JewelryCategory.necklace,
          metalType: MetalType.gold,
          karat: 14,
          weightGrams: 2.1,
          price: 4200,
        ),
        JewelryCatalogItem(
          id: "j2",
          name: "Halka Küpe",
          category: JewelryCategory.earring,
          metalType: MetalType.gold,
          karat: 14,
          weightGrams: 1.4,
          price: 2600,
          discountedPrice: 2150,
        ),
        JewelryCatalogItem(
          id: "j3",
          name: "Zincir Bileklik",
          category: JewelryCategory.bracelet,
          metalType: MetalType.roseGold,
          karat: 18,
          weightGrams: 4.0,
          price: 7800,
        ),
        JewelryCatalogItem(
          id: "j4",
          name: "Klasik Alyans",
          category: JewelryCategory.ring,
          metalType: MetalType.whiteGold,
          karat: 22,
          weightGrams: 5.5,
          price: 11200,
        ),
      ],
    ),
  ];

  static final List<CustomJewelryOrderCard Function(String id)>
  _customJewelryOrderBuilders = [
    (id) => CustomJewelryOrderCard(
      id: id,
      brandName: "Atölye Form",
      brandLogoUrl: "",
      description:
          "İsme özel tasarım mücevher — ölçü, ayar ve taşı sen belirle.",
      availableCategories: const [
        JewelryCategory.ring,
        JewelryCategory.necklace,
        JewelryCategory.bracelet,
      ],
      availableMetals: const [
        MetalType.gold,
        MetalType.whiteGold,
        MetalType.roseGold,
      ],
      availableKarats: const [14, 18, 22],
      minBudget: 3000,
      maxBudget: 50000,
    ),
  ];

  static final List<GiftItemCard Function(String id)> _giftItemBuilders = [
    (id) => GiftItemCard(
      id: id,
      businessName: "Çiçek Bahçesi",
      businessLogoUrl: "",
      itemName: "Kır Çiçeği Buketi",
      description: "Mevsim çiçeklerinden özenle hazırlanmış, taze buket.",
      category: GiftCategory.flowerBouquet,
      occasions: const [Occasion.birthday, Occasion.getWell],
      price: 450,
      discountedPrice: 380,
      rating: 4.7,
      reviewCount: 356,
      sameDayDelivery: true,
      includesMessageCard: true,
    ),
  ];

  static final List<GiftCatalogCard Function(String id)> _giftCatalogBuilders =
      [
        (id) => GiftCatalogCard(
          id: id,
          businessName: "Hediye Dünyası",
          businessLogoUrl: "",
          rating: 4.3,
          reviewCount: 410,
          items: const [
            GiftCatalogItem(
              id: "g1",
              name: "Orkide Saksısı",
              category: GiftCategory.plant,
              price: 320,
              sameDayDelivery: true,
            ),
            GiftCatalogItem(
              id: "g2",
              name: "Çikolata Kutusu",
              category: GiftCategory.chocolate,
              price: 280,
              discountedPrice: 240,
            ),
            GiftCatalogItem(
              id: "g3",
              name: "Sürpriz Hediye Sepeti",
              category: GiftCategory.giftBasket,
              price: 650,
            ),
            GiftCatalogItem(
              id: "g4",
              name: "Peluş Ayı",
              category: GiftCategory.toy,
              price: 190,
            ),
          ],
        ),
      ];

  static final List<CustomGiftOrderCard Function(String id)>
  _customGiftOrderBuilders = [
    (id) => CustomGiftOrderCard(
      id: id,
      businessName: "Atölye Hediye",
      businessLogoUrl: "",
      description:
          "Vesileye özel, kişiselleştirilmiş hediye seti hazırlayalım.",
      availableCategories: const [
        GiftCategory.flowerArrangement,
        GiftCategory.giftBasket,
        GiftCategory.personalizedGift,
      ],
      availableOccasions: const [
        Occasion.birthday,
        Occasion.anniversary,
        Occasion.wedding,
        Occasion.newBorn,
        Occasion.congratulations,
      ],
      minBudget: 200,
      maxBudget: 5000,
    ),
  ];

  static final MessagesListCard _messagesListCard = MessagesListCard(
    id: "messages_main",
    contacts: [
      ChatContact(
        id: "c1",
        name: "Elif Yıldız",
        isOnline: true,
        lastMessage: "Yarın saat kaçta buluşuyoruz?",
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      ChatContact(
        id: "c2",
        name: "Mert Kaya",
        lastMessage: "Tamamdır, teşekkürler!",
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatContact(
        id: "c3",
        name: "Aslı Demir",
        isOnline: true,
        lastMessage: "Fotoğrafları gönderdim.",
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        unreadCount: 1,
      ),
      const ChatContact(id: "c4", name: "Can Öztürk"),
    ],
  );

  static final SocialFeedCard _socialFeedCard = SocialFeedCard(
    id: "social_main",
    stories: const [
      StoryItem(id: "s1", username: "elif.y"),
      StoryItem(id: "s2", username: "mert_k", isViewed: true),
      StoryItem(id: "s3", username: "asli.d"),
      StoryItem(id: "s4", username: "can_o", isViewed: true),
      StoryItem(id: "s5", username: "zeynep"),
    ],
    seedPosts: [
      SocialPost(
        id: "post_seed_1",
        username: "elif.y",
        imageUrl: "",
        caption: "Bugün harika bir gündü ☀️",
        likeCount: 342,
        commentCount: 18,
        postedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SocialPost(
        id: "post_seed_2",
        username: "mert_k",
        imageUrl: "",
        caption: "Yeni projeme başlıyorum 🚀",
        likeCount: 128,
        commentCount: 5,
        postedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
  );

  static final DatingSwipeCard _datingSwipeCard = DatingSwipeCard(
    id: "dating_main",
    seedProfiles: const [
      DatingProfile(
        id: "d1",
        firstName: "Ece",
        lastName: "Kaya",
        age: 27,
        hometown: "İstanbul",
        bio: "Doğa yürüyüşleri ve iyi kahve tutkunu.",
        hobbies: ["Yürüyüş", "Fotoğrafçılık", "Kahve"],
        distanceKm: 4.2,
      ),
      DatingProfile(
        id: "d2",
        firstName: "Kerem",
        lastName: "Demir",
        age: 31,
        hometown: "Ankara",
        bio: "Hafta sonları dağcılık, hafta içi yazılım.",
        hobbies: ["Dağcılık", "Kitap"],
        distanceKm: 11.8,
      ),
    ],
  );

  static final VideoFeedCard _videoFeedCard = VideoFeedCard(
    id: "video_feed_main",
    seedVideos: const [
      FeedVideoItem(
        id: "vfeed1",
        videoUrl: "",
        username: "kaan.y",
        description: "Bugün bunu deniyorum 👀",
        likeCount: 1240,
        commentCount: 87,
      ),
      FeedVideoItem(
        id: "vfeed2",
        videoUrl: "",
        username: "selin_",
        description: "Kahkaha garantili 😂",
        likeCount: 3820,
        commentCount: 214,
      ),
    ],
  );

  static const List<YoutubeChannel> _youtubeChannels = [
    YoutubeChannel(id: "ch1", name: "Kod Atölyesi", subscriberCount: 184000),
    YoutubeChannel(id: "ch2", name: "Mutfak Sırları", subscriberCount: 92000),
    YoutubeChannel(
      id: "ch3",
      name: "Teknoloji Günlüğü",
      subscriberCount: 410000,
    ),
    YoutubeChannel(id: "ch4", name: "Doğa Yolu", subscriberCount: 57000),
  ];

  static final YoutubeFeedCard _youtubeFeedCard = YoutubeFeedCard(
    id: "youtube_feed_main",
    subscribedChannels: _youtubeChannels,
    seedVideos: [
      LongVideoItem(
        id: "yt_seed1",
        title: "Flutter ile sıfırdan uygulama",
        channel: _youtubeChannels[0],
        duration: const Duration(minutes: 24, seconds: 12),
        viewCount: 48200,
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      LongVideoItem(
        id: "yt_seed2",
        title: "15 dakikada akşam yemeği",
        channel: _youtubeChannels[1],
        duration: const Duration(minutes: 14, seconds: 40),
        viewCount: 9100,
        uploadedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ],
  );

  static final NetflixFeedCard _netflixFeedCard = NetflixFeedCard(
    id: "netflix_feed_main",
    platformName: "Nolbir+",
    plans: const [
      SubscriptionPlan(
        tier: SubscriptionTier.basic,
        name: "Temel",
        monthlyPrice: 59.9,
        perks: ["720p kalite", "1 cihaz"],
      ),
      SubscriptionPlan(
        tier: SubscriptionTier.standard,
        name: "Standart",
        monthlyPrice: 99.9,
        perks: ["1080p kalite", "2 cihaz", "İndirme"],
      ),
      SubscriptionPlan(
        tier: SubscriptionTier.premium,
        name: "Premium",
        monthlyPrice: 149.9,
        perks: ["4K kalite", "4 cihaz", "İndirme", "Tüm canlı kanallar"],
      ),
      SubscriptionPlan(
        tier: SubscriptionTier.premium,
        name: "Yetişkin İçerik Paketi",
        monthlyPrice: 39.9,
        perks: ["18+ film ve dizilere erişim"],
        isAdultAddon: true,
      ),
    ],
    collections: const [
      StreamingCollection(
        id: "col1",
        name: "Yeni Çıkanlar",
        titles: [
          StreamingTitle(
            id: "t1",
            name: "Gece Yarısı Treni",
            type: StreamingContentType.movie,
            synopsis:
                "Gizemli bir yolculukta geçmişiyle yüzleşen bir kadının hikayesi.",
            languageOptions: ["Türkçe Dublaj", "İngilizce Altyazılı"],
            requiredTier: SubscriptionTier.basic,
            rating: 7.8,
            releaseYear: 2025,
          ),
          StreamingTitle(
            id: "t2",
            name: "Kuzey Rüzgarı",
            type: StreamingContentType.series,
            synopsis: "Küçük bir kasabada açığa çıkan sırların dizisi.",
            languageOptions: ["Türkçe Altyazılı"],
            requiredTier: SubscriptionTier.standard,
            rating: 8.2,
            releaseYear: 2024,
          ),
        ],
      ),
      StreamingCollection(
        id: "col2",
        name: "Canlı Yayın Kanalları",
        titles: [
          StreamingTitle(
            id: "t3",
            name: "Spor Kanalı HD",
            type: StreamingContentType.liveChannel,
            synopsis: "Canlı spor yayınları.",
            requiredTier: SubscriptionTier.premium,
            releaseYear: 2025,
          ),
          StreamingTitle(
            id: "t4",
            name: "Haber 7/24",
            type: StreamingContentType.liveChannel,
            synopsis: "Kesintisiz canlı haber yayını.",
            requiredTier: SubscriptionTier.basic,
            releaseYear: 2025,
          ),
        ],
      ),
      StreamingCollection(
        id: "col3",
        name: "Yetişkin İçerik Paketi",
        isAdultCollection: true,
        titles: [
          StreamingTitle(
            id: "t5",
            name: "Kırmızı Oda",
            type: StreamingContentType.movie,
            synopsis:
                "18 yaş ve üzeri izleyici kitlesine yönelik gerilim filmi.",
            languageOptions: ["İngilizce Altyazılı"],
            requiredTier: SubscriptionTier.premium,
            isAdult: true,
            rating: 6.9,
            releaseYear: 2023,
          ),
        ],
      ),
    ],
  );

  @override
  Future<List<FeedCard>> fetchFeed({
    required int page,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (page >= 27) return [];

    return List.generate(pageSize, (i) {
      final n = page * pageSize + i;
      final type = n % 26; // 0: video, 1: ürün, 2: abonelik, 3: banka ürünü
      switch (type) {
        case 0:
          return VideoCard(
            id: "v$n",
            videoUrl: "",
            username: "kullanici$n",
            description: "Örnek video açıklaması #$n",
            likeCount: (n * 37) % 5000,
          );
        case 1:
          return ProductCard(
            id: "pr$n",
            title: "Ürün #$n",
            imageUrl: "",
            price: 99.9 + n * 10,
            cartType: _demoCartTypes[n % _demoCartTypes.length],
          );
        case 2:
          return SubscriptionCard(
            id: "sub$n",
            serviceName: "Premium Paket #$n",
            description: "Özel içerik ve avantajlar",
            monthlyPrice: 29.9 + n,
          );
        case 3:
          return _bankProductBuilders[n % _bankProductBuilders.length](
            "bank$n",
          );
        case 4:
          return _ecommerceProductBuilders[n %
              _ecommerceProductBuilders.length]("ecmc$n");
        case 5:
          return _insuranceProductBuilders[n %
              _insuranceProductBuilders.length]("ins$n");
        case 6:
          return ProductGridCard(
            id: "grid$n",
            title: _gridThemes[n % _gridThemes.length],
            subtitle: "Farklı mağazalardan seçilmiş 12 ürün",
            products: _buildGridItems(n, 12),
          );
        case 7:
          return _ticketSearchBuilders[n % _ticketSearchBuilders.length](
            "ticket$n",
          );
        case 8:
          return _popularRoutesBuilders[n % _popularRoutesBuilders.length](
            "routes$n",
          );
        case 9:
          return _hotelSearchBuilders[n % _hotelSearchBuilders.length](
            "hotels$n",
          );
        case 10:
          return _popularHotelsBuilders[n % _popularHotelsBuilders.length](
            "populer_otels$n",
          );
        case 11:
          return _foodItemBuilders[n % _foodItemBuilders.length]("food$n");
        case 12:
          return _businessMenuBuilders[n % _businessMenuBuilders.length](
            "menu$n",
          );
        case 13:
          return _foodPlaceSearchBuilders[n % _foodPlaceSearchBuilders.length](
            "foodsearch$n",
          );
        case 14:
          return _jewelryItemBuilders[n % _jewelryItemBuilders.length](
            "jewel$n",
          );
        case 15:
          return _jewelryCatalogBuilders[n % _jewelryCatalogBuilders.length](
            "jewelcat$n",
          );
        case 16:
          return _customJewelryOrderBuilders[n %
              _customJewelryOrderBuilders.length]("jewelcustom$n");
        case 17:
          return _giftItemBuilders[n % _giftItemBuilders.length]("gift$n");
        case 18:
          return _giftCatalogBuilders[n % _giftCatalogBuilders.length](
            "giftcat$n",
          );
        case 19:
          return _customGiftOrderBuilders[n % _customGiftOrderBuilders.length](
            "giftcustom$n",
          );
        case 20:
          return _socialFeedCard;
        case 21:
          return _datingSwipeCard;
        case 22:
          return _videoFeedCard;
        case 23:
          return _youtubeFeedCard;
        case 24:
          return _netflixFeedCard;
        default:
          return _messagesListCard;
      }
    });
  }
}
