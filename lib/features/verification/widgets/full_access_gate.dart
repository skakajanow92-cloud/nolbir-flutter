import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/feed_card/verification_profile_card.dart';
import '../../../models/form_card/verification_level.dart';
import '../application/verification_providers.dart';
import 'verification_profile_card_view.dart';

/// C1 (Tam Yetki) seviyesi gerektiren TÜM modüller için ortak kapı.
///
/// BİLİNÇLİ TASARIM KARARI: Ortaklık başvurusu (`ShareholderApplication`)
/// ile ileride eklenecek ajanta/şube açma gibi "tam yetki" gerektiren
/// modüllerin HER BİRİ kendi kilit ekranını tekrar yazmak yerine bu tek
/// widget'ı sarmalayıcı (wrapper) olarak kullanır — `MediaPicker`/
/// `ApiClient` ile aynı merkezileştirme ilkesi. `core/widgets/` yerine
/// bilerek `features/verification/widgets/` altında tutuluyor çünkü
/// doğrudan `verificationStatusNotifierProvider`'a bağımlı — core katmanı
/// feature'lara bağımlı olmamalı.
///
/// GÜNCELLEME: Doğrulama durumu artık ASENKRON (`VerificationRepository`
/// üzerinden admin onayına bağlı) — bu yüzden `userVerificationProvider`/
/// `VerifiedType` yerine `verificationStatusNotifierProvider`
/// (`AsyncValue<VerificationStatus>`) izleniyor. `approvedLevel.hasFullAccess`
/// false iken [child] HİÇ build edilmez; kullanıcı kilit ekranından
/// doğrudan Doğrulama Merkezi'ne yönlendirilir. Durum yüklenirken/hata
/// alırken de [child] gösterilmez — C1 gerektiren bir modülün durumu
/// belirsizken açık kalması güvenlik açısından YANLIŞ olur, bu yüzden
/// loading/error durumlarında da kilitli view (belirsiz seviye ile)
/// gösterilir.
class FullAccessGate extends ConsumerWidget {
  final Widget child;
  final String featureTitle;
  final String featureDescription;
  final IconData icon;

  const FullAccessGate({
    super.key,
    required this.child,
    required this.featureTitle,
    required this.featureDescription,
    this.icon = Icons.lock_outline,
  });

  /// Doğrulama Merkezi ile AYNI vurgu rengi — bu kilidin o modülün bir
  /// uzantısı olduğu görsel olarak da hissettirilsin diye.
  static const accent = Color(0xFF1F7A8C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(verificationStatusProvider);

    return statusAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: accent),
        ),
      ),
      error: (e, _) => _LockedView(
        currentLevel: null,
        icon: icon,
        featureTitle: featureTitle,
        featureDescription: featureDescription,
      ),
      data: (status) {
        if (status.approvedLevel.hasFullAccess) return child;
        return _LockedView(
          currentLevel: status.approvedLevel,
          icon: icon,
          featureTitle: featureTitle,
          featureDescription: featureDescription,
        );
      },
    );
  }
}

class _LockedView extends StatelessWidget {
  /// `null` -> durum yüklenemedi (hata), seviye bilinmiyor.
  final VerificationLevel? currentLevel;
  final IconData icon;
  final String featureTitle;
  final String featureDescription;

  const _LockedView({
    required this.currentLevel,
    required this.icon,
    required this.featureTitle,
    required this.featureDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: FullAccessGate.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: FullAccessGate.accent, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              featureTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              featureDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                currentLevel != null
                    ? "Mevcut seviyen: ${currentLevel!.label}"
                    : "Doğrulama durumun şu an alınamadı",
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: FullAccessGate.accent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () => _goToVerificationCenter(context),
              icon: const Icon(Icons.verified_user_outlined, size: 18),
              label: const Text("Doğrulama Merkezine Git"),
            ),
          ],
        ),
      ),
    );
  }

  // DİKKAT: `VerificationProfileCardView` kendi `SizedBox(width: size.width,
  // height: size.height, ...)` ile TÜM ekran boyutunu kaplayacak şekilde
  // tasarlandı (normalde kart akışında AppBar'sız full-bleed gösteriliyor).
  // Bu yüzden burada bir `Scaffold`/`AppBar` İÇİNE koymuyoruz — `body`
  // alanı AppBar kadar küçülür ve taşma (overflow) oluşur. Onun yerine
  // geri butonunu bir `Stack` ile ÜSTÜNE biniyoruz, full-bleed boyutlandırma
  // bozulmadan geri navigasyonu (Android/iOS varsayılan geri hareketine ek
  // olarak görünür bir ok) garanti altına alınmış oluyor.
  void _goToVerificationCenter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => Stack(
          children: [
            const VerificationProfileCardView(
              card: VerificationProfileCard(id: "verification_center"),
            ),
            Positioned(
              top: MediaQuery.of(routeContext).padding.top + 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(routeContext).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
