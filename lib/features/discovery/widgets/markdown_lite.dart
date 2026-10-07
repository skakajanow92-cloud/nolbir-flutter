import 'package:flutter/material.dart';

/// Tek bir satırı **kalın**/_italik_/__altı çizili__ işaretlerine göre
/// `TextSpan` listesine çevirir. Gerçek bir markdown parser değil —
/// sadece bu kartın ihtiyacı kadar, bilinçli olarak minimal.
List<InlineSpan> parseInlineMarkdown(String line, TextStyle base) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'(\*\*.+?\*\*|__.+?__|_.+?_)');
  int last = 0;
  for (final match in pattern.allMatches(line)) {
    if (match.start > last) {
      spans.add(TextSpan(text: line.substring(last, match.start), style: base));
    }
    final token = match.group(0)!;
    if (token.startsWith('**')) {
      spans.add(
        TextSpan(
          text: token.substring(2, token.length - 2),
          style: base.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    } else if (token.startsWith('__')) {
      spans.add(
        TextSpan(
          text: token.substring(2, token.length - 2),
          style: base.copyWith(decoration: TextDecoration.underline),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: token.substring(1, token.length - 1),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }
    last = match.end;
  }
  if (last < line.length) {
    spans.add(TextSpan(text: line.substring(last), style: base));
  }
  return spans;
}

/// Bir belge gövdesini satır satır render eder — "- " ile başlayan
/// satırlar madde işaretli, diğerleri normal paragraf.
Widget buildMarkdownLiteBody(String body, {TextStyle? style}) {
  final base =
      style ??
      const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5);
  final lines = body.split('\n');
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: lines.map((line) {
      if (line.startsWith('- ')) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("•  ", style: base),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: parseInlineMarkdown(line.substring(2), base),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      if (line.trim().isEmpty) return const SizedBox(height: 10);
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(children: parseInlineMarkdown(line, base)),
        ),
      );
    }).toList(),
  );
}

/// TextField seçimini bir önek/sonek ile sarmalar (kalın/italik/altı
/// çizili butonları için). Seçim yoksa imleç konumuna boş sarmalayıcı
/// eklenir, imleç ortada kalır.
void wrapSelection(
  TextEditingController controller,
  String prefix,
  String suffix,
) {
  final selection = controller.selection;
  final text = controller.text;
  if (!selection.isValid) return;

  if (selection.isCollapsed) {
    final offset = selection.start;
    controller.text = text.replaceRange(offset, offset, '$prefix$suffix');
    controller.selection = TextSelection.collapsed(
      offset: offset + prefix.length,
    );
    return;
  }

  final selected = text.substring(selection.start, selection.end);
  controller.text = text.replaceRange(
    selection.start,
    selection.end,
    '$prefix$selected$suffix',
  );
  controller.selection = TextSelection(
    baseOffset: selection.start,
    extentOffset:
        selection.start + prefix.length + selected.length + suffix.length,
  );
}
