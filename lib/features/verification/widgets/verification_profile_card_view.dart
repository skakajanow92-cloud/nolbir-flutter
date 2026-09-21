import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nolbir/models/feed_card/verification_profile_card.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/verification.dart';
import '../../../models/form_card/form_card.dart';
import '../../../core/forms/form_view_registry.dart';
import '../../../core/widgets/page_aware_scroll_view.dart';
import '../application/verification_providers.dart';

/// Doğrulama Merkezi — hem PROFİL kartı sistemine (durumu gösterir) hem
/// de FORM sistemine (Navigator.push + FormViewRegistry ile ilgili
/// formu açar) bağlanan tek modül. Bu ikisinin kesiştiği yer.
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
    final level = ref.watch(userVerificationProvider);
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
          child: PageAwareScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(level: level),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _CapabilityChecklist(level: level),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Doğrulama Basamakları",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: VerifiedType.values
                        .where((v) => v != VerifiedType.none)
                        .map((v) => _LevelRow(level: v, currentLevel: level))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VerifiedType level;
  const _Header({required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.verified_user_outlined,
                color: VerificationProfileCardView.moduleAccent, size: 20),
            SizedBox(width: 8),
            Text("Doğrulama Merkezi", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(level.label,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.1)),
        const SizedBox(height: 6),
        Text(level.description,
            style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
      ],
    );
  }
}

class _CapabilityChecklist extends StatelessWidget {
  final VerifiedType level;
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
        final color = unlocked ? VerificationProfileCardView.moduleAccent : Colors.white24;
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
              Icon(unlocked ? Icons.check_circle : Icons.lock_outline,
                  size: 13, color: unlocked ? VerificationProfileCardView.moduleAccent : Colors.white38),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(color: unlocked ? Colors.white : Colors.white38, fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final VerifiedType level;
  final VerifiedType currentLevel;
  const _LevelRow({required this.level, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    final isDone = currentLevel.index >= level.index;
    final isNext = !isDone && currentLevel.nextLevel == level;
    final isLocked = !isDone && !isNext;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDone
                ? VerificationProfileCardView.moduleAccent.withValues(alpha: 0.5)
                : Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle
                : (isLocked ? Icons.lock_outline : Icons.radio_button_unchecked),
            color: isDone ? VerificationProfileCardView.moduleAccent : Colors.white38,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.label,
                    style: TextStyle(
                        color: isLocked ? Colors.white38 : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(level.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: isLocked ? Colors.white24 : Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          if (isNext)
            TextButton(
              onPressed: () => _startVerification(context, level),
              child: const Text("Devam Et"),
            ),
        ],
      ),
    );
  }

  void _startVerification(BuildContext context, VerifiedType target) {
    final FormCard form = switch (target.method) {
      VerificationMethod.emailCode => const EmailVerificationFormCard(id: "verify_email"),
      VerificationMethod.phoneCode => const PhoneVerificationFormCard(id: "verify_phone"),
      VerificationMethod.nationalDocument =>
        const NationalDocumentFormCard(id: "verify_b1"),
      VerificationMethod.internationalDocument =>
        const InternationalDocumentFormCard(id: "verify_b2"),
      VerificationMethod.branchOrLiveCall =>
        const FullAccessRequestFormCard(id: "verify_c1"),
      VerificationMethod.none => throw StateError("Bu seviye için form yok"),
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, title: Text(target.label)),
          body: FormViewRegistry.build(routeContext, form),
        ),
      ),
    );
  }
}
