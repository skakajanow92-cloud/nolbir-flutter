import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/shareholder_application.dart';

part 'shareholder_providers.g.dart';

/// Ortaklık başvurusunun ilerleyen taslağı — sihirbazın adımları arasında
/// state korunur.
@riverpod
class ShareholderApplicationDraft extends _$ShareholderApplicationDraft {
  @override
  ShareholderApplication build() => const ShareholderApplication();

  void updatePersonalInfo({
    required String fullName,
    required String nationalOrPassportNo,
    required String email,
    required String phone,
  }) {
    state = state.copyWith(
      fullName: fullName,
      nationalOrPassportNo: nationalOrPassportNo,
      email: email,
      phone: phone,
    );
  }

  void updateFinancials({
    required double requestedEquityPercent,
    required double cashContribution,
  }) {
    state = state.copyWith(
      requestedEquityPercent: requestedEquityPercent,
      cashContribution: cashContribution,
    );
  }

  void addAsset(AssetContribution asset) {
    state =
        state.copyWith(assetContributions: [...state.assetContributions, asset]);
  }

  void removeAsset(String assetId) {
    state = state.copyWith(
      assetContributions:
          state.assetContributions.where((a) => a.id != assetId).toList(),
    );
  }

  void addDocument(UploadedDocument document) {
    final others =
        state.documents.where((d) => d.type != document.type).toList();
    state = state.copyWith(documents: [...others, document]);
  }

  void removeDocument(DocumentType type) {
    state = state.copyWith(
      documents: state.documents.where((d) => d.type != type).toList(),
    );
  }

  void updateDocumentNumber(DocumentType type, String number) {
    final docs = state.documents
        .map((d) => d.type == type ? d.copyWith(documentNumber: number) : d)
        .toList();
    state = state.copyWith(documents: docs);
  }

  /// NOT (bilinçli, geçici tasarım kararı — verification akışındaki C1
  /// ile aynı yaklaşım): gerçek süreçte bu başvuru bir hukuk/uyum (legal/
  /// compliance) ekibi incelemesine düşer ve "İnceleniyor" durumunda
  /// BEKLER — belge doğrulaması, mülakat, arka plan kontrolü günler/
  /// haftalar sürebilir. Demo modunda gönderim DOĞRUDAN "Onaylandı"
  /// durumuna geçiyor ki `isShareholderProvider` test edilebilsin.
  /// Backend bağlanınca: submit() sadece "Gönderildi"ye geçmeli, onay/red
  /// ayrı bir admin akışından (insan kararıyla) gelmeli.
  void submit() {
    state = state.copyWith(
      status: ShareholderApplicationStatus.approved,
      submittedAt: DateTime.now(),
    );
  }
}

/// `isShareholder` — SADECE başvuru onaylandığında true olur.
@riverpod
bool isShareholder(Ref ref) {
  final status =
      ref.watch(shareholderApplicationDraftProvider.select((a) => a.status));
  return status == ShareholderApplicationStatus.approved;
}
