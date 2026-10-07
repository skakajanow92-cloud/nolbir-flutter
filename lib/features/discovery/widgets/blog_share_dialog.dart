import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'markdown_lite.dart';

class BlogShareDialog extends StatelessWidget {
  final WritingDocument document;

  const BlogShareDialog({super.key, required this.document});

  static const accent = Color(0xFF4C7CF0);

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
            color: Color(0xFF151515),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                "Blog Yazısı Önizleme",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                document.title.isEmpty ? "Başlıksız Belge" : document.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${document.wordCount} kelime",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),
              buildMarkdownLiteBody(document.body),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    // NOT: Gerçek yayınlama/paylaşım backend bağlanınca
                    // eklenecek — şimdilik sadece onay mesajı.
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Blog yazısı paylaşıldı (mock)"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.public),
                  label: const Text("Blog Olarak Paylaş"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
