import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/verification_providers.dart';

enum _C1Path { branch, liveCall }

/// C1 doğrulama: şubeye başvuru YA DA admin ile canlı görüşme talebi.
///
/// NOT: Gerçek admin onay akışı YOK — normalde bu talep "beklemede"
/// durumuna düşüp bir admin tarafından onaylanana kadar seviye atlanmaz.
/// Demo modunda talebi göndermek doğrudan C1'e geçiriyor; backend
/// bağlanınca burada bir "pending" ara durumu eklenecek.
class FullAccessRequestCardView extends ConsumerStatefulWidget {
  const FullAccessRequestCardView({super.key});

  @override
  ConsumerState<FullAccessRequestCardView> createState() =>
      _FullAccessRequestCardViewState();
}

class _FullAccessRequestCardViewState extends ConsumerState<FullAccessRequestCardView> {
  static const accent = Color(0xFF1F7A8C);
  _C1Path _path = _C1Path.branch;
  final _branchController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _branchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_branchController.text.trim().isEmpty || _dateController.text.trim().isEmpty) return;
    ref.read(userVerificationProvider.notifier).submitFullAccessRequest();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Talep alındı — tam yetki tanındı (C1)")));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.workspace_premium_outlined, color: accent, size: 40),
          const SizedBox(height: 12),
          const Text("Tam Yetki Başvurusu (C1)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          SegmentedButton<_C1Path>(
            segments: const [
              ButtonSegment(value: _C1Path.branch, label: Text("Şubeye Başvuru")),
              ButtonSegment(value: _C1Path.liveCall, label: Text("Canlı Görüşme")),
            ],
            selected: {_path},
            onSelectionChanged: (s) => setState(() => _path = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _branchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: _path == _C1Path.branch ? "Tercih Edilen Şube" : "Görüşme Talebi Notu",
              labelStyle: const TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dateController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: "Tercih Edilen Tarih/Saat",
                labelStyle: TextStyle(color: Colors.white54)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: _submit,
            child: const Text("Talebi Gönder"),
          ),
        ],
      ),
    );
  }
}
