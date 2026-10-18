import '../feed_card/base.dart';
import 'education_common.dart';

class SeriesInstructor {
  final String id;
  final String name;
  final String avatarUrl;
  final String title; // "Matematik Öğretmeni" vb.

  const SeriesInstructor({
    required this.id,
    required this.name,
    this.avatarUrl = "",
    this.title = "",
  });
}

class SeriesLesson {
  final String id;
  final String title;
  final LessonContentType contentType;
  final SeriesInstructor instructor;
  final Duration? videoDuration;
  final int? pageCount;
  final DateTime addedAt;

  const SeriesLesson({
    required this.id,
    required this.title,
    required this.contentType,
    required this.instructor,
    required this.addedAt,
    this.videoDuration,
    this.pageCount,
  });
}

/// Orta tab için: birkaç öğretmenden oluşan kapsamlı bir eğitim serisi.
/// `LiveCollectible` — kullanıcı abone/favori olunca statik bir önizleme
/// değil, yeni video/PDF derslerin eklendiği canlı akış olarak kalmalı
/// (bkz. view'daki periyodik mock ders ekleme).
class EducationSeriesCard extends FeedCard
    implements Collectible, LiveCollectible {
  final String seriesName;
  final String coverImageUrl;
  final String description;
  final List<SeriesInstructor> instructors;
  final List<SeriesLesson> seedLessons;
  final String language;
  final CourseLevel level;
  final double monthlyPrice;
  final String currency;
  final double rating;
  final int reviewCount;

  const EducationSeriesCard({
    required String id,
    required this.seriesName,
    required this.description,
    required this.instructors,
    required this.seedLessons,
    required this.language,
    this.coverImageUrl = "",
    this.level = CourseLevel.allLevels,
    this.monthlyPrice = 0,
    this.currency = "TRY",
    this.rating = 0,
    this.reviewCount = 0,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (seriesName, coverImageUrl);
}
