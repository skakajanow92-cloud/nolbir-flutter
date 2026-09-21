import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/verification_providers.dart';

/// A2 doğrulama: telefon + SMS kod onayı (bkz. EmailVerificationCardView
/// ile aynı demo-kod yaklaşımı).
class PhoneVerificationCardView extends ConsumerStatefulWidget {
  const PhoneVerificationCardView({super.key});

  @override
  ConsumerState<PhoneVerificationCardView> createState() =>
      _PhoneVerificationCardViewState();
}

class _PhoneVerificationCardViewState extends ConsumerState<PhoneVerificationCardView> {
  static const accent = Color(0xFF1F7A8C);

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _sentCode;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _error = "Telefon numarası zorunlu");
      return;
    }
    final code = (100000 + Random().nextInt(900000)).toString();
    setState(() {
      _sentCode = code;
      _error = null;
    });
  }

  void _verify() {
    if (_codeController.text.trim() != _sentCode) {
      setState(() => _error = "Kod hatalı");
      return;
    }
    ref.read(userVerificationProvider.notifier).submitPhoneCode(_codeController.text.trim());
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Telefon doğrulandı (A2)")));
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
          const Text("Telefon Doğrulama",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            enabled: _sentCode == null,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: "Telefon Numarası", labelStyle: TextStyle(color: Colors.white54)),
          ),
          if (_sentCode == null) ...[
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: _sendCode,
              child: const Text("Kod Gönder"),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text("Demo kodu: $_sentCode (gerçek SMS ile gönderilecek)",
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: "Doğrulama Kodu", labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: _verify,
              child: const Text("Doğrula"),
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
