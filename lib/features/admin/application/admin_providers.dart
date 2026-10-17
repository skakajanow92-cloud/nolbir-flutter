import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/admin_application.dart';

part 'admin_providers.g.dart';

/// Admin başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
/// state korunur.
@riverpod
class AdminApplicationDraft extends _$AdminApplicationDraft {
  @override
  AdminApplication build() => const AdminApplication();

  void updateBasics({
    required AdminRole? role,
    required String fullName,
    required String nationalOrPassportNo,
    required String email,
    required String phone,
    required bool isForeignNational,
  }) {
    state = state.copyWith(
      role: role,
      fullName: fullName,
      nationalOrPassportNo: nationalOrPassportNo,
      email: email,
      phone: phone,
      isForeignNational: isForeignNational,
    );
  }

  void updateExpectations({
    required int yearsOfExperience,
    required double expectedMonthlySalary,
    required DateTime? availableFrom,
    required String coverLetter,
  }) {
    state = state.copyWith(
      yearsOfExperience: yearsOfExperience,
      expectedMonthlySalary: expectedMonthlySalary,
      availableFrom: availableFrom,
      coverLetter: coverLetter,
    );
  }

  void addDocument(AdminDocument document) {
    final others =
        state.documents.where((d) => d.type != document.type).toList();
    state = state.copyWith(documents: [...others, document]);
  }

  void removeDocument(AdminDocumentType type) {
    state = state.copyWith(
      documents: state.documents.where((d) => d.type != type).toList(),
    );
  }

  void updateDocumentNumber(AdminDocumentType type, String number) {
    final docs = state.documents
        .map((d) => d.type == type ? d.copyWith(documentNumber: number) : d)
        .toList();
    state = state.copyWith(documents: docs);
  }

  void setAcceptances({bool? confidentiality, bool? dataProcessing}) {
    state = state.copyWith(
      acceptedConfidentiality: confidentiality,
      acceptedDataProcessing: dataProcessing,
    );
  }

  /// NOT (bilinçli, geçici tasarım kararı — shareholder/C1 ile aynı
  /// yaklaşım ama burada risk DAHA YÜKSEK): admin, kullanıcı verilerine ve
  /// onay yetkilerine erişen ayrıcalıklı bir rol. Gerçek süreçte bu başvuru
  /// İK incelemesi → mülakat → arka plan doğrulaması → İNSAN onayı
  /// zincirinden geçer. Demo modunda gönderim doğrudan "Onaylandı"ya
  /// geçiyor ki akış test edilebilsin. Backend bağlanınca `submit()` sadece
  /// "Gönderildi"ye geçmeli; onay SUNUCU tarafında, yetkili bir kişiyle
  /// verilmeli. `isAdmin` ASLA istemci state'ine güvenilerek bir yetki
  /// kapısı olarak kullanılmamalı — sunucu her admin işleminde yetkiyi
  /// kendisi doğrulamalı.
  void submit() {
    state = state.copyWith(
      status: AdminApplicationStatus.approved,
      submittedAt: DateTime.now(),
    );
  }
}

/// `isAdmin` — SADECE başvuru onaylandığında true olur.
@riverpod
bool isAdmin(Ref ref) {
  final status =
      ref.watch(adminApplicationDraftProvider.select((a) => a.status));
  return status == AdminApplicationStatus.approved;
}
