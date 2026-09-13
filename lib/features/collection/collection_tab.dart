import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/vertical_card_feed.dart';
import '../../app/card_factory.dart';
import 'application/collection_providers.dart';

class CollectionTab extends ConsumerWidget {
  const CollectionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(collectionFeedProvider);

    return feedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(collectionFeedProvider),
          child: const Text("Koleksiyon yüklenemedi, tekrar dene",
              style: TextStyle(color: Colors.white70)),
        ),
      ),
      data: (cards) {
        if (cards.isEmpty) {
          return const Center(
            child: Text("Henüz koleksiyonunda bir şey yok",
                style: TextStyle(color: Colors.white54)),
          );
        }
        return VerticalCardFeed(
          cards: cards,
          cardBuilder: buildFeedCard,
        );
      },
    );
  }
}
