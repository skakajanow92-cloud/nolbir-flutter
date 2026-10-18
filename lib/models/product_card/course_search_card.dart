import '../feed_card/base.dart';

class CourseSearchCard extends FeedCard {
  final String platformName;
  final String platformLogoUrl;
  final String description;
  final List<String> subjects;
  final List<String> languages;

  const CourseSearchCard({
    required String id,
    required this.platformName,
    required this.platformLogoUrl,
    required this.description,
    this.subjects = const [],
    this.languages = const [],
  }) : super(id);
}
