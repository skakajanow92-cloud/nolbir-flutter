import '../../models/feed_card.dart';
import '../../models/wallet.dart';
import '../../models/insurance.dart';
import '../../models/travel.dart';
import '../../models/accommodation.dart';
import '../../models/food.dart';

/// Sol tab (Profil) veri kaynağı sözleşmesi.
abstract class ProfileRepository {
  Future<List<FeedCard>> fetchProfileFeed(String userId);
  Future<void> addPost(FeedCard post);
}

class MockProfileRepository implements ProfileRepository {
  // Gerçek uygulamada bu bir API/DB olurdu; burada oturum boyunca
  // bellekte tutuluyor ki eklenen yeni paylaşımlar kalıcı görünsün.
  final List<FeedCard> _cards = [
    const ProfileHeaderCard(
      id: "p1",
      username: "kullanici_adi",
      avatarUrl: "",
      bio: "Kısa biyografi burada",
      firstName: "Ayşe",
      lastName: "Yılmaz",
      country: "Türkiye",
      gender: "Kadın",
      followerCount: 128,
    ),
    WalletProfileCard(
      id: "wallet1",
      accounts: [
        const BankAccount(
          id: "acc1",
          bankName: "Ziraat Bankası",
          type: BankAccountType.checking,
          balance: 12450.75,
        ),
        const BankAccount(
          id: "acc2",
          bankName: "İş Bankası",
          type: BankAccountType.checking,
          balance: 3200.10,
        ),
        BankAccount(
          id: "acc3",
          bankName: "Garanti BBVA",
          type: BankAccountType.timeDeposit,
          balance: 50000.00,
          interestRate: 42.5,
          maturityDate: DateTime(2026, 12, 15),
        ),
        BankAccount(
          id: "acc4",
          bankName: "Akbank",
          type: BankAccountType.timeDeposit,
          balance: 25750.00,
          interestRate: 41.0,
          maturityDate: DateTime(2027, 3, 1),
        ),
      ],
      creditCards: const [
        BankCreditCard(
          id: "cc1",
          bankName: "Ziraat Bankası",
          maskedNumber: "**** 4417",
          limit: 30000,
          used: 12500,
        ),
        BankCreditCard(
          id: "cc2",
          bankName: "Garanti BBVA",
          maskedNumber: "**** 9082",
          limit: 50000,
          used: 41250,
        ),
      ],
    ),
    InsuranceProfileCard(
      id: "insurance1",
      policies: [
        InsurancePolicy(
          id: "pol1",
          company: "Allianz Sigorta",
          type: InsurancePolicyType.vehicle,
          policyNumber: "ALZ-2026-0091",
          premium: 4200,
          coverageAmount: 850000,
          startDate: DateTime(2026, 1, 10),
          endDate: DateTime(2027, 1, 10),
        ),
        InsurancePolicy(
          id: "pol2",
          company: "Anadolu Sigorta",
          type: InsurancePolicyType.health,
          policyNumber: "AND-2025-3387",
          premium: 9800,
          coverageAmount: 1500000,
          startDate: DateTime(2025, 11, 1),
          endDate: DateTime(2026, 11, 1),
        ),
        InsurancePolicy(
          id: "pol3",
          company: "Axa Sigorta",
          type: InsurancePolicyType.home,
          policyNumber: "AXA-2024-7765",
          premium: 1250,
          coverageAmount: 600000,
          startDate: DateTime(2024, 6, 1),
          endDate: DateTime(2025, 6, 1),
          isActive: false,
        ),
        InsurancePolicy(
          id: "pol4",
          company: "Türkiye Sigorta",
          type: InsurancePolicyType.life,
          policyNumber: "TSG-2026-1123",
          premium: 3600,
          coverageAmount: 400000,
          startDate: DateTime(2026, 3, 1),
          endDate: DateTime(2036, 3, 1),
        ),
      ],
    ),
    TravelProfileCard(
      id: "travel1",
      tickets: [
        // Geçmiş biletler — sabit tarihler yeterli, "geçmiş" olduklarını
        // garanti etmek için bilinçli olarak uzak geçmişte seçildi.
        TravelTicket(
          id: "t1",
          company: "Turkish Airlines",
          transportType: TransportType.flight,
          ticketNumber: "TK-2025-88213",
          origin: "İstanbul",
          destination: "Londra",
          departureDateTime: DateTime(2025, 11, 2, 9, 30),
          arrivalDateTime: DateTime(2025, 11, 2, 12, 15),
          seatNumber: "14C",
          price: 4200,
        ),
        TravelTicket(
          id: "t2",
          company: "Metro Turizm",
          transportType: TransportType.bus,
          ticketNumber: "MT-2026-04471",
          origin: "Ankara",
          destination: "İzmir",
          departureDateTime: DateTime(2026, 2, 14, 22, 0),
          price: 650,
        ),
        TravelTicket(
          id: "t3",
          company: "TCDD Taşımacılık",
          transportType: TransportType.train,
          ticketNumber: "YHT-2026-11829",
          origin: "Ankara",
          destination: "İstanbul",
          departureDateTime: DateTime(2026, 5, 20, 7, 45),
          seatNumber: "5A",
          price: 380,
        ),
        // Yaklaşan biletler — bilerek "şu an"a göre DİNAMİK (DateTime.now()
        // tabanlı) tarihler kullanılıyor. Böylece bu mock veri hangi
        // tarihte test edilirse edilsin "yaklaşan yolculuk alarmı" anlamlı
        // kalır (sabit bir tarih yazsaydık, birkaç ay sonra o da geçmişe
        // düşerdi ve demo bozulurdu).
        TravelTicket(
          id: "t4",
          company: "Pegasus",
          transportType: TransportType.flight,
          ticketNumber: "PC-2026-90344",
          origin: "İstanbul",
          destination: "Antalya",
          departureDateTime: DateTime.now().add(
            const Duration(days: 3, hours: 6),
          ),
          seatNumber: "22F",
          price: 1450,
        ),
        TravelTicket(
          id: "t5",
          company: "Turkish Airlines",
          transportType: TransportType.flight,
          ticketNumber: "TK-2026-77410",
          origin: "İstanbul",
          destination: "Paris",
          departureDateTime: DateTime.now().add(const Duration(days: 45)),
          seatNumber: "9A",
          price: 5200,
        ),
      ],
    ),
    AccommodationProfileCard(
      id: "accommodation1",
      reservations: [
        // Geçmiş rezervasyonlar — sabit tarihler.
        AccommodationReservation(
          id: "res1",
          hotelName: "Hilton Bodrum",
          location: "Bodrum, Türkiye",
          roomType: "Standart Oda",
          guestCount: 2,
          checkIn: DateTime(2025, 8, 10),
          checkOut: DateTime(2025, 8, 14),
          confirmationNumber: "HLT-2025-55210",
          price: 18000,
        ),
        AccommodationReservation(
          id: "res2",
          hotelName: "Ibis Ankara",
          location: "Ankara, Türkiye",
          roomType: "Standart Oda",
          guestCount: 1,
          checkIn: DateTime(2026, 3, 5),
          checkOut: DateTime(2026, 3, 7),
          confirmationNumber: "IBS-2026-11987",
          price: 3200,
        ),
        // Yaklaşan rezervasyonlar — travel modülündeki gibi bilerek
        // DateTime.now() bazlı, sabit tarih değil.
        AccommodationReservation(
          id: "res3",
          hotelName: "Rixos Premium Belek",
          location: "Antalya, Türkiye",
          roomType: "Suit",
          guestCount: 2,
          checkIn: DateTime.now().add(const Duration(days: 5)),
          checkOut: DateTime.now().add(const Duration(days: 8)),
          confirmationNumber: "RXS-2026-90021",
          price: 42000,
        ),
        AccommodationReservation(
          id: "res4",
          hotelName: "Conrad Paris",
          location: "Paris, Fransa",
          roomType: "Executive Oda",
          guestCount: 1,
          checkIn: DateTime.now().add(const Duration(days: 50)),
          checkOut: DateTime.now().add(const Duration(days: 53)),
          confirmationNumber: "CND-2026-33456",
          price: 65000,
        ),
      ],
    ),
    const FoodProfileCard(
      id: "food1",
      favoriteFoods: [
        FavoriteFood(id: "ff1", name: "Mantı", cuisine: "Türk"),
        FavoriteFood(id: "ff2", name: "Izgara Köfte", cuisine: "Türk"),
        FavoriteFood(id: "ff3", name: "Sushi", cuisine: "Japon"),
        FavoriteFood(id: "ff4", name: "Tiramisu", cuisine: "İtalyan"),
      ],
      favoriteRestaurants: [
        FavoriteRestaurant(
          id: "fr1",
          name: "Nusr-Et",
          cuisine: "Steakhouse",
          location: "İstanbul",
        ),
        FavoriteRestaurant(
          id: "fr2",
          name: "Mikla",
          cuisine: "Modern Türk",
          location: "İstanbul",
        ),
        FavoriteRestaurant(
          id: "fr3",
          name: "Kronotrop",
          cuisine: "Kahve",
          location: "Ankara",
        ),
      ],
      recurringOrders: [
        RecurringOrder(
          id: "ro1",
          restaurantName: "Domino's Pizza",
          orderDescription: "Büyük Boy Karışık Pizza",
          frequency: "Her Cuma akşamı",
        ),
        RecurringOrder(
          id: "ro2",
          restaurantName: "Starbucks",
          orderDescription: "Büyük Boy Latte",
          frequency: "Her sabah işe giderken",
        ),
      ],
      loyaltyCards: [
        CafeLoyaltyCard(
          id: "cl1",
          cafeName: "Kronotrop",
          stampsCollected: 7,
          stampsRequired: 10,
          rewardDescription: "1 Ücretsiz Filtre Kahve",
        ),
        CafeLoyaltyCard(
          id: "cl2",
          cafeName: "Starbucks Rewards",
          stampsCollected: 145,
          stampsRequired: 200,
          rewardDescription: "Ücretsiz İçecek",
        ),
        CafeLoyaltyCard(
          id: "cl3",
          cafeName: "Simit Sarayı",
          discountPercent: 15,
          rewardDescription: "Kart sahiplerine sabit indirim",
        ),
      ],
    ),
    const UserPostCard(id: "post1", mediaUrl: "", caption: "İlk paylaşım"),
    const UserPostCard(id: "post2", mediaUrl: "", caption: "İkinci paylaşım"),
    const UserPostCard(id: "post3", mediaUrl: "", caption: "Üçüncü paylaşım"),
  ];

  @override
  Future<List<FeedCard>> fetchProfileFeed(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_cards);
  }

  @override
  Future<void> addPost(FeedCard post) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cards.add(post);
  }
}
