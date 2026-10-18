import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

class LessonDetailDialog extends StatelessWidget {
  final SeriesLesson lesson;

  const LessonDetailDialog({super.key, required this.lesson});

  static const accent = Color(0xFF6C63E0);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF14121E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  Icon(lesson.contentType.icon, color: accent, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "${lesson.instructor.name} · ${lesson.instructor.title}",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.contentType == LessonContentType.video
                    ? "Süre: ${lesson.videoDuration?.inMinutes ?? 0} dk"
                    : lesson.contentType == LessonContentType.pdf
                    ? "${lesson.pageCount ?? 0} sayfa"
                    : "Canlı ders",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${lesson.title} açılıyor (mock)"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(
                    lesson.contentType == LessonContentType.pdf
                        ? Icons.open_in_new
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    lesson.contentType == LessonContentType.pdf
                        ? "Görüntüle"
                        : "İzle",
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
