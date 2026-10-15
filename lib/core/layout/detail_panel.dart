import 'package:flutter/material.dart';
import '../../models/feed_card/feed_card.dart';
import '../widgets/detail_kit.dart';
import 'card_detail_registry.dart';
import 'feed_activity.dart';

/// Geniş ekranlarda feed'in yanında duran panel. Seçili tab'ın aktif kartı
/// değiştikçe içeriği de değişir (yumuşak geçişle). Kartın türüne özel
/// içerik `CardDetailRegistry`'den gelir; kayıt yoksa genel bir önizleme
/// gösterilir.
class DetailPanel extends StatelessWidget {
  final FeedActivityTracker tracker;
  final int tabIndex;

  const DetailPanel({
    super.key,
    required this.tracker,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(20));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F12),
          borderRadius: radius,
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: ListenableBuilder(
            listenable: tracker,
            builder: (context, _) {
              final card = tracker.activeFor(tabIndex);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, if (current != null) current],
                ),
                child: KeyedSubtree(
                  // Aynı kartın verisi güncellenirse (aynı id) animasyonsuz
                  // yerinde yenilenir; farklı kart/tab ise geçiş animasyonu
                  // çalışır.
                  key: ValueKey('$tabIndex:${card?.id}'),
                  child: card == null
                      ? const _EmptyPanel()
                      : (CardDetailRegistry.build(context, card) ??
                          _GenericDetail(card: card)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, color: Colors.white24, size: 40),
            SizedBox(height: 12),
            Text('Detaylar burada görünür',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text(
              'Akıştaki aktif kartın ayrıntıları, kart değiştikçe bu panelde güncellenir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detay görünümü kaydedilmemiş kart türleri için fallback.
class _GenericDetail extends StatelessWidget {
  final FeedCard card;

  const _GenericDetail({required this.card});

  @override
  Widget build(BuildContext context) {
    final title = card is Collectible
        ? (card as Collectible).toCollectionPreview().$1
        : card.runtimeType.toString();

    return DetailPage(
      title: title.isEmpty ? card.runtimeType.toString() : title,
      subtitle: card.runtimeType.toString(),
      icon: Icons.info_outline,
      accent: const Color(0xFF3E4A5A),
      children: [
        DetailSection(
          title: 'Kart',
          spacing: 0,
          children: [
            DetailRow(label: 'Tür', value: card.runtimeType.toString()),
            DetailRow(label: 'Kimlik', value: card.id),
          ],
        ),
        const DetailEmpty('Bu kart türü için henüz ek detay tanımlanmadı.'),
      ],
    );
  }
}
