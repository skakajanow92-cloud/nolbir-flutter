import 'base.dart';
import '../hosting.dart';

/// Yirmi dördüncü profil modülü: kullanıcı adına kayıtlı hosting
/// varlıkları — kiralanan VPS/VDS/dedicated sunucular, farklı
/// firmalardan hosting paketleri, domainler ve SSL sertifikaları; her
/// birinin ödeme/yenileme tarihi ve tutarı.
///
/// NOT: Dört farklı varlık türü tek bir `nextAlertPayment`de birleşiyor
/// — sunucu/paket 7 günlük, domain/SSL 30 günlük eşikle (bkz.
/// hosting.dart). `totalMonthlyOutlay` farklı fatura döngülerini
/// (aylık/3 aylık/yıllık) `monthlyEquivalent` ile normalize ediyor.
class HostingProfileCard extends FeedCard implements Collectible {
  final List<HostedServer> servers;
  final List<HostingPackage> hostingPackages;
  final List<Domain> domains;
  final List<SslCertificate> sslCertificates;

  const HostingProfileCard({
    required String id,
    this.servers = const [],
    this.hostingPackages = const [],
    this.domains = const [],
    this.sslCertificates = const [],
  }) : super(id);

  double get totalMonthlyOutlay {
    var total = 0.0;
    for (final s in servers) {
      total += s.monthlyEquivalent;
    }
    for (final p in hostingPackages) {
      total += p.monthlyEquivalent;
    }
    for (final d in domains) {
      total += d.paymentAmount / 12;
    }
    for (final c in sslCertificates) {
      total += c.paymentAmount / 12;
    }
    return total;
  }

  /// Dört farklı varlık türünü (sunucu/paket/domain/SSL) tek bir listede
  /// birleştirip en yakın ödeme/yenilemeyi döndürür — kendi eşiği
  /// içindeyse (sunucu/paket: 7 gün, domain/SSL: 30 gün).
  ({String label, DateTime date})? get nextAlertPayment {
    final now = DateTime.now();
    final candidates = <({String label, DateTime date, int thresholdDays})>[];

    for (final s in servers) {
      candidates.add((
        label: "${s.label} (${s.provider})",
        date: s.nextPaymentDate,
        thresholdDays: 7,
      ));
    }
    for (final p in hostingPackages) {
      candidates.add((
        label: "${p.packageName} (${p.provider})",
        date: p.nextPaymentDate,
        thresholdDays: 7,
      ));
    }
    for (final d in domains) {
      candidates.add((label: d.domainName, date: d.expiryDate, thresholdDays: 30));
    }
    for (final c in sslCertificates) {
      candidates.add((
        label: "${c.domainName} SSL",
        date: c.expiryDate,
        thresholdDays: 30,
      ));
    }

    final due = candidates
        .where((c) => c.date.difference(now).inDays <= c.thresholdDays)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (due.isEmpty) return null;
    return (label: due.first.label, date: due.first.date);
  }

  @override
  (String, String) toCollectionPreview() => ("Hosting Profili", "");
}