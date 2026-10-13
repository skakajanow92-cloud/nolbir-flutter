import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'spreadsheet_formula_engine.dart';

class SpreadsheetBlogShareDialog extends StatelessWidget {
  final SpreadsheetDocument document;

  const SpreadsheetBlogShareDialog({super.key, required this.document});

  static const accent = Color(0xFF2FB380);

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
                "Tablo Önizleme",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                document.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.white12),
                  defaultColumnWidth: const FixedColumnWidth(80),
                  children: [
                    for (var r = 0; r < document.rowCount; r++)
                      TableRow(
                        children: [
                          for (var c = 0; c < document.colCount; c++)
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                evaluateCell(document.grid, r, c),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Tablo blog yazısı olarak paylaşıldı (mock)",
                        ),
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
