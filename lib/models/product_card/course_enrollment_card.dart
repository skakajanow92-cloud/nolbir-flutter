import '../feed_card/base.dart';
import 'education_common.dart';

/// Orta tab için: bir öğretmenin ya da okulun tek bir ders sezonuna
/// kayıt ilanı. `format` alanı hem online kursu hem gerçek fiziki
/// okul/sezon duyurusunu (semt/ülke ile) tek kart tipinde birleştiriyor
/// — ikisi de aynı veri şeklini (sağlayıcı, sezon tarihleri, fiyat,
/// kontenjan) paylaştığı için ayrı bir kart türü açmadım.
class CourseEnrollmentCard extends FeedCard implements Collectible {
  final String providerName; // öğretmen adı ya da okul adı
  final String providerLogoUrl;
  final bool isSchool;
  final String courseTitle;
  final String description;
  final List<String> imageUrls;
  final CourseFormat format;
  final String? country;
  final String? district;
  final String language;
  final CourseLevel level;
  final DateTime seasonStart;
  final DateTime seasonEnd;
  final DateTime enrollmentDeadline;
  final int seatsTotal;
  final int seatsTaken;
  final double price;
  final double? discountedPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final String? detailUrl;

  const CourseEnrollmentCard({
    required String id,
    required this.providerName,
    required this.providerLogoUrl,
    required this.isSchool,
    required this.courseTitle,
    required this.description,
    required this.format,
    required this.language,
    required this.seasonStart,
    required this.seasonEnd,
    required this.enrollmentDeadline,
    required this.price,
    this.imageUrls = const [],
    this.country,
    this.district,
    this.level = CourseLevel.allLevels,
    this.seatsTotal = 0,
    this.seatsTaken = 0,
    this.discountedPrice,
    this.currency = "TRY",
    this.rating = 0,
    this.reviewCount = 0,
    this.detailUrl,
  }) : super(id);

  int get seatsAvailable => seatsTotal - seatsTaken;
  bool get isFull => seatsTotal > 0 && seatsAvailable <= 0;
  double get effectivePrice => discountedPrice ?? price;

  @override
  (String, String) toCollectionPreview() => (
    "$providerName · $courseTitle",
    imageUrls.isNotEmpty ? imageUrls.first : providerLogoUrl,
  );
}
