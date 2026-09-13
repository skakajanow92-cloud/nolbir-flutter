import 'package:flutter/material.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../models/feed_card.dart';

class UserPostCardView extends StatelessWidget {
  final UserPostCard card;

  const UserPostCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return CardShell(
      background: Container(
        color: Colors.grey.shade900,
        alignment: Alignment.center,
        child: const Icon(Icons.image, color: Colors.white24, size: 80),
        // TODO: card.mediaUrl ile gerçek görsel/video
      ),
      bottomContent: Text(card.caption,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      actions: [
        CardActionButton(icon: Icons.delete_outline, label: "Sil", onTap: () {}),
        CardActionButton(icon: Icons.edit, label: "Düzenle", onTap: () {}),
      ],
    );
  }
}
