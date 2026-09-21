import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/verification_providers.dart';

/// B2 doğrulama: pasaport/uluslararası belge — ilgili ülkenin doğrulama
/// sistemine yönlendirme adımı (bkz. NationalDocumentCardView'daki aynı
/// simülasyon notu).
class InternationalDocumentCardView extends ConsumerStatefulWidget {
  const InternationalDocumentCardView({super.key});

  @override
  ConsumerState<InternationalDocumentCardView> createState() =>
      _InternationalDocumentCardViewState();
}

class _InternationalDocumentCardViewState
    extends ConsumerState<InternationalDocumentCardView> {
  static const accent = Color(0xFF1F7A8C);
  final _countryController = TextEditingController();
  final _passportNumberController = TextEditingController();
  bool _redirecting = false;

  @override
  void dispose() {
    _countryController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_countryController.text.trim().isEmpty ||
        _passportNumberController.text.trim().isEmpty) {
      return;
    }
    setState(() => _redirecting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ref.read(userVerificationProvider.notifier).submitInternationalDocument(
          documentNumber: _passportNumberController.text.trim(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Uluslararası doğrulama tamamlandı (B2)")));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.public_outlined, color: accent, size: 40),
          const SizedBox(height: 12),
          const Text("Uluslararası Doğrulama (B2)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            "Pasaport ya da geçerli uluslararası bir belge ile ilgili "
            "ülkenin resmi doğrulama sistemine yönlendirileceksin.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _countryController,
            enabled: !_redirecting,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: "Belgeyi Veren Ülke", labelStyle: TextStyle(color: Colors.white54)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passportNumberController,
            enabled: !_redirecting,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: "Pasaport / Belge No", labelStyle: TextStyle(color: Colors.white54)),
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
