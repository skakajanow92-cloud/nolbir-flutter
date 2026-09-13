/// Poliçe türü.
enum InsurancePolicyType { health, vehicle, home, life, travel }

extension InsurancePolicyTypeLabel on InsurancePolicyType {
  String get label => switch (this) {
        InsurancePolicyType.health => "Sağlık",
        InsurancePolicyType.vehicle => "Kasko",
        InsurancePolicyType.home => "Konut",
        InsurancePolicyType.life => "Hayat",
        InsurancePolicyType.travel => "Seyahat",
      };
}

/// Bir sigorta şirketinden alınmış tek bir poliçe.
class InsurancePolicy {
  final String id;
  final String company;
  final InsurancePolicyType type;
  final String policyNumber;
  final double premium;
  final String currency;
  final double coverageAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const InsurancePolicy({
    required this.id,
    required this.company,
    required this.type,
    required this.policyNumber,
    required this.premium,
    required this.coverageAmount,
    required this.startDate,
    required this.endDate,
    this.currency = "TRY",
    this.isActive = true,
  });
}
