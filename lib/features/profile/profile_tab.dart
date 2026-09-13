import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/vertical_card_feed.dart';
import '../../app/card_factory.dart';
import 'application/profile_providers.dart';
import 'widgets/create_post_sheet.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  void _openCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreatePostSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(profileFeedProvider);

    // İç içe (nested) Scaffold: sadece bu tab'a özel bir FAB eklemek için.
    // Dış Scaffold (MainScaffold) zaten bottomNavigationBar'ı yönetiyor.
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreatePostSheet(context),
        child: const Icon(Icons.add),
      ),
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(profileFeedProvider),
            child: const Text("Profil yüklenemedi, tekrar dene",
                style: TextStyle(color: Colors.white70)),
          ),
        ),
        data: (cards) => VerticalCardFeed(
          cards: cards,
          cardBuilder: buildFeedCard,
        ),
      ),
    );
  }
}
