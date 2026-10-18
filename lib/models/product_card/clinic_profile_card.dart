import '../feed_card/base.dart';
import 'health_common.dart';

class ClinicDoctorSummary {
  final String name;
  final MedicalSpecialty specialty;
  final String photoUrl;

  const ClinicDoctorSummary({
    required this.name,
    required this.specialty,
    this.photoUrl = "",
  });
}

/// Orta tab için: bir klinik/hastanenin tanıtım kartı. `DoctorAppointmentCard`
/// tek bir doktoru öne çıkarırken, bu kart kurumun geneline (branşlar,
/// kadro, adres) odaklanıyor.
class ClinicProfileCard extends FeedCard implements Collectible {
  final String clinicName;
  final String logoUrl;
  final List<String> imageUrls;
  final String description;
  final List<MedicalSpecialty> specialties;
  final List<ClinicDoctorSummary> doctors;
  final String address;
  final double rating;
  final int reviewCount;
  final String? detailUrl;

  const ClinicProfileCard({
    required String id,
    required this.clinicName,
    required this.logoUrl,
    required this.description,
    required this.specialties,
    required this.doctors,
    required this.address,
    this.imageUrls = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.detailUrl,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() =>
      (clinicName, imageUrls.isNotEmpty ? imageUrls.first : logoUrl);
}
