import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'document_editor_dialog.dart';

class WritingToolCardView extends StatefulWidget {
  final WritingToolCard card;

  const WritingToolCardView({super.key, required this.card});

  @override
  State<WritingToolCardView> createState() => _WritingToolCardViewState();
}

class _WritingToolCardViewState extends State<WritingToolCardView> {
  static const accent = Color(0xFF4C7CF0);
  static const _base = Color(0xFF14151A);
  static const _baseEnd = Color(0xFF1A1C24);

  final List<WritingDocument> _documents = [];

  void _newDocument() {
    final doc = WritingDocument(
      id: "doc_${DateTime.now().microsecondsSinceEpoch}",
    );
    setState(() => _documents.insert(0, doc));
    _openEditor(doc);
  }

  void _openEditor(WritingDocument doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DocumentEditorDialog(
        document: doc,
        onSave: () => setState(() {
          _documents.remove(doc);
          _documents.insert(0, doc); // en son düzenlenen en üste
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(card: widget.card),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.card.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: _newDocument,
                icon: const Icon(Icons.add),
                label: const Text("Yeni Belge"),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (_documents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Henüz belge yok — başlamak için \"Yeni Belge\" butonuna dokun.",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            )
          else
            for (final doc in _documents)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: _DocumentTile(
                  document: doc,
                  onTap: () => _openEditor(doc),
                ),
              ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final WritingToolCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.edit_note,
            color: _WritingToolCardViewState.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.toolName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                "Araç",
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final WritingDocument document;
  final VoidCallback onTap;
  const _DocumentTile({required this.document, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${document.wordCount} kelime · ${_formatRelative(document.updatedAt)}",
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  String _formatRelative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "az önce";
    if (diff.inHours < 1) return "${diff.inMinutes} dk önce";
    if (diff.inDays < 1) return "${diff.inHours} sa önce";
    return "${diff.inDays} gün önce";
  }
}
