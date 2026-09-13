import '../../models/feed_card.dart';
import '../../models/wallet.dart';
import '../../models/insurance.dart';

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
