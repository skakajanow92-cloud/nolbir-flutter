import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'course_search_results_dialog.dart';

class CourseSearchCardView extends StatefulWidget {
  final CourseSearchCard card;

  const CourseSearchCardView({super.key, required this.card});

  @override
  State<CourseSearchCardView> createState() => _CourseSearchCardViewState();
}

class _CourseSearchCardViewState extends State<CourseSearchCardView> {
  static const accent = Color(0xFF3FA6E0);

  String? _subject;
  String? _language;
  CourseLevel? _level;
  CourseFormat? _format;

  bool get _isValid => _subject != null && _language != null;

  void _openResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CourseSearchResultsDialog(subject: _subject!, language: _language!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return CardPageScaffold(
      baseColor: const Color(0xFF0E1620),
      baseEndColor: const Color(0xFF152030),
      header: _Header(card: card),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            const _FieldLabel("Konu"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.subjects
                  .map(
                    (s) => _ToggleChip(
                      label: s,
                      selected: _subject == s,
                      onTap: () => setState(() => _subject = s),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const _FieldLabel("Dil"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.languages
                  .map(
                    (l) => _ToggleChip(
                      label: l,
                      selected: _language == l,
                      onTap: () => setState(() => _language = l),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const _FieldLabel("Seviye"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CourseLevel.values
                  .map(
                    (lv) => _ToggleChip(
                      label: lv.label,
                      selected: _level == lv,
                      onTap: () => setState(() => _level = lv),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const _FieldLabel("Format"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CourseFormat.values
                  .map(
                    (f) => _ToggleChip(
                      label: f.label,
                      selected: _format == f,
                      onTap: () => setState(() => _format = f),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: _isValid ? _openResults : null,
                child: const Text("Kurs ara"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CourseSearchCard card;
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
          child: card.platformLogoUrl.isEmpty
              ? const Icon(
                  Icons.search,
                  color: _CourseSearchCardViewState.accent,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(card.platformLogoUrl, fit: BoxFit.cover),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            card.platformName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? _CourseSearchCardViewState.accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _CourseSearchCardViewState.accent
                : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
