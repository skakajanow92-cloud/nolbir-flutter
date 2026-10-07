import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'ecommerce_shared_widgets.dart' show AttributeBadge;

class StreamingTitleDetailDialog extends StatelessWidget {
  final StreamingTitle title;
  final bool hasAccess;
  final String missingAccessReason; // erişim yoksa gösterilecek metin
  final VoidCallback onRequestSubscribe;

  const StreamingTitleDetailDialog({
    super.key,
    required this.title,
    required this.hasAccess,
    required this.missingAccessReason,
    required this.onRequestSubscribe,
  });

  static const accent = Color(0xFFE50914);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.05),
                    child: title.posterUrl.isEmpty
                        ? const Icon(
                            Icons.movie_outlined,
                            color: Colors.white24,
                            size: 56,
                          )
                        : Image.network(title.posterUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    "${title.releaseYear}",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title.type.label,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Text(
                    title.rating.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (title.isAdult) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "18+",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title.synopsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (title.languageOptions.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: title.languageOptions
                      .map(
                        (l) => AttributeBadge(
                          text: l,
                          accentColor: accent,
                          icon: Icons.language,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              if (hasAccess)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    onPressed: () {
                      // NOT: Gerçek oynatıcı backend bağlanınca eklenecek.
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${title.name} oynatılıyor (mock)"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("İzle"),
                  ),
                )
              else ...[
                Text(
                  missingAccessReason,
                  style: const TextStyle(color: Colors.amber, fontSize: 13),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    onPressed: onRequestSubscribe,
                    child: const Text("Abone Ol"),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
