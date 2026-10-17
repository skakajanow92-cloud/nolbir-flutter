import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/verification_repository.dart';
import '../../../models/form_card/verification_level.dart';
import '../application/verification_providers.dart';
import 'verification_status_banners.dart';

enum _C1Path { branch, liveCall }

/// C1 doğrulama: şubeye başvuru YA DA admin ile canlı görüşme talebi.
///
/// GÜNCELLEME: Gönderim artık `VerificationRepository.submitFullAccessRequest`
/// üzerinden gerçek (asenkron) bir admin incelemesine düşüyor — eskisi gibi
/// doğrudan C1'e geçmiyor. `_path` seçimi `FullAccessRequestType`'a eşlenir.
class FullAccessRequestCardView extends ConsumerStatefulWidget {
  const FullAccessRequestCardView({super.key});

  @override
  ConsumerState<FullAccessRequestCardView> createState() =>
      _FullAccessRequestCardViewState();
}

class _FullAccessRequestCardViewState extends ConsumerState<FullAccessRequestCardView> {
  static const accent = Color(0xFF1F7A8C);
  _C1Path _path = _C1Path.branch;
  bool _isSubmitting = false;
  String? _error;
  final _branchController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _branchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_branchController.text.trim().isEmpty || _dateController.text.trim().isEmpty) {
      setState(() => _error = "Her iki alan da zorunlu");
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final note = _path == _C1Path.branch
          ? "Tercih edilen şube: ${_branchController.text.trim()} · "
              "Tarih/Saat: ${_dateController.text.trim()}"
          : "Görüşme notu: ${_branchController.text.trim()} · "
              "Tercih edilen Tarih/Saat: ${_dateController.text.trim()}";
      await ref.read(verificationStatusProvider.notifier).submitFullAccessRequest(
            type: _path == _C1Path.branch
                ? FullAccessRequestType.branchVisit
                : FullAccessRequestType.liveInterview,
            note: note,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Talebin alındı — admin incelemesi bekleniyor (C1)")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(verificationStatusProvider);

    return statusAsync.when(
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: accent))),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text("Durum alınamadı: $e", style: const TextStyle(color: Colors.redAccent)),
      ),
      data: (status) {
        final stepStatus = status.statusFor(VerificationLevel.fullAccess);
        if (stepStatus == StepStatus.pending) {
          return const PendingNotice(
            title: "Tam Yetki Başvurusu İnceleniyor (C1)",
            message: "Talebin admin tarafından inceleniyor. Onaylanınca sınırsız "
                "imkanların tamamı açılacak.",
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.workspace_premium_outlined, color: accent, size: 40),
              const SizedBox(height: 12),
              const Text("Tam Yetki Başvurusu (C1)",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              if (stepStatus == StepStatus.rejected && status.rejectionReason != null) ...[
                const SizedBox(height: 14),
                RejectionBanner(reason: status.rejectionReason!),
              ],
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
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Talebi Gönder"),
              ),
            ],
          ),
        );
      },
    );
  }
}
