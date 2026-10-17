import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nolbir/models/feed_card/verification_profile_card.dart';
import '../../../data/repositories/verification_repository.dart';
import '../../../models/form_card/form_card.dart';
import '../../../core/forms/form_view_registry.dart';
import '../../../core/widgets/page_aware_scroll_view.dart';
import '../application/verification_providers.dart';

/// Doğrulama Merkezi — hem PROFİL kartı sistemine (durumu gösterir) hem
/// de FORM sistemine (Navigator.push + FormViewRegistry ile ilgili
/// formu açar) bağlanan tek modül. Bu ikisinin kesiştiği yer.
///
/// GÜNCELLEME (eski `VerifiedType`/`userVerificationProvider` sisteminin
/// yerine geçti): doğrulama durumu artık `verificationStatusNotifierProvider`
/// üzerinden ASENKRON okunuyor ve her adımın durumu `VerificationStatus.
/// statusFor()` ile `StepStatus` (locked/available/pending/approved/
/// rejected) olarak hesaplanıyor — B1/B2/C1 admin onayı bekleyebilir,
/// bu yüzden "sıradaki adım" artık her zaman hemen başlatılabilir değil.
///
/// Modül vurgu rengi: petrol camgöbeği — "güven/doğrulama" hissi, diğer
/// profil modüllerinin renk setinden ayrı, çünkü bu bir içerik modülü
/// değil, işlevsel bir akış.
class VerificationProfileCardView extends ConsumerWidget {
  final VerificationProfileCard card;
  const VerificationProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF1F7A8C);
  static const _base = Color(0xFF0B1213);
  static const _baseEnd = Color(0xFF121B1C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(verificationStatusProvider);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: SafeArea(
          child: statusAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: moduleAccent),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Doğrulama durumu alınamadı: $e",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: moduleAccent,
                      ),
                      onPressed: () => ref
                          .read(verificationStatusProvider.notifier)
                          .refresh(),
                      child: const Text("Tekrar Dene"),
                    ),
                  ],
                ),
              ),
            ),
            data: (status) => PageAwareScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _Header(level: status.approvedLevel),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _CapabilityChecklist(level: status.approvedLevel),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Doğrulama Basamakları",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: VerificationStatus.steps
                          .map(
                            (level) => _LevelRow(level: level, status: status),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VerificationLevel level;
  const _Header({required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: VerificationProfileCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Doğrulama Merkezi",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          level.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          level.description,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _CapabilityChecklist extends StatelessWidget {
  final VerificationLevel level;
  const _CapabilityChecklist({required this.level});

  @override
  Widget build(BuildContext context) {
    final items = <(String, bool)>[
      ("Beğeni ve yorum", level.canLikeAndComment),
      ("İçerik paylaşma", level.canPostContent),
      ("Cüzdan ve transfer", level.canOpenWalletAndTransfer),
      ("Çoklu döviz/borsa", level.canMultiCurrencyAndInvest),
      ("Tam yetki", level.hasFullAccess),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((i) {
        final (label, unlocked) = i;
        final color = unlocked
            ? VerificationProfileCardView.moduleAccent
            : Colors.white24;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: unlocked ? 0.2 : 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                unlocked ? Icons.check_circle : Icons.lock_outline,
                size: 13,
                color: unlocked
                    ? VerificationProfileCardView.moduleAccent
                    : Colors.white38,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: unlocked ? Colors.white : Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final VerificationLevel level;
  final VerificationStatus status;
  const _LevelRow({required this.level, required this.status});

  @override
  Widget build(BuildContext context) {
    final stepStatus = status.statusFor(level);
    final isDone = stepStatus == StepStatus.approved;
    final isPending = stepStatus == StepStatus.pending;
    final isRejected = stepStatus == StepStatus.rejected;
    final isActionable = stepStatus == StepStatus.available || isRejected;
    final isLocked = stepStatus == StepStatus.locked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? VerificationProfileCardView.moduleAccent.withValues(alpha: 0.5)
              : isRejected
              ? Colors.redAccent.withValues(alpha: 0.4)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle
                : isPending
                ? Icons.hourglass_top_outlined
                : isRejected
                ? Icons.error_outline
                : (isLocked
                      ? Icons.lock_outline
                      : Icons.radio_button_unchecked),
            color: isDone
                ? VerificationProfileCardView.moduleAccent
                : isPending
                ? Colors.white38
                : isRejected
                ? Colors.redAccent
                : Colors.white38,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.label,
                  style: TextStyle(
                    color: isLocked ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPending
                      ? "Admin incelemesi bekleniyor"
                      : isRejected
                      ? "Reddedildi — tekrar deneyebilirsin"
                      : level.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLocked
                        ? Colors.white24
                        : isRejected
                        ? Colors.redAccent
                        : Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isActionable)
            TextButton(
              onPressed: () => _startVerification(context, level),
              child: Text(isRejected ? "Yeniden Dene" : "Devam Et"),
            ),
        ],
      ),
    );
  }

  void _startVerification(BuildContext context, VerificationLevel target) {
    final FormCard form = switch (target) {
      VerificationLevel.emailVerified => const EmailVerificationFormCard(
        id: "verify_email",
      ),
      VerificationLevel.phoneVerified => const PhoneVerificationFormCard(
        id: "verify_phone",
      ),
      VerificationLevel.nationalDocumentVerified =>
        const NationalDocumentFormCard(id: "verify_b1"),
      VerificationLevel.internationalDocumentVerified =>
        const InternationalDocumentFormCard(id: "verify_b2"),
      VerificationLevel.fullAccess => const FullAccessRequestFormCard(
        id: "verify_c1",
      ),
      VerificationLevel.none => throw StateError("Bu seviye için form yok"),
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(target.label),
          ),
          body: FormViewRegistry.build(routeContext, form),
        ),
      ),
    );
  }
}
