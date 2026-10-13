import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'spreadsheet_formula_engine.dart';
import 'spreadsheet_blog_share_dialog.dart';
import 'print_document_dialog.dart';

class SpreadsheetEditorDialog extends StatefulWidget {
  final SpreadsheetDocument document;
  final VoidCallback onSave;

  const SpreadsheetEditorDialog({
    super.key,
    required this.document,
    required this.onSave,
  });

  @override
  State<SpreadsheetEditorDialog> createState() =>
      _SpreadsheetEditorDialogState();
}

class _SpreadsheetEditorDialogState extends State<SpreadsheetEditorDialog> {
  //static const accent = Color(0xFF2FB380);

  late final TextEditingController _titleController;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    widget.document
      ..title = _titleController.text.trim().isEmpty
          ? "Başlıksız Tablo"
          : _titleController.text.trim()
      ..updatedAt = DateTime.now();
    widget.onSave();
  }

  void _onCellChanged(int row, int col, String value) {
    setState(() => widget.document.grid[row][col] = value);
  }

  void _addRow() {
    setState(
      () => widget.document.grid.add(List.filled(widget.document.colCount, "")),
    );
  }

  void _addColumn() {
    setState(() {
      for (final row in widget.document.grid) {
        row.add("");
      }
    });
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
                          hintText: "Tablo başlığı",
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    TextButton(onPressed: _save, child: const Text("Kaydet")),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: "Hızlı ara...",
                          hintStyle: const TextStyle(color: Colors.white30),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white38,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.view_week_outlined,
                        color: Colors.white70,
                      ),
                      tooltip: "Sütun ekle",
                      onPressed: _addColumn,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.table_rows_outlined,
                        color: Colors.white70,
                      ),
                      tooltip: "Satır ekle",
                      onPressed: _addRow,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _SpreadsheetGrid(
                    document: widget.document,
                    searchQuery: _searchQuery,
                    onCellChanged: _onCellChanged,
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
                              builder: (_) => SpreadsheetBlogShareDialog(
                                document: widget.document,
                              ),
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
                                documentTitle: widget.document.title,
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

class _SpreadsheetGrid extends StatelessWidget {
  final SpreadsheetDocument document;
  final String searchQuery;
  final void Function(int row, int col, String value) onCellChanged;

  const _SpreadsheetGrid({
    required this.document,
    required this.searchQuery,
    required this.onCellChanged,
  });

  static const double cellWidth = 92;
  static const double cellHeight = 36;
  static const double headerWidth = 36;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: headerWidth, height: cellHeight),
                for (var c = 0; c < document.colCount; c++)
                  Container(
                    width: cellWidth,
                    height: cellHeight,
                    alignment: Alignment.center,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: Text(
                      columnLabel(c),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            for (var r = 0; r < document.rowCount; r++)
              Row(
                children: [
                  Container(
                    width: headerWidth,
                    height: cellHeight,
                    alignment: Alignment.center,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: Text(
                      "${r + 1}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  for (var c = 0; c < document.colCount; c++)
                    _Cell(
                      key: ValueKey('$r-$c'),
                      rawValue: document.grid[r][c],
                      displayValue: evaluateCell(document.grid, r, c),
                      isMatch:
                          searchQuery.isNotEmpty &&
                          evaluateCell(
                            document.grid,
                            r,
                            c,
                          ).toLowerCase().contains(searchQuery.toLowerCase()),
                      width: cellWidth,
                      height: cellHeight,
                      onChanged: (v) => onCellChanged(r, c, v),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// TEK TEK hücrelere `ValueKey('$r-$c')` vermek bilinçli — herhangi bir
/// hücre değiştiğinde üst widget tüm grid'i yeniden kuruyor (formüller
/// birbirine bağlı olabileceği için tüm hücrelerin yeniden değerlendirilmesi
/// gerekiyor). Key olmasaydı her rebuild'de her `_Cell` için YENİ bir
/// `TextEditingController` oluşurdu ve o an düzenlenmekte olan hücrede
/// imleç sıçrardı (ticket formundaki `_CityField` ile aynı hata sınıfı).
/// Key, Flutter'a "bu State nesnesini koru" dedirtiyor; controller sadece
/// `initState`'te bir kez kuruluyor.
class _Cell extends StatefulWidget {
  final String rawValue;
  final String displayValue;
  final bool isMatch;
  final double width;
  final double height;
  final ValueChanged<String> onChanged;

  const _Cell({
    super.key,
    required this.rawValue,
    required this.displayValue,
    required this.isMatch,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.rawValue);
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _editing = _focusNode.hasFocus);
        if (!_focusNode.hasFocus) widget.onChanged(_controller.text);
      });
  }

  @override
  void didUpdateWidget(covariant _Cell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Odakta değilken dışarıdan (ör. satır/sütun eklenince ya da başka
    // bir hücrenin formülü bunu etkileyince) gelen değişiklikleri yansıt.
    if (!_focusNode.hasFocus && widget.rawValue != _controller.text) {
      _controller.text = widget.rawValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12, width: 0.5),
        color: widget.isMatch
            ? Colors.amber.withValues(alpha: 0.18)
            : (_editing
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.transparent),
      ),
      alignment: Alignment.centerLeft,
      child: _editing
          ? TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            )
          : GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
    );
  }
}
