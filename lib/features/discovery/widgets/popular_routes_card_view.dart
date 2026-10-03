import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';

class PopularRoutesCardView extends StatelessWidget {
  final PopularRoutesCard card;

  const PopularRoutesCardView({super.key, required this.card});

  static const _base = Color(0xFF0E1420);
  static const _baseEnd = Color(0xFF17213A);
  static const accent = Color(0xFFFFA23E);

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore_outlined, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                card.subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            card.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          for (final route in card.routes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _RouteTile(route: route),
            ),
        ],
      ),
    );
  }
}

class _RouteTile extends StatelessWidget {
  final PopularRouteItem route;
  const _RouteTile({required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            route.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.white.withValues(alpha: 0.06),
              child: const Icon(
                Icons.landscape_outlined,
                color: Colors.white24,
                size: 32,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 12,
            right: 14,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      route.destinationName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (route.tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: PopularRoutesCardView.accent.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          route.tag!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${route.fromCity} → ${route.toCity}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  "${route.startingPrice.toStringAsFixed(0)} ${route.currency}'den başlayan fiyatlarla",
                  style: const TextStyle(
                    color: PopularRoutesCardView.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
