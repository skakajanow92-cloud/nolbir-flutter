import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/shareholder_application.dart';
import '../application/shareholder_providers.dart';

/// Holding'e Ortaklık Başvurusu — 5 adımlı sihirbaz.
///
/// TASARIM NOTU: `Stepper` widget'ı kullanıldı (dikey, adım adım) —
/// içerik tek bir belge yükleme ekranından çok daha fazla veri ve dosya
/// topluyor, tek bir uzun form yerine adımlara bölünmesi hem kullanıcıyı
/// yormuyor hem de "Gözden Geçir" adımında eksikleri net gösterebiliyor.
class ShareholderApplicationWizardView extends ConsumerStatefulWidget {
  const ShareholderApplicationWizardView({super.key});

  @override
  ConsumerState<ShareholderApplicationWizardView> createState() =>
      _ShareholderApplicationWizardViewState();
}

class _ShareholderApplicationWizardViewState
    extends ConsumerState<ShareholderApplicationWizardView> {
  static const accent = Color(0xFF8A5A2E);

  int _currentStep = 0;

  final _fullNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _equityController = TextEditingController();
  final _cashController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(shareholderApplicationDraftProvider);
    _fullNameController.text = draft.fullName;
    _idNumberController.text = draft.nationalOrPassportNo;
    _emailController.text = draft.email;
    _phoneController.text = draft.phone;
    _equityController.text = draft.requestedEquityPercent > 0
        ? "${draft.requestedEquityPercent}"
        : "";
    _cashController.text = draft.cashContribution > 0
        ? "${draft.cashContribution}"
        : "";
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _equityController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  void _savePersonalInfo() {
    ref
        .read(shareholderApplicationDraftProvider.notifier)
        .updatePersonalInfo(
          fullName: _fullNameController.text.trim(),
          nationalOrPassportNo: _idNumberController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );
  }

  void _saveFinancials() {
    ref
        .read(shareholderApplicationDraftProvider.notifier)
        .updateFinancials(
          requestedEquityPercent: double.tryParse(_equityController.text) ?? 0,
          cashContribution: double.tryParse(_cashController.text) ?? 0,
        );
  }

  /// NOT: `withData: true` — Flutter Web'de gerçek dosya yolu yok, bu
  /// bayrak olmadan `bytes` null gelir ve önizleme/kayıt çalışmaz.
  Future<void> _pickDocument(DocumentType type) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result.isEmpty) return;
    final file = result.single;
    Uint8List bytes = await file.readAsBytes();

    ref
        .read(shareholderApplicationDraftProvider.notifier)
        .addDocument(
          UploadedDocument(
            type: type,
            fileName: file.name,
            bytes: bytes,
            fileSizeBytes: bytes.elementSizeInBytes,
            uploadedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _openAddAssetSheet() async {
    final asset = await showModalBottomSheet<AssetContribution>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF17141C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddAssetSheet(),
    );
    if (asset != null) {
      ref.read(shareholderApplicationDraftProvider.notifier).addAsset(asset);
    }
  }

  void _submit() {
    _savePersonalInfo();
    _saveFinancials();
    final draft = ref.read(shareholderApplicationDraftProvider);
    if (!draft.isComplete) {
      final reasons = <String>[];
      if (draft.fullName.isEmpty ||
          draft.nationalOrPassportNo.isEmpty ||
          draft.email.isEmpty ||
          draft.phone.isEmpty) {
        reasons.add("kişisel bilgiler eksik");
      }
      if (draft.requestedEquityPercent <= 0) {
        reasons.add("hisse oranı girilmedi");
      }
      if (draft.missingRequiredDocuments.isNotEmpty) {
        reasons.add(
          "eksik belge: ${draft.missingRequiredDocuments.map((d) => d.label).join(', ')}",
        );
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(reasons.join(' · '))));
      return;
    }

    ref.read(shareholderApplicationDraftProvider.notifier).submit();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Ortaklık başvurun alındı.")));
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(shareholderApplicationDraftProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0D14),
        title: const Text("Ortaklık Başvurusu"),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: accent),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) _savePersonalInfo();
            if (_currentStep == 2) _saveFinancials();
            if (_currentStep < _steps(draft).length - 1) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          onStepTapped: (i) => setState(() => _currentStep = i),
          controlsBuilder: (context, details) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: details.onStepContinue,
                  child: Text(
                    _currentStep == _steps(draft).length - 1
                        ? "Başvuruyu Gönder"
                        : "Devam",
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Geri"),
                  ),
              ],
            ),
          ),
          steps: _steps(draft),
        ),
      ),
    );
  }

  List<Step> _steps(ShareholderApplication draft) => [
    Step(
      title: const Text("Kişisel Bilgiler"),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: _PersonalInfoStep(
        fullNameController: _fullNameController,
        idNumberController: _idNumberController,
        emailController: _emailController,
        phoneController: _phoneController,
      ),
    ),
    Step(
      title: const Text("Kimlik ve Fotoğraf"),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: _DocumentsStep(
        types: const [
          DocumentType.identityCard,
          DocumentType.passport,
          DocumentType.applicantPhoto,
        ],
        draft: draft,
        onPick: _pickDocument,
        onRemove: (t) => ref
            .read(shareholderApplicationDraftProvider.notifier)
            .removeDocument(t),
        onNumberChanged: (t, v) => ref
            .read(shareholderApplicationDraftProvider.notifier)
            .updateDocumentNumber(t, v),
      ),
    ),
    Step(
      title: const Text("Mali Katkı ve Varlıklar"),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: _FinancialsStep(
        equityController: _equityController,
        cashController: _cashController,
        draft: draft,
        onAddAsset: _openAddAssetSheet,
        onRemoveAsset: (id) => ref
            .read(shareholderApplicationDraftProvider.notifier)
            .removeAsset(id),
      ),
    ),
    Step(
      title: const Text("Ek Belgeler"),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: _DocumentsStep(
        types: const [
          DocumentType.criminalRecord,
          DocumentType.financialStatement,
          DocumentType.taxRegistration,
          DocumentType.sourceOfFundsDeclaration,
          DocumentType.mentalHealthReport,
          DocumentType.referenceLetter,
        ],
        draft: draft,
        onPick: _pickDocument,
        onRemove: (t) => ref
            .read(shareholderApplicationDraftProvider.notifier)
            .removeDocument(t),
        onNumberChanged: (t, v) => ref
            .read(shareholderApplicationDraftProvider.notifier)
            .updateDocumentNumber(t, v),
      ),
    ),
    Step(
      title: const Text("Gözden Geçir & Gönder"),
      isActive: _currentStep >= 4,
      state: StepState.indexed,
      content: _ReviewStep(draft: draft),
    ),
  ];
}

class _PersonalInfoStep extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController idNumberController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const _PersonalInfoStep({
    required this.fullNameController,
    required this.idNumberController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(fullNameController, "Ad Soyad"),
        const SizedBox(height: 12),
        _field(idNumberController, "T.C. Kimlik No / Pasaport No"),
        const SizedBox(height: 12),
        _field(
          emailController,
          "E-posta",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _field(phoneController, "Telefon", keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  final List<DocumentType> types;
  final ShareholderApplication draft;
  final void Function(DocumentType type) onPick;
  final void Function(DocumentType type) onRemove;
  final void Function(DocumentType type, String number) onNumberChanged;

  const _DocumentsStep({
    required this.types,
    required this.draft,
    required this.onPick,
    required this.onRemove,
    required this.onNumberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final type in types) ...[
          _DocumentUploadTile(
            type: type,
            uploaded: draft.documentOf(type),
            onPick: () => onPick(type),
            onRemove: () => onRemove(type),
            onDocumentNumberChanged: (v) => onNumberChanged(type, v),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _DocumentUploadTile extends StatefulWidget {
  final DocumentType type;
  final UploadedDocument? uploaded;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final void Function(String) onDocumentNumberChanged;

  const _DocumentUploadTile({
    required this.type,
    required this.uploaded,
    required this.onPick,
    required this.onRemove,
    required this.onDocumentNumberChanged,
  });

  @override
  State<_DocumentUploadTile> createState() => _DocumentUploadTileState();
}

class _DocumentUploadTileState extends State<_DocumentUploadTile> {
  late final TextEditingController _numberController = TextEditingController(
    text: widget.uploaded?.documentNumber ?? "",
  );

  static const _accent = Color(0xFF8A5A2E);

  @override
  void didUpdateWidget(covariant _DocumentUploadTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uploaded?.fileName != widget.uploaded?.fileName) {
      _numberController.text = widget.uploaded?.documentNumber ?? "";
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploaded = widget.uploaded;
    final isUploaded = uploaded != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isUploaded ? _accent : Colors.white).withValues(
          alpha: isUploaded ? 0.14 : 0.04,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? _accent.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Preview(uploaded: uploaded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.type.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (widget.type.isRequired) ...[
                          const SizedBox(width: 4),
                          const Text(
                            "*",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUploaded ? uploaded.fileName : widget.type.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isUploaded ? Colors.white70 : Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isUploaded ? Icons.close : Icons.upload_file_outlined,
                  color: isUploaded ? Colors.white54 : _accent,
                ),
                onPressed: isUploaded ? widget.onRemove : widget.onPick,
              ),
            ],
          ),
          if (isUploaded) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _numberController,
              onChanged: widget.onDocumentNumberChanged,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                labelText: "Belge No (opsiyonel)",
                labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final UploadedDocument? uploaded;
  const _Preview({required this.uploaded});

  @override
  Widget build(BuildContext context) {
    if (uploaded == null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.description_outlined,
          color: Colors.white24,
          size: 20,
        ),
      );
    }
    if (uploaded!.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          uploaded!.bytes,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    // PDF — gerçek sayfa önizlemesi için bir render paketi (ör.
    // flutter_pdfview) gerekir; şimdilik tür simgesiyle gösteriliyor.
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF8A5A2E).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.picture_as_pdf_outlined,
        color: Color(0xFF8A5A2E),
        size: 20,
      ),
    );
  }
}

class _FinancialsStep extends StatelessWidget {
  final TextEditingController equityController;
  final TextEditingController cashController;
  final ShareholderApplication draft;
  final VoidCallback onAddAsset;
  final void Function(String assetId) onRemoveAsset;

  const _FinancialsStep({
    required this.equityController,
    required this.cashController,
    required this.draft,
    required this.onAddAsset,
    required this.onRemoveAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: equityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Talep Edilen Hisse Oranı (%)",
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: cashController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Nakit Katkı (TRY)",
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Varlık Katkıları",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            TextButton.icon(
              onPressed: onAddAsset,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Varlık Ekle"),
            ),
          ],
        ),
        if (draft.assetContributions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Henüz varlık eklenmedi (opsiyonel)",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          )
        else
          for (final asset in draft.assetContributions)
            _AssetTile(asset: asset, onRemove: () => onRemoveAsset(asset.id)),
        if (draft.totalContribution > 0) ...[
          const SizedBox(height: 12),
          Text(
            "Toplam katkı: ${_formatMoney(draft.totalContribution)} TRY",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ],
    );
  }
}

class _AssetTile extends StatelessWidget {
  final AssetContribution asset;
  final VoidCallback onRemove;
  const _AssetTile({required this.asset, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            _iconForAsset(asset.type),
            color: const Color(0xFF8A5A2E),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${asset.type.label} · ${_formatMoney(asset.estimatedValue)} ${asset.currency}"
                  "${asset.proofDocument != null ? ' · Belge eklendi' : ' · Belge eksik'}",
                  style: TextStyle(
                    color: asset.proofDocument != null
                        ? Colors.white54
                        : Colors.orangeAccent,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white38, size: 18),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _AddAssetSheet extends StatefulWidget {
  const _AddAssetSheet();

  @override
  State<_AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<_AddAssetSheet> {
  AssetType _type = AssetType.realEstate;
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  Uint8List? _proofBytes;
  String? _proofFileName;

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result.isEmpty) return;
    final file = result.single;
    Uint8List bytes = await file.readAsBytes();
    setState(() {
      _proofBytes = bytes;
      _proofFileName = file.name;
    });
  }

  void _save() {
    if (_descriptionController.text.trim().isEmpty) return;
    final value = double.tryParse(_valueController.text.trim()) ?? 0;
    if (value <= 0) return;

    final asset = AssetContribution(
      id: "asset_${DateTime.now().millisecondsSinceEpoch}",
      type: _type,
      description: _descriptionController.text.trim(),
      estimatedValue: value,
      proofDocument: _proofBytes != null
          ? UploadedDocument(
              type: DocumentType.assetProof,
              fileName: _proofFileName!,
              bytes: _proofBytes!,
              fileSizeBytes: _proofBytes!.length,
              uploadedAt: DateTime.now(),
            )
          : null,
    );
    Navigator.of(context).pop(asset);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Varlık Ekle",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AssetType>(
              value: _type,
              dropdownColor: const Color(0xFF17141C),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Varlık Türü",
                labelStyle: TextStyle(color: Colors.white54),
              ),
              items: AssetType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Açıklama",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Tahmini Değer (TRY)",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickProof,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(_proofFileName ?? "Tapu/Ruhsat vb. Belge Ekle"),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8A5A2E),
              ),
              onPressed: _save,
              child: const Text("Ekle"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final ShareholderApplication draft;
  const _ReviewStep({required this.draft});

  @override
  Widget build(BuildContext context) {
    final missing = draft.missingRequiredDocuments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row("Ad Soyad", draft.fullName),
        _row("Kimlik/Pasaport No", draft.nationalOrPassportNo),
        _row("E-posta", draft.email),
        _row("Telefon", draft.phone),
        _row(
          "Talep Edilen Hisse",
          "%${draft.requestedEquityPercent.toStringAsFixed(1)}",
        ),
        _row("Toplam Katkı", "${_formatMoney(draft.totalContribution)} TRY"),
        _row("Yüklenen Belge", "${draft.documents.length}"),
        _row("Varlık Sayısı", "${draft.assetContributions.length}"),
        const SizedBox(height: 12),
        if (missing.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Eksik zorunlu belgeler: ${missing.map((d) => d.label).join(', ')}",
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          )
        else
          const Text(
            "Tüm zorunlu belgeler tamam — başvuruyu gönderebilirsin.",
            style: TextStyle(color: Colors.greenAccent, fontSize: 12),
          ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? "—" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForAsset(AssetType type) => switch (type) {
  AssetType.realEstate => Icons.home_work_outlined,
  AssetType.vehicle => Icons.directions_car_outlined,
  AssetType.cash => Icons.payments_outlined,
  AssetType.other => Icons.inventory_2_outlined,
};

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
