import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nolbir/features/auth/application/auth_providers.dart';
import 'package:nolbir/features/auth/widgets/login_register_card_view.dart';
import '../../core/widgets/vertical_card_feed.dart';
import '../../app/card_factory.dart';
import 'application/profile_providers.dart';

/// NOT: FAB kaldırıldı — proje tasarımında yeri yoktu. "Gönderi ekle"
/// menüsünün kendisi (`CreatePostSheet`) silinmedi, `widgets/
/// create_post_sheet.dart` içindeki paylaşılan `showCreatePostSheet(context)`
/// fonksiyonuna taşındı — ileride bir kart/buton bu akışı tetiklemek
/// isterse sadece o fonksiyonu çağırır, burada tekrar kurmaz.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(profileFeedProvider);
    final isUser = ref.watch(isUserProvider);
    if (!isUser) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: LoginRegisterCardView(),
      );
    }
    return feedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(profileFeedProvider),
          child: const Text(
            "Profil yüklenemedi, tekrar dene",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
      data: (cards) =>
          VerticalCardFeed(cards: cards, cardBuilder: buildFeedCard),
    );
  }
}
