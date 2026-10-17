import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/verification_providers.dart';

/// A2 doğrulama: telefon + SMS kod onayı (bkz. EmailVerificationCardView
/// ile aynı asenkron gönder/onayla deseni).
class PhoneVerificationCardView extends ConsumerStatefulWidget {
  const PhoneVerificationCardView({super.key});

  @override
  ConsumerState<PhoneVerificationCardView> createState() =>
      _PhoneVerificationCardViewState();
}

class _PhoneVerificationCardViewState
    extends ConsumerState<PhoneVerificationCardView> {
  static const accent = Color(0xFF1F7A8C);

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = "Telefon numarası zorunlu");
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref
          .read(verificationStatusProvider.notifier)
          .sendPhoneCode(phone);
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
      await ref
          .read(verificationStatusProvider.notifier)
          .confirmPhoneCode(
            phoneNumber: _phoneController.text.trim(),
            code: _codeController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Telefon doğrulandı (A2)")));
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
          const Icon(Icons.sms_outlined, color: accent, size: 40),
          const SizedBox(height: 12),
          const Text(
            "Telefon Doğrulama",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            enabled: !_codeSent,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Telefon Numarası",
              labelStyle: TextStyle(color: Colors.white54),
            ),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Kod Gönder"),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              "Kod SMS ile gönderildi.",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Doğrulama Kodu",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: _isSubmitting ? null : _verify,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Doğrula"),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
