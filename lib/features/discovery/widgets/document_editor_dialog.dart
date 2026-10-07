import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'markdown_lite.dart';
import 'blog_share_dialog.dart';
import 'print_document_dialog.dart';

/// Belge düzenleyici. `onSave` her kayıtta çağrılır — kartın sahip
/// olduğu `WritingDocument` nesnesi mutable olduğu için burada yeni bir
/// nesne üretmek yerine doğrudan üzerine yazıyoruz; `onSave` sadece dış
/// widget'ın `setState` ile yeniden çizilmesini tetikler.
class DocumentEditorDialog extends StatefulWidget {
  final WritingDocument document;
  final VoidCallback onSave;

  const DocumentEditorDialog({
    super.key,
    required this.document,
    required this.onSave,
  });

  @override
  State<DocumentEditorDialog> createState() => _DocumentEditorDialogState();
}

class _DocumentEditorDialogState extends State<DocumentEditorDialog> {
  //static const accent = Color(0xFF4C7CF0);

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _bodyController = TextEditingController(text: widget.document.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    widget.document
      ..title = _titleController.text.trim().isEmpty
          ? "Başlıksız Belge"
          : _titleController.text.trim()
      ..body = _bodyController.text
      ..updatedAt = DateTime.now();
    widget.onSave();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Kaydedildi"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF151515),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Başlık",
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    TextButton(onPressed: _save, child: const Text("Kaydet")),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              _FormatToolbar(
                controller: _bodyController,
                onChanged: () => setState(() {}),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _bodyController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Yazmaya başla...",
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _save();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  BlogShareDialog(document: widget.document),
                            );
                          },
                          icon: const Icon(Icons.public, size: 18),
                          label: const Text("Paylaş"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _save();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => PrintDocumentDialog(
                                document: widget.document,
                              ),
                            );
                          },
                          icon: const Icon(Icons.print_outlined, size: 18),
                          label: const Text("Yazdır"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FormatToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _FormatToolbar({required this.controller, required this.onChanged});

  void _apply(String prefix, String suffix) {
    wrapSelection(controller, prefix, suffix);
    onChanged();
  }

  void _toggleBullet() {
    final selection = controller.selection;
    final text = controller.text;
    final lineStart =
        text.lastIndexOf('\n', (selection.start - 1).clamp(0, text.length)) + 1;
    controller.text = text.replaceRange(lineStart, lineStart, '- ');
    controller.selection = TextSelection.collapsed(offset: selection.start + 2);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.format_bold, color: Colors.white70),
            onPressed: () => _apply("**", "**"),
          ),
          IconButton(
            icon: const Icon(Icons.format_italic, color: Colors.white70),
            onPressed: () => _apply("_", "_"),
          ),
          IconButton(
            icon: const Icon(Icons.format_underline, color: Colors.white70),
            onPressed: () => _apply("__", "__"),
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted, color: Colors.white70),
            onPressed: _toggleBullet,
          ),
        ],
      ),
    );
  }
}
