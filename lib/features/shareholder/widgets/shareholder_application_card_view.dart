import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/feed_card/shareholder_application_card.dart';
import '../../../models/shareholder_application.dart';
import '../../../models/form_card/shareholder_application_form_card.dart';
import '../../../core/forms/form_view_registry.dart';
import '../application/shareholder_providers.dart';

/// Ortaklık Başvurusu giriş kartı.
/// Modül vurgu rengi: sıcak bronz — "kurumsal/holding" hissi, diğer
/// modüllerin renklerinden ayrışan sıcak-nötr bir ton.
class ShareholderApplicationCardView extends ConsumerWidget {
  final ShareholderApplicationCard card;
  const ShareholderApplicationCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF8A5A2E);
  static const _base = Color(0xFF120E09);
  static const _baseEnd = Color(0xFF1A140D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(shareholderApplicationDraftProvider);
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.handshake_outlined, color: moduleAccent, size: 20),
                    SizedBox(width: 8),
                    Text("Holding Ortaklığı",
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(draft.status.label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  draft.status == ShareholderApplicationStatus.approved
                      ? "Tebrikler, artık bir ortaksın."
                      : draft.status == ShareholderApplicationStatus.draft
                          ? "Holdingimize ortak olmak için başvuru sürecini başlat."
                          : "Başvurun ${_formatDate(draft.submittedAt)} tarihinde gönderildi.",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const Spacer(),
                if (draft.status != ShareholderApplicationStatus.approved)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: moduleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _openWizard(context),
                      child: Text(
                        draft.status == ShareholderApplicationStatus.rejected
                            ? "Başvuruyu Yeniden Gönder"
                            : draft.status == ShareholderApplicationStatus.draft
                                ? "Başvuruyu Başlat"
                                : "Başvuruyu Düzenle",
                      ),
                    ),
                  )
                else
                  const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.greenAccent, size: 18),
                      SizedBox(width: 6),
                      Text("Ortak",
                          style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                    ],
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openWizard(BuildContext context) {
    const form = ShareholderApplicationFormCard(id: "shareholder_application");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => FormViewRegistry.build(routeContext, form),
      ),
    );
  }
}

String _formatDate(DateTime? d) {
  if (d == null) return "";
  return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
}
