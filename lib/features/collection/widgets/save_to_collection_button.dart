import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../models/feed_card.dart';
import '../application/collection_providers.dart';
import '../collection_item_builder.dart';

/// Herhangi bir FeedCard için "koleksiyona kaydet" aksiyon butonu.
/// Video, ürün, abonelik ... hepsi bunu kullanır — kart başına ayrı bir
/// kaydetme mantığı yazmak yerine tek bir widget.
///
/// `collectionFeedProvider`'ı izlediği için kart zaten koleksiyondaysa
/// buton otomatik "Kaydedildi" (dolu bookmark) gösterir; tekrar dokununca
/// koleksiyondan çıkarır — klasik toggle davranışı.
class SaveToCollectionButton extends ConsumerWidget {
  final FeedCard card;

  const SaveToCollectionButton({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionFeedProvider);
    final collectionItemId = "col_${card.id}";
    final isSaved =
        collectionAsync.value?.any((e) => e.id == collectionItemId) ?? false;

    return CardActionButton(
      icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
      label: isSaved ? "Kaydedildi" : "Kaydet",
      color: isSaved ? Colors.amberAccent : null,
      onTap: () {
        final notifier = ref.read(collectionFeedProvider.notifier);
        if (isSaved) {
          notifier.remove(collectionItemId);
        } else {
          notifier.add(toCollectionItem(card));
        }
      },
    );
  }
}
