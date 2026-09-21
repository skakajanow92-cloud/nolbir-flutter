import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/verification_providers.dart';

/// B1 doğrulama: kimlik/yerli evrak — ilgili ülkenin doğrulama sistemine
/// yönlendirme adımı.
///
/// NOT: Gerçek ülke doğrulama sistemi entegrasyonu (ör. e-Devlet) YOK —
/// bu adım demo modunda SİMÜLE EDİLİYOR (kısa bir gecikme). Gerçek
/// entegrasyon eklenince bu dosya değişecek ama VerificationProfileCard'ın
/// çağırma şekli aynı kalacak.
class NationalDocumentCardView extends ConsumerStatefulWidget {
  const NationalDocumentCardView({super.key});

  @override
  ConsumerState<NationalDocumentCardView> createState() =>
      _NationalDocumentCardViewState();
}

class _NationalDocumentCardViewState extends ConsumerState<NationalDocumentCardView> {
  static const accent = Color(0xFF1F7A8C);
  final _documentNumberController = TextEditingController();
  bool _redirecting = false;

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_documentNumberController.text.trim().isEmpty) return;
    setState(() => _redirecting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ref.read(userVerificationProvider.notifier).submitNationalDocument(
          documentNumber: _documentNumberController.text.trim(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Kimlik doğrulandı (B1)")));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.badge_outlined, color: accent, size: 40),
          const SizedBox(height: 12),
          const Text("Kimlik Doğrulama (B1)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            "T.C. kimlik no ya da ülke içinde geçerli bir yerli evrak ile "
            "ilgili ülkenin resmi doğrulama sistemine yönlendirileceksin.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _documentNumberController,
            enabled: !_redirecting,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: "T.C. Kimlik No / Belge No",
                labelStyle: TextStyle(color: Colors.white54)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: _redirecting ? null : _submit,
            child: _redirecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("Doğrulama Sistemine Gönder"),
          ),
        ],
      ),
    );
  }
}
