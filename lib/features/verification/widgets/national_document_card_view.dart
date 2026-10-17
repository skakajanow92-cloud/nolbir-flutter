import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/media/media_pick_result.dart';
import '../../../core/media/media_providers.dart';
import '../../../data/repositories/verification_repository.dart';
import '../../../models/form_card/verification_level.dart';
import '../application/verification_providers.dart';
import 'verification_status_banners.dart';

/// B1 doğrulama: kimlik/yerli evrak — ön yüz (zorunlu) + arka yüz
/// (opsiyonel) belge fotoğrafı yükleyip admin incelemesine gönderir.
///
/// GÜNCELLEME: Artık bir belge NUMARASI değil, gerçek bir belge GÖRSELİ
/// isteniyor (`VerificationRepository.submitNationalDocument` imzası
/// `frontImageUrl`/`backImageUrl` alıyor) — seçme/kaydetme/yükleme işi
/// `core/media/` altındaki merkezi `MediaService`'e devredildi, bu kart
/// kendi image_picker/file_picker kodunu yazmıyor (bkz. `MediaPicker`'ın
/// dosya başı doc comment'i — TEK merkezi seçme noktası ilkesi).
/// Gönderim artık ANINDA onaylanmıyor — admin incelemesi bekleyen
/// `pending` durumuna düşüyor (bkz. `StepStatus`).
class NationalDocumentCardView extends ConsumerStatefulWidget {
  const NationalDocumentCardView({super.key});

  @override
  ConsumerState<NationalDocumentCardView> createState() =>
      _NationalDocumentCardViewState();
}

class _NationalDocumentCardViewState
    extends ConsumerState<NationalDocumentCardView> {
  static const accent = Color(0xFF1F7A8C);

  MediaPickResult? _front;
  MediaPickResult? _back;
  bool _isSubmitting = false;
  String? _error;

  Future<void> _pick({required bool front}) async {
    final media = await ref.read(mediaServiceProvider).pickAnyFileAndPersist();
    if (media == null || !mounted) return;
    setState(() {
      if (front) {
        _front = media;
      } else {
        _back = media;
      }
    });
  }

  Future<void> _submit() async {
    if (_front == null) {
      setState(() => _error = "Belgenin ön yüzü zorunlu");
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final mediaService = ref.read(mediaServiceProvider);
      final frontUrl = await mediaService.upload(_front!);
      final backUrl = _back != null ? await mediaService.upload(_back!) : null;
      await ref
          .read(verificationStatusProvider.notifier)
          .submitNationalDocument(
            frontImageUrl: frontUrl,
            backImageUrl: backUrl,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Belge gönderildi — admin incelemesi bekleniyor (B1)"),
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
          VerificationLevel.nationalDocumentVerified,
        );
        if (stepStatus == StepStatus.pending) {
          return const PendingNotice(
            title: "Yerli Evrak İnceleniyor (B1)",
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
              const Icon(Icons.badge_outlined, color: accent, size: 40),
              const SizedBox(height: 12),
              const Text(
                "Kimlik Doğrulama (B1)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "T.C. kimlik no ya da ülke içinde geçerli bir yerli evrakın "
                "fotoğrafını yükle — admin incelemesinden geçirilecek.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              if (stepStatus == StepStatus.rejected &&
                  status.rejectionReason != null) ...[
                const SizedBox(height: 14),
                _RejectionBanner(reason: status.rejectionReason!),
              ],
              const SizedBox(height: 20),
              _DocumentTile(
                label: "Ön Yüz *",
                media: _front,
                onPick: () => _pick(front: true),
                onRemove: () => setState(() => _front = null),
              ),
              const SizedBox(height: 10),
              _DocumentTile(
                label: "Arka Yüz (opsiyonel)",
                media: _back,
                onPick: () => _pick(front: false),
                onRemove: () => setState(() => _back = null),
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
  final String label;
  final MediaPickResult? media;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _DocumentTile({
    required this.label,
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
                Text(
                  label,
                  style: const TextStyle(
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

/// `national_document_card_view.dart`/`international_document_card_view.dart`/
/// `full_access_request_card_view.dart` ARASINDA paylaşılan "admin
/// inceliyor" ekranı — kopya kod olmasın diye burada, gerekirse `core/
/// widgets/`e taşınabilir.
// ignore: unused_element
class _PendingNotice extends StatelessWidget {
  final String title;
  final String message;
  const _PendingNotice({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_top_outlined,
              color: Colors.white38,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectionBanner extends StatelessWidget {
  final String reason;
  const _RejectionBanner({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Önceki başvuru reddedildi: $reason",
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
