import '../feed_card/base.dart';
import 'health_common.dart';

class AppointmentSlot {
  final String id;
  final DateTime dateTime;
  final bool isOnline;

  const AppointmentSlot({
    required this.id,
    required this.dateTime,
    this.isOnline = true,
  });
}

/// Orta tab için: bir doktorun ya da kliniğin randevu alınabilir
/// profili. `isVerifiedSpecialist` rozeti burada da gösteriliyor —
/// sağlık serisinin genelinde "karşıda mutlaka doğrulanmış bir uzman
/// olmalı" ilkesinin görünür kısmı.
class DoctorAppointmentCard extends FeedCard implements Collectible {
  final String doctorName;
  final String doctorPhotoUrl;
  final String clinicName;
  final MedicalSpecialty specialty;
  final String bio;
  final bool isVerifiedSpecialist;
  final double rating;
  final int reviewCount;
  final double consultationFee;
  final String currency;
  final List<AppointmentSlot> availableSlots;

  const DoctorAppointmentCard({
    required String id,
    required this.doctorName,
    required this.doctorPhotoUrl,
    required this.clinicName,
    required this.specialty,
    required this.bio,
    required this.consultationFee,
    required this.availableSlots,
    this.isVerifiedSpecialist = true,
    this.rating = 0,
    this.reviewCount = 0,
    this.currency = "TRY",
  }) : super(id);

  @override
  (String, String) toCollectionPreview() =>
      ("$doctorName · ${specialty.label}", doctorPhotoUrl);
}
