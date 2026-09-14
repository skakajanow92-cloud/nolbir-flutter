import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../models/feed_card/feed_card.dart';
import '../application/collection_providers.dart';

class CollectionItemCardView extends ConsumerWidget {
  final CollectionItemCard card;

  const CollectionItemCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardShell(
      background: Container(
        color: Colors.grey.shade900,
        alignment: Alignment.center,
        child: const Icon(Icons.bookmark, color: Colors.white24, size: 80),
        // TODO: card.previewUrl ile gerçek önizleme
      ),
      bottomContent: Text(card.title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      actions: [
        CardActionButton(
          icon: Icons.open_in_new,
          label: "Aç",
          onTap: () {
            // TODO: card.originalCard tipine göre orijinal ekrana yönlendir
          },
        ),
        CardActionButton(
          icon: Icons.delete_outline,
          label: "Çıkar",
          onTap: () => ref.read(collectionFeedProvider.notifier).remove(card.id),
        ),
      ],
    );
  }
}
