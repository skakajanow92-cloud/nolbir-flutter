enum AffiliationType { organization, community }

extension AffiliationTypeLabel on AffiliationType {
  String get label => switch (this) {
        AffiliationType.organization => "Kuruluş",
        AffiliationType.community => "Topluluk",
      };
}

/// Kullanıcının ait olduğunu belirttiği bir kuruluş ya da topluluk.
class Affiliation {
  final String id;
  final String name;
  final AffiliationType type;
  final String? role; // örn. "Gönüllü", "Yönetim Kurulu Üyesi" — opsiyonel

  const Affiliation({
    required this.id,
    required this.name,
    required this.type,
    this.role,
  });
}

/// Kullanıcının yaptığı bir bağış.
class Donation {
  final String id;
  final String organization;
  final double amount;
  final String currency;
  final DateTime date;
  final bool isRecurring;

  const Donation({
    required this.id,
    required this.organization,
    required this.amount,
    required this.date,
    this.currency = "TRY",
    this.isRecurring = false,
  });
}
