import '../../../models/feed_card/feed_card.dart';
import '../../../models/insurance.dart';

/// Sigorta modülünün demo verisi.
/// Gerçek uygulamada bu veri API/DB'den gelecek; burada tek bir
/// fonksiyonda toplandı ki modülün verisi kendi dosyasında dursun.
InsuranceProfileCard buildInsuranceMock() {
  return InsuranceProfileCard(
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
  );
}
