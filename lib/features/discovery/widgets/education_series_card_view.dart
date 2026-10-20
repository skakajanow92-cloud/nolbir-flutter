import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'lesson_detail_dialog.dart';

class EducationSeriesCardView extends StatefulWidget {
  final EducationSeriesCard card;

  const EducationSeriesCardView({super.key, required this.card});

  @override
  State<EducationSeriesCardView> createState() =>
      _EducationSeriesCardViewState();
}

class _EducationSeriesCardViewState extends State<EducationSeriesCardView> {
  static const accent = Color(0xFF6C63E0);
  static const _base = Color(0xFF14121E);
  static const _baseEnd = Color(0xFF1C1930);
  static const _maxMockAdditions = 5;

  late List<SeriesLesson> _lessons;
  bool _isSubscribed = false;
  Timer? _timer;
  int _addedCount = 0;

  @override
  void initState() {
    super.initState();
    _lessons = List.of(widget.card.seedLessons)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// "Abone olunca sürekli güncellenir" davranışının somut bir
  /// göstergesi: gerçek backend yerine, abone olunduğu sürece belirli
  /// aralıklarla mock bir yeni ders ekleniyor. `_maxMockAdditions` ile
  /// sınırlı — sonsuz bir Timer bırakmamak için.
  void _toggleSubscribe() {
    setState(() => _isSubscribed = !_isSubscribed);
    if (_isSubscribed) {
      _timer = Timer.periodic(const Duration(seconds: 45), (_) {
        if (_addedCount >= _maxMockAdditions) {
          _timer?.cancel();
          return;
        }
        setState(() {
          _lessons.insert(0, _generateNewLesson(widget.card, _addedCount));
          _addedCount++;
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _openLesson(SeriesLesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LessonDetailDialog(lesson: lesson),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(
        card: widget.card,
        isSubscribed: _isSubscribed,
        onToggleSubscribe: _toggleSubscribe,
      ),
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
          const SizedBox(height: 14),
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: widget.card.instructors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) =>
                  _InstructorChip(instructor: widget.card.instructors[i]),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Dersler (${_lessons.length})",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final lesson in _lessons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: _LessonTile(
                lesson: lesson,
                isNew: DateTime.now().difference(lesson.addedAt).inDays < 7,
                onTap: () => _openLesson(lesson),
              ),
            ),
        ],
      ),
    );
  }
}

SeriesLesson _generateNewLesson(EducationSeriesCard card, int n) {
  final rnd = Random(card.id.hashCode + n);
  const titles = [
    "Tekrar ve Alıştırmalar",
    "Yeni Konu: İleri Teknikler",
    "Soru-Cevap Oturumu",
    "Özet Notlar",
  ];
  final instructor = card.instructors[rnd.nextInt(card.instructors.length)];
  final isVideo = rnd.nextBool();
  return SeriesLesson(
    id: "${card.id}_auto_$n",
    title: titles[rnd.nextInt(titles.length)],
    contentType: isVideo ? LessonContentType.video : LessonContentType.pdf,
    instructor: instructor,
    videoDuration: isVideo ? Duration(minutes: 8 + rnd.nextInt(30)) : null,
    pageCount: isVideo ? null : 3 + rnd.nextInt(20),
    addedAt: DateTime.now(),
  );
}

class _Header extends StatelessWidget {
  final EducationSeriesCard card;
  final bool isSubscribed;
  final VoidCallback onToggleSubscribe;
  const _Header({
    required this.card,
    required this.isSubscribed,
    required this.onToggleSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            color: Colors.white.withValues(alpha: 0.08),
            child: card.coverImageUrl.isEmpty
                ? const Icon(Icons.school_outlined, color: Colors.white54)
                : Image.network(card.coverImageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.seriesName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${card.instructors.length} eğitmen · ${card.language}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: isSubscribed
                ? Colors.white54
                : _EducationSeriesCardViewState.accent,
            side: BorderSide(
              color: isSubscribed
                  ? Colors.white24
                  : _EducationSeriesCardViewState.accent,
            ),
          ),
          onPressed: onToggleSubscribe,
          child: Text(isSubscribed ? "Abonesin" : "Abone Ol"),
        ),
      ],
    );
  }
}

class _InstructorChip extends StatelessWidget {
  final SeriesInstructor instructor;
  const _InstructorChip({required this.instructor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            child: instructor.avatarUrl.isEmpty
                ? Text(
                    instructor.name.isNotEmpty
                        ? instructor.name[0].toUpperCase()
                        : "?",
                    style: const TextStyle(color: Colors.white),
                  )
                : ClipOval(
                    child: Image.network(
                      instructor.avatarUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            instructor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final SeriesLesson lesson;
  final bool isNew;
  final VoidCallback onTap;
  const _LessonTile({
    required this.lesson,
    required this.isNew,
    required this.onTap,
  });

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
            Icon(
              lesson.contentType.icon,
              color: _EducationSeriesCardViewState.accent,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          lesson.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "YENİ",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    lesson.instructor.name,
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
}
