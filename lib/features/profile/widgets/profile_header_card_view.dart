import 'package:flutter/material.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../models/feed_card.dart';

class ProfileHeaderCardView extends StatelessWidget {
  final ProfileHeaderCard card;

  const ProfileHeaderCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return CardShell(
      background: Container(color: Colors.grey.shade800),
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 32, backgroundColor: Colors.white24),
          const SizedBox(height: 10),
          Text(card.username,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 4),
          Text(card.bio, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text("${card.followerCount} takipçi",
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
      actions: [
        CardActionButton(icon: Icons.settings, label: "Ayarlar", onTap: () {}),
      ],
    );
  }
}
