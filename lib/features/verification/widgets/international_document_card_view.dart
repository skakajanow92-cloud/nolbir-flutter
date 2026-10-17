import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/media/media_pick_result.dart';
import '../../../core/media/media_providers.dart';
import '../../../data/repositories/verification_repository.dart';
import '../../../models/form_card/verification_level.dart';
import '../application/verification_providers.dart';
import 'verification_status_banners.dart';

/// B2 doğrulama: pasaport/uluslararası belge — tek bir belge fotoğrafı
/// yükleyip admin incelemesine gönderir (bkz. `NationalDocumentCardView`
/// ile AYNI yükleme/gönderim deseni — fark sadece tek görsel olması).
class InternationalDocumentCardView extends ConsumerStatefulWidget {
  const InternationalDocumentCardView({super.key});

  @override
  ConsumerState<InternationalDocumentCardView> createState() =>
      _InternationalDocumentCardViewState();
}

class _InternationalDocumentCardViewState
    extends ConsumerState<InternationalDocumentCardView> {
  static const accent = Color(0xFF1F7A8C);

  MediaPickResult? _passport;
  bool _isSubmitting = false;
  String? _error;

  Future<void> _pick() async {
    final media = await ref.read(mediaServiceProvider).pickAnyFileAndPersist();
    if (media == null || !mounted) return;
    setState(() => _passport = media);
  }

  Future<void> _submit() async {
    if (_passport == null) {
      setState(() => _error = "Pasaport/belge fotoğrafı zorunlu");
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final mediaService = ref.read(mediaServiceProvider);
      final passportUrl = await mediaService.upload(_passport!);
      await ref
          .read(verificationStatusProvider.notifier)
          .submitInternationalDocument(passportImageUrl: passportUrl);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Belge gönderildi — admin incelemesi bekleniyor (B2)"),
        ),
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
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: accent),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Durum alınamadı: $e",
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
      data: (status) {
        final stepStatus = status.statusFor(
          VerificationLevel.internationalDocumentVerified,
        );
        if (stepStatus == StepStatus.pending) {
          return const PendingNotice(
            title: "Uluslararası Belge İnceleniyor (B2)",
            message:
                "Belgen admin tarafından inceleniyor. Onaylanınca bu seviyenin "
                "izinleri otomatik açılacak.",
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.public_outlined, color: accent, size: 40),
              const SizedBox(height: 12),
              const Text(
                "Uluslararası Doğrulama (B2)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pasaport ya da geçerli uluslararası bir belgenin fotoğrafını "
                "yükle — admin incelemesinden geçirilecek.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              if (stepStatus == StepStatus.rejected &&
                  status.rejectionReason != null) ...[
                const SizedBox(height: 14),
                RejectionBanner(reason: status.rejectionReason!),
              ],
              const SizedBox(height: 20),
              _DocumentTile(
                media: _passport,
                onPick: _pick,
                onRemove: () => setState(() => _passport = null),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("İncelemeye Gönder"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final MediaPickResult? media;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _DocumentTile({
    required this.media,
    required this.onPick,
    required this.onRemove,
  });

  static const _accent = Color(0xFF1F7A8C);

  @override
  Widget build(BuildContext context) {
    final uploaded = media != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (uploaded ? _accent : Colors.white).withValues(
          alpha: uploaded ? 0.14 : 0.04,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: uploaded ? _accent.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          if (uploaded && media!.kind == MediaKind.image)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                media!.bytes,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                uploaded
                    ? Icons.description_outlined
                    : Icons.upload_file_outlined,
                color: uploaded ? Colors.white54 : Colors.white24,
                size: 20,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pasaport / Belge *",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  uploaded ? media!.fileName : "Dosya seçilmedi",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: uploaded ? Colors.white70 : Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              uploaded ? Icons.close : Icons.add_photo_alternate_outlined,
              color: uploaded ? Colors.white54 : _accent,
            ),
            onPressed: uploaded ? onRemove : onPick,
          ),
        ],
      ),
    );
  }
}
