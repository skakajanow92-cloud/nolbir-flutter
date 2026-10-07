import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

class _MockPrinter {
  final String name;
  final bool isOnline;
  const _MockPrinter({required this.name, required this.isOnline});
}

const _mockPrinters = [
  _MockPrinter(name: "Ev Yazıcısı (HP LaserJet)", isOnline: true),
  _MockPrinter(name: "Ofis Yazıcısı - 2. Kat", isOnline: true),
  _MockPrinter(name: "Ofis Yazıcısı - Lobi", isOnline: false),
];

class PrintDocumentDialog extends StatefulWidget {
  final WritingDocument document;

  const PrintDocumentDialog({super.key, required this.document});

  @override
  State<PrintDocumentDialog> createState() => _PrintDocumentDialogState();
}

class _PrintDocumentDialogState extends State<PrintDocumentDialog> {
  static const accent = Color(0xFF4C7CF0);

  String? _selectedPrinter;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.8,
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
                "Yazdır",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "\"${widget.document.title}\" belgesini gönder",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final printer in _mockPrinters)
                RadioListTile<String>(
                  value: printer.name,
                  groupValue: _selectedPrinter,
                  onChanged: printer.isOnline
                      ? (v) => setState(() => _selectedPrinter = v)
                      : null,
                  activeColor: accent,
                  title: Text(
                    printer.name,
                    style: TextStyle(
                      color: printer.isOnline ? Colors.white : Colors.white30,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    printer.isOnline ? "Çevrimiçi" : "Çevrimdışı",
                    style: TextStyle(
                      color: printer.isOnline
                          ? Colors.greenAccent
                          : Colors.white30,
                      fontSize: 11,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: _selectedPrinter == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "$_selectedPrinter yazıcısına gönderildi (mock)",
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                  icon: const Icon(Icons.print_outlined),
                  label: const Text("Yazdır"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
