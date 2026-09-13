import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/vertical_card_feed.dart';
import '../../app/card_factory.dart';
import 'application/discovery_providers.dart';

class DiscoveryTab extends ConsumerWidget {
  const DiscoveryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(discoveryFeedProvider);

    return feedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => _ErrorView(
        message: "Akış yüklenemedi",
        onRetry: () => ref.invalidate(discoveryFeedProvider),
      ),
      data: (cards) {
        if (cards.isEmpty) {
          return const Center(
            child: Text("Gösterilecek içerik yok",
                style: TextStyle(color: Colors.white54)),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(discoveryFeedProvider.notifier).refresh(),
          child: VerticalCardFeed(
            cards: cards,
            cardBuilder: buildFeedCard,
            onReachEnd: () => ref.read(discoveryFeedProvider.notifier).loadMore(),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text("Tekrar dene")),
        ],
      ),
    );
  }
}
