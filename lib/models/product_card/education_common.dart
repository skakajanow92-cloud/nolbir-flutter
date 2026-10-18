import 'package:flutter/material.dart';

enum CourseFormat { online, inPerson, hybrid }

extension CourseFormatLabel on CourseFormat {
  String get label {
    switch (this) {
      case CourseFormat.online:
        return "Online";
      case CourseFormat.inPerson:
        return "Yüz Yüze";
      case CourseFormat.hybrid:
        return "Karma";
    }
  }
}

enum CourseLevel { beginner, intermediate, advanced, allLevels }

extension CourseLevelLabel on CourseLevel {
  String get label {
    switch (this) {
      case CourseLevel.beginner:
        return "Başlangıç";
      case CourseLevel.intermediate:
        return "Orta Seviye";
      case CourseLevel.advanced:
        return "İleri Seviye";
      case CourseLevel.allLevels:
        return "Tüm Seviyeler";
    }
  }
}

enum LessonContentType { video, pdf, liveSession }

extension LessonContentTypeLabel on LessonContentType {
  String get label {
    switch (this) {
      case LessonContentType.video:
        return "Video";
      case LessonContentType.pdf:
        return "PDF";
      case LessonContentType.liveSession:
        return "Canlı Ders";
    }
  }

  IconData get icon {
    switch (this) {
      case LessonContentType.video:
        return Icons.play_circle_outline;
      case LessonContentType.pdf:
        return Icons.picture_as_pdf_outlined;
      case LessonContentType.liveSession:
        return Icons.sensors;
    }
  }
}