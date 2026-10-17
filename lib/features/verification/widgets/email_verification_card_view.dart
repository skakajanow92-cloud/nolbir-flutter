import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/verification_providers.dart';

/// A1 doğrulama: e-posta + kod onayı.
///
/// GÜNCELLEME: Kod gönderimi/onayı artık `VerificationRepository` üzerinden
/// gerçek (asenkron) çağrılar — demo kodu ekranda GÖSTERİLMİYOR, gerçek bir
/// e-posta/SMS sağlayıcısı bağlanana kadar kullanıcı gelen kutusunu kontrol
/// etmesi gerektiğini varsayarak ilerliyor. Her iki adım da kendi
/// yükleniyor/hata durumunu taşıyor (bkz. `LoginRegisterCardView` ile aynı
/// desen) — e-posta/telefon onayı admin incelemesine DÜŞMEZ, anında
/// onaylanır (bkz. `StepStatus` doc comment).
class EmailVerificationCardView extends ConsumerStatefulWidget {
  const EmailVerificationCardView({super.key});

  @override
  ConsumerState<EmailVerificationCardView> createState() =>
      _EmailVerificationCardViewState();
}

class _EmailVerificationCardViewState extends ConsumerState<EmailVerificationCardView> {
  static const accent = Color(0xFF1F7A8C);

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = "E-posta zorunlu");
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(verificationStatusProvider.notifier).sendEmailCode(email);
      if (!mounted) return;
      setState(() => _codeSent = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(verificationStatusProvider.notifier).confirmEmailCode(
            email: _emailController.text.trim(),
            code: _codeController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("E-posta doğrulandı (A1)")));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.mark_email_read_outlined, color: accent, size: 40),
          const SizedBox(height: 12),
          const Text("E-posta Doğrulama",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            enabled: !_codeSent,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: "E-posta", labelStyle: TextStyle(color: Colors.white54)),
          ),
          if (!_codeSent) ...[
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: _isSubmitting ? null : _sendCode,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Kod Gönder"),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text("Kod e-postana gönderildi.",
                style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: "Doğrulama Kodu", labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: _isSubmitting ? null : _verify,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Doğrula"),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
