/// Sunucu türü.
enum ServerType { vps, vds, dedicated }

extension ServerTypeLabel on ServerType {
  String get label => switch (this) {
        ServerType.vps => "VPS",
        ServerType.vds => "VDS",
        ServerType.dedicated => "Dedicated Sunucu",
      };
}

/// Hosting ürününün (sunucu/paket) durumu.
enum HostingStatus { active, suspended, expired, provisioning }

extension HostingStatusLabel on HostingStatus {
  String get label => switch (this) {
        HostingStatus.active => "Aktif",
        HostingStatus.suspended => "Askıya Alındı",
        HostingStatus.expired => "Süresi Doldu",
        HostingStatus.provisioning => "Kurulum Aşamasında",
      };
}

/// Fatura döngüsü.
enum BillingCycle { monthly, quarterly, yearly }

extension BillingCycleLabel on BillingCycle {
  String get label => switch (this) {
        BillingCycle.monthly => "Aylık",
        BillingCycle.quarterly => "3 Aylık",
        BillingCycle.yearly => "Yıllık",
      };

  /// Bir ödemeyi aylık karşılığa çevirmek için bölen — farklı fatura
  /// döngülerini (aylık/3 aylık/yıllık) tek bir ortak birime indirger.
  int get monthDivisor => switch (this) {
        BillingCycle.monthly => 1,
        BillingCycle.quarterly => 3,
        BillingCycle.yearly => 12,
      };
}

/// Kullanıcı adına kiralanmış tek bir VPS/VDS/dedicated sunucu.
class HostedServer {
  final String id;
  final String provider;
  final ServerType type;
  final String label; // kullanıcının verdiği ad, örn. "Prod API Sunucusu"
  final String ipAddress;
  final int cpuCores;
  final int ramGb;
  final int diskGb;
  final String os;
  final HostingStatus status;
  final String? managementPanelUrl;
  final DateTime nextPaymentDate;
  final double paymentAmount;
  final String currency;
  final BillingCycle billingCycle;

  const HostedServer({
    required this.id,
    required this.provider,
    required this.type,
    required this.label,
    required this.ipAddress,
    required this.cpuCores,
    required this.ramGb,
    required this.diskGb,
    required this.os,
    this.status = HostingStatus.active,
    this.managementPanelUrl,
    required this.nextPaymentDate,
    required this.paymentAmount,
    this.currency = "TRY",
    this.billingCycle = BillingCycle.monthly,
  });

  double get monthlyEquivalent => paymentAmount / billingCycle.monthDivisor;
}

/// Farklı bir firmadan kiralanmış paylaşımlı hosting paketi.
class HostingPackage {
  final String id;
  final String provider;
  final String packageName;
  final String scopeDescription; // paketin içeriği/kapsamı
  final int? diskGb;
  final int? bandwidthGb;
  final HostingStatus status;
  final String? managementPanelUrl;
  final DateTime nextPaymentDate;
  final double paymentAmount;
  final String currency;
  final BillingCycle billingCycle;

  const HostingPackage({
    required this.id,
    required this.provider,
    required this.packageName,
    required this.scopeDescription,
    this.diskGb,
    this.bandwidthGb,
    this.status = HostingStatus.active,
    this.managementPanelUrl,
    required this.nextPaymentDate,
    required this.paymentAmount,
    this.currency = "TRY",
    this.billingCycle = BillingCycle.monthly,
  });

  double get monthlyEquivalent => paymentAmount / billingCycle.monthDivisor;
}

/// Kullanıcı adına kayıtlı bir alan adı (domain).
///
/// NOT: Sunucu/pakette olduğu gibi bir fatura döngüsü YOK — domainler
/// tek bir `expiryDate`e sahip, `paymentAmount` yıllık bedeldir (bkz.
/// HostingProfileCard.totalMonthlyOutlay'daki /12 normalize mantığı).
class Domain {
  final String id;
  final String domainName;
  final String registrar;
  final DateTime registrationDate;
  final DateTime expiryDate;
  final bool autoRenew;
  final String? managementPanelUrl;
  final double paymentAmount; // yıllık bedel
  final String currency;

  const Domain({
    required this.id,
    required this.domainName,
    required this.registrar,
    required this.registrationDate,
    required this.expiryDate,
    this.autoRenew = false,
    this.managementPanelUrl,
    required this.paymentAmount,
    this.currency = "TRY",
  });
}

/// SSL sertifikası türü.
enum SslCertType { dv, ov, ev, wildcard }

extension SslCertTypeLabel on SslCertType {
  String get label => switch (this) {
        SslCertType.dv => "DV",
        SslCertType.ov => "OV",
        SslCertType.ev => "EV",
        SslCertType.wildcard => "Wildcard",
      };
}

/// Kullanıcı adına kayıtlı bir SSL sertifikası.
class SslCertificate {
  final String id;
  final String domainName;
  final String provider;
  final SslCertType certType;
  final DateTime issueDate;
  final DateTime expiryDate;
  final double paymentAmount; // yıllık bedel (ücretsizse 0)
  final String currency;

  const SslCertificate({
    required this.id,
    required this.domainName,
    required this.provider,
    required this.certType,
    required this.issueDate,
    required this.expiryDate,
    this.paymentAmount = 0,
    this.currency = "TRY",
  });
}
