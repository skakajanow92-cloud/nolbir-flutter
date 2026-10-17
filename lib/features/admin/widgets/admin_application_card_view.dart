import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/forms/form_view_registry.dart';
import '../../../core/widgets/page_aware_scroll_view.dart';
import '../../../models/admin_application.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/form_card/form_card.dart';
import '../application/admin_providers.dart';

/// Admin Başvurusu giriş kartı — profil akışında görünür. Başvuru
/// başlamadan ÖNCE neyin hazırlanması gerektiğini gösteriyor (kullanıcı
/// formu açıp yarıda kalmasın diye), başladıktan sonra ilerlemeyi.
class AdminApplicationCardView extends ConsumerWidget {
  final AdminApplicationCard card;

  const AdminApplicationCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF6F8296);
  static const _base = Color(0xFF0F1114);
  static const _baseEnd = Color(0xFF171B20);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(adminApplicationDraftProvider);
    final status = draft.status;
    final size = MediaQuery.of(context).size;
    final started = draft.completedDocumentSlotCount > 0 ||
        draft.fullName.isNotEmpty ||
        draft.role != null;
    final canEdit = status == AdminApplicationStatus.draft ||
        status == AdminApplicationStatus.rejected;

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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.admin_panel_settings_outlined,
                        color: moduleAccent, size: 20),
                    SizedBox(width: 8),
                    Text("Admin Başvurusu",
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  status.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700),
                ),
                if (draft.role != null) ...[
                  const SizedBox(height: 4),
                  Text(draft.role!.label,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
                const SizedBox(height: 8),
                Text(_blurb(status, draft),
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
                if (status == AdminApplicationStatus.draft && started) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: draft.completedDocumentSlotCount /
                          draft.requiredDocumentSlotCount,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor:
                          const AlwaysStoppedAnimation(moduleAccent),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Zorunlu belgeler: ${draft.completedDocumentSlotCount}/${draft.requiredDocumentSlotCount}",
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
                if (status == AdminApplicationStatus.draft) ...[
                  const SizedBox(height: 24),
                  const Text("Başvuru için hazırlaman gerekenler",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  const _Need("Kimlik veya pasaport"),
                  const _Need("Vesikalık fotoğraf"),
                  const _Need("İkametgâh belgesi"),
                  const _Need("Özgeçmiş (CV)"),
                  const _Need("Diploma / mezuniyet belgesi"),
                  const _Need("Adli sicil kaydı (son 3 ay)"),
                  const SizedBox(height: 8),
                  const Text(
                    "Yabancı uyruklular için çalışma izni, finans pozisyonu için "
                    "mesleki yeterlilik belgesi de gerekir.",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 24),
                if (canEdit)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: moduleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _openWizard(context),
                      child: Text(
                        status == AdminApplicationStatus.rejected
                            ? "Başvuruyu Yeniden Gönder"
                            : (started ? "Başvuruya Devam Et" : "Başvuruyu Başlat"),
                      ),
                    ),
                  )
                else if (status == AdminApplicationStatus.approved)
                  const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.greenAccent, size: 18),
                      SizedBox(width: 6),
                      Text("Admin başvurun onaylandı",
                          style: TextStyle(
                              color: Colors.greenAccent, fontSize: 13)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _blurb(AdminApplicationStatus status, AdminApplication draft) {
    return switch (status) {
      AdminApplicationStatus.draft =>
        "Maaşlı admin kadrosuna başvur. Belgelerini yükle, sonuç sana bildirilir.",
      AdminApplicationStatus.submitted =>
        "Başvurun alındı, incelenmeyi bekliyor.",
      AdminApplicationStatus.underReview =>
        "Belgelerin İK ekibi tarafından inceleniyor.",
      AdminApplicationStatus.interview =>
        "Mülakat için seninle iletişime geçilecek.",
      AdminApplicationStatus.approved => "Başvurun onaylandı.",
      AdminApplicationStatus.rejected =>
        "Başvurun reddedildi. Eksikleri giderip yeniden gönderebilirsin.",
    };
  }

  void _openWizard(BuildContext context) {
    const form = AdminApplicationFormCard(id: "admin_application");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => FormViewRegistry.build(routeContext, form),
      ),
    );
  }
}

class _Need extends StatelessWidget {
  final String text;
  const _Need(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 15, color: AdminApplicationCardView.moduleAccent),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
