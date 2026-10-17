import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/document_upload_tile.dart';
import '../../../models/admin_application.dart';
import '../application/admin_providers.dart';

/// Maaşlı admin pozisyonu başvuru sihirbazı — 5 adım:
/// 1) Pozisyon & kişisel bilgiler  2) Deneyim & beklentiler
/// 3) Kimlik & fotoğraf            4) Mesleki belgeler
/// 5) Taahhütler & gönder
///
/// Shareholder formundan farkı: mal varlığı/hisse yok; bunun yerine
/// pozisyon, maaş beklentisi, deneyim ve güvenilirlik belgeleri (adli sicil
/// vb.) var. Zorunlu belgeler başvuruya göre DEĞİŞİR: yabancı uyruklu →
/// çalışma izni, finans pozisyonu → mesleki yeterlilik belgesi (bkz.
/// `AdminApplication.requiredDocumentTypes`).
class AdminApplicationWizardView extends ConsumerStatefulWidget {
  const AdminApplicationWizardView({super.key});

  @override
  ConsumerState<AdminApplicationWizardView> createState() =>
      _AdminApplicationWizardViewState();
}

class _AdminApplicationWizardViewState
    extends ConsumerState<AdminApplicationWizardView> {
  static const _accent = Color(0xFF6F8296);
  static const _bg = Color(0xFF0F1114);

  int _currentStep = 0;
  AdminRole? _role;
  bool _isForeign = false;
  DateTime? _availableFrom;

  final _fullName = TextEditingController();
  final _idNo = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _years = TextEditingController();
  final _salary = TextEditingController();
  final _coverLetter = TextEditingController();

  @override
  void initState() {
    super.initState();
    final d = ref.read(adminApplicationDraftProvider);
    _role = d.role;
    _isForeign = d.isForeignNational;
    _availableFrom = d.availableFrom;
    _fullName.text = d.fullName;
    _idNo.text = d.nationalOrPassportNo;
    _email.text = d.email;
    _phone.text = d.phone;
    _years.text = d.yearsOfExperience > 0 ? "${d.yearsOfExperience}" : "";
    _salary.text =
        d.expectedMonthlySalary > 0 ? d.expectedMonthlySalary.toStringAsFixed(0) : "";
    _coverLetter.text = d.coverLetter;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _idNo.dispose();
    _email.dispose();
    _phone.dispose();
    _years.dispose();
    _salary.dispose();
    _coverLetter.dispose();
    super.dispose();
  }

  /// Form alanlarını taslağa yazar. Adım değiştirirken ve göndermeden önce
  /// çağrılıyor — özellikle pozisyon/uyruk değişince zorunlu belge listesi
  /// değiştiği için sonraki adımların güncel taslağı görmesi şart.
  void _saveAll() {
    final n = ref.read(adminApplicationDraftProvider.notifier);
    n.updateBasics(
      role: _role,
      fullName: _fullName.text.trim(),
      nationalOrPassportNo: _idNo.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      isForeignNational: _isForeign,
    );
    n.updateExpectations(
      yearsOfExperience: int.tryParse(_years.text.trim()) ?? 0,
      expectedMonthlySalary:
          double.tryParse(_salary.text.trim().replaceAll(',', '.')) ?? 0,
      availableFrom: _availableFrom,
      coverLetter: _coverLetter.text.trim(),
    );
  }

  void _goTo(int step) {
    _saveAll();
    setState(() => _currentStep = step);
  }

  /// file_picker v13: tek dosya için `pickFile()` (iptalde null), içerik
  /// `readAsBytes()` ile okunuyor; web dahil her platformda çalışır.
  Future<void> _pickDocument(AdminDocumentType type) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    ref.read(adminApplicationDraftProvider.notifier).addDocument(
          AdminDocument(
            type: type,
            fileName: file.name,
            bytes: bytes,
            fileSizeBytes: bytes.length,
            uploadedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = (_availableFrom != null && _availableFrom!.isAfter(now))
        ? _availableFrom!
        : now.add(const Duration(days: 14));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _availableFrom = picked);
  }

  void _submit() {
    _saveAll();
    final draft = ref.read(adminApplicationDraftProvider);
    if (!draft.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Eksik: ${draft.missingItems.join(', ')}")),
      );
      return;
    }
    ref.read(adminApplicationDraftProvider.notifier).submit();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text("Admin başvurun alındı")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(adminApplicationDraftProvider);
    const lastStep = 4;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text("Admin Başvurusu"),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              Theme.of(context).colorScheme.copyWith(primary: _accent),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: _goTo,
          onStepContinue: () =>
              _currentStep == lastStep ? _submit() : _goTo(_currentStep + 1),
          onStepCancel: () {
            if (_currentStep > 0) _goTo(_currentStep - 1);
          },
          controlsBuilder: (context, details) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  style: FilledButton.styleFrom(backgroundColor: _accent),
                  child: Text(
                      _currentStep == lastStep ? "Başvuruyu Gönder" : "Devam"),
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
          steps: [
            _step(0, "Pozisyon & Kişisel Bilgiler", _basicsStep()),
            _step(1, "Deneyim & Beklentiler", _expectationsStep()),
            _step(2, "Kimlik & Fotoğraf", _identityStep(draft)),
            _step(3, "Mesleki Belgeler", _professionalStep(draft)),
            _step(4, "Taahhütler & Gönder", _reviewStep(draft)),
          ],
        ),
      ),
    );
  }

  Step _step(int index, String title, Widget content) => Step(
        title: Text(title),
        isActive: _currentStep >= index,
        state: _currentStep > index ? StepState.complete : StepState.indexed,
        content: content,
      );

  // ---------------------------------------------------------------- Adım 1
  Widget _basicsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Başvurulan Pozisyon *",
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AdminRole.values
              .map(
                (r) => ChoiceChip(
                  label: Text(r.label),
                  selected: _role == r,
                  onSelected: (_) => setState(() => _role = r),
                  selectedColor: _accent,
                  backgroundColor: Colors.white10,
                  labelStyle: TextStyle(
                    color: _role == r ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              )
              .toList(),
        ),
        if (_role != null) ...[
          const SizedBox(height: 8),
          Text(_role!.description,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          if (_role!.requiresProfessionalCertificate)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Bu pozisyon için mesleki yeterlilik belgesi zorunludur.",
                style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
              ),
            ),
        ],
        const SizedBox(height: 16),
        _field(_fullName, "Ad Soyad"),
        const SizedBox(height: 12),
        _field(_idNo, "T.C. Kimlik No / Pasaport No"),
        const SizedBox(height: 12),
        _field(_email, "E-posta", keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _field(_phone, "Telefon", keyboardType: TextInputType.phone),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isForeign,
          onChanged: (v) => setState(() => _isForeign = v),
          title: const Text("Yabancı uyrukluyum",
              style: TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: const Text("Çalışma izni belgesi zorunlu olur",
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- Adım 2
  Widget _expectationsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(_years, "Toplam Deneyim (yıl)",
            keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        _field(_salary, "Beklenen Aylık Maaş (TRY, brüt)",
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.event_outlined, size: 18),
          label: Text(_availableFrom == null
              ? "Başlayabileceğin Tarihi Seç"
              : "Başlangıç: ${_formatDate(_availableFrom!)}"),
        ),
        const SizedBox(height: 12),
        _field(_coverLetter, "Ön Yazı (kısaca kendini tanıt)", maxLines: 5),
      ],
    );
  }

  // ---------------------------------------------------------------- Adım 3
  Widget _identityStep(AdminApplication draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            draft.hasIdentityDocument
                ? "Kimlik/pasaport belgesi tamam"
                : "Kimlik veya pasaporttan en az biri zorunlu *",
            style: TextStyle(
              color: draft.hasIdentityDocument
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
              fontSize: 12,
            ),
          ),
        ),
        _docTile(AdminDocumentType.identityCard, draft, required: false),
        _docTile(AdminDocumentType.passport, draft, required: false),
        _docTile(AdminDocumentType.applicantPhoto, draft, required: true),
        _docTile(AdminDocumentType.residenceProof, draft, required: true),
        if (draft.isForeignNational)
          _docTile(AdminDocumentType.workPermit, draft, required: true),
      ],
    );
  }

  // ---------------------------------------------------------------- Adım 4
  Widget _professionalStep(AdminApplication draft) {
    final certRequired =
        draft.requiredDocumentTypes.contains(AdminDocumentType.professionalCertificate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _docTile(AdminDocumentType.resume, draft, required: true),
        _docTile(AdminDocumentType.diploma, draft, required: true),
        _docTile(AdminDocumentType.criminalRecord, draft, required: true),
        _docTile(AdminDocumentType.professionalCertificate, draft,
            required: certRequired),
        _docTile(AdminDocumentType.employmentHistory, draft, required: false),
        _docTile(AdminDocumentType.referenceLetter, draft, required: false),
      ],
    );
  }

  // ---------------------------------------------------------------- Adım 5
  Widget _reviewStep(AdminApplication draft) {
    final missing = draft.missingItems;
    final notifier = ref.read(adminApplicationDraftProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row("Pozisyon", draft.role?.label ?? ""),
        _row("Ad Soyad", draft.fullName),
        _row("Uyruk", draft.isForeignNational ? "Yabancı" : "Yerli"),
        _row("Deneyim", "${draft.yearsOfExperience} yıl"),
        _row(
          "Beklenen Maaş",
          draft.expectedMonthlySalary > 0
              ? "${_formatMoney(draft.expectedMonthlySalary)} ${draft.currency}"
              : "",
        ),
        _row("Başlangıç",
            draft.availableFrom == null ? "" : _formatDate(draft.availableFrom!)),
        _row("Zorunlu Belgeler",
            "${draft.completedDocumentSlotCount}/${draft.requiredDocumentSlotCount}"),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: _accent,
          value: draft.acceptedConfidentiality,
          onChanged: (v) =>
              notifier.setAcceptances(confidentiality: v ?? false),
          title: const Text(
            "Kullanıcı verilerinin gizliliğini koruyacağımı taahhüt ederim.",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: _accent,
          value: draft.acceptedDataProcessing,
          onChanged: (v) =>
              notifier.setAcceptances(dataProcessing: v ?? false),
          title: const Text(
            "Başvuru belgelerimin kişisel veri olarak işlenmesini onaylıyorum (KVKK).",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        if (missing.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Eksikler: ${missing.join(', ')}",
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          )
        else
          const Text(
            "Her şey tamam — başvuruyu gönderebilirsin.",
            style: TextStyle(color: Colors.greenAccent, fontSize: 12),
          ),
      ],
    );
  }

  // --------------------------------------------------------------- Yardımcı
  Widget _docTile(AdminDocumentType type, AdminApplication draft,
      {required bool required}) {
    final doc = draft.documentOf(type);
    final notifier = ref.read(adminApplicationDraftProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DocumentUploadTile(
        key: ValueKey(type),
        label: type.label,
        description: type.description,
        isRequired: required,
        fileName: doc?.fileName,
        bytes: doc?.bytes,
        isImage: doc?.isImage ?? false,
        documentNumber: doc?.documentNumber,
        accent: _accent,
        onPick: () => _pickDocument(type),
        onRemove: () => notifier.removeDocument(type),
        onDocumentNumberChanged: (v) => notifier.updateDocumentNumber(type, v),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
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

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

String _formatMoney(double value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
