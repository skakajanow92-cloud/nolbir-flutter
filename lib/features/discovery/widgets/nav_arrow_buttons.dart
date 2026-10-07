import 'package:flutter/material.dart';
import '../../../core/widgets/vertical_card_feed.dart';

/// Kendi içinde sonsuz/iç içe dikey kaydırmalı kartlarda (sosyal akış,
/// video akışı) dış ana akışta gezinmek için kullanılan sabit ok
/// butonları. `VerticalFeedController` yoksa (kart bir feed dışında
/// render ediliyorsa) hiçbir şey çizmez.
class NavArrowOverlay extends StatelessWidget {
  const NavArrowOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final feedController = VerticalFeedController.maybeOf(context);
    if (feedController == null) return const SizedBox.shrink();

    return Positioned(
      right: 10,
      top: 0,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrowButton(
              icon: Icons.keyboard_arrow_up,
              onTap: feedController.previousPage,
            ),
            const SizedBox(height: 10),
            _ArrowButton(
              icon: Icons.keyboard_arrow_down,
              onTap: feedController.nextPage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
