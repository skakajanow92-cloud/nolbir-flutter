import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/verification_providers.dart';

/// A1 doğrulama: e-posta + kod onayı.
///
/// NOT: Gerçek e-posta gönderimi YOK — demo kodu ekranda gösteriliyor ki
/// akış test edilebilsin. Backend bağlanınca "Kod Gönder" gerçek bir
/// e-posta API çağrısına dönüşecek, kod ekranda gösterilmeyecek.
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
  String? _sentCode;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _error = "E-posta zorunlu");
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
    ref.read(userVerificationProvider.notifier).submitEmailCode(_codeController.text.trim());
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("E-posta doğrulandı (A1)")));
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
            enabled: _sentCode == null,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: "E-posta", labelStyle: TextStyle(color: Colors.white54)),
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
            Text("Demo kodu: $_sentCode (gerçek e-postana gönderilecek)",
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
