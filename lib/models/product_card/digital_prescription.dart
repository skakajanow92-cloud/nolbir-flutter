/// Reçeteli ürün satın alabilmek için gereken, dijital imzalı ve
/// kopyalanamaz (salt-okunur) reçete kaydı. `id`, sistemde reçeteyi
/// benzersiz şekilde tanımlayan reçete numarasıdır.
class DigitalPrescription {
  final String id;
  final String patientName;
  final String issuingDoctorName;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String digitalSignatureHash;
  final List<String> prescribedItemNames;

  const DigitalPrescription({
    required this.id,
    required this.patientName,
    required this.issuingDoctorName,
    required this.issuedAt,
    required this.expiresAt,
    required this.digitalSignatureHash,
    required this.prescribedItemNames,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool covers(String itemName) =>
      prescribedItemNames.any((n) => n.toLowerCase() == itemName.toLowerCase());
}

/// Mock bir reçete sorgusu — gerçek backend'de bu, e-Reçete benzeri bir
/// sisteme bağlı bir sorgu olur. Reçete numarasından (id) deterministik
/// bir reçete üretir; biçimi tutmayan ya da çok kısa girişlerde null
/// döner.
DigitalPrescription? lookupPrescription(String prescriptionId) {
  final trimmed = prescriptionId.trim();
  if (trimmed.length < 6) return null;
  final seed = trimmed.hashCode.abs();
  const patients = ["Ahmet Y.", "Zeynep A.", "Mert C."];
  const doctors = ["Dr. Elif Demir", "Dr. Burak Şen"];
  const items = ["Amoksisilin 1000mg", "Parol 500mg", "Augmentin BID"];
  return DigitalPrescription(
    id: trimmed,
    patientName: patients[seed % patients.length],
    issuingDoctorName: doctors[seed % doctors.length],
    issuedAt: DateTime.now().subtract(Duration(days: seed % 10)),
    expiresAt: DateTime.now().add(Duration(days: 10 - (seed % 10))),
    digitalSignatureHash:
        "SIG-${trimmed.hashCode.toRadixString(16).toUpperCase()}",
    prescribedItemNames: [items[seed % items.length]],
  );
}
