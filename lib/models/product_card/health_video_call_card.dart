import '../feed_card/base.dart';
import 'health_common.dart';

class UpcomingHealthAppointment {
  final String id;
  final String doctorName;
  final String doctorPhotoUrl;
  final MedicalSpecialty specialty;
  final DateTime scheduledAt;

  const UpcomingHealthAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.scheduledAt,
    this.doctorPhotoUrl = "",
  });

  /// Randevu saatine 5 dakika kala - sonrasına 30 dakika kadar "Katıl"
  /// butonu aktif. Gerçek backend bunu sunucu saatine göre, randevu
  /// durumuna (uzman hazır mı) bakarak belirleyecek.
  bool get isJoinable {
    final now = DateTime.now();
    return now.isAfter(scheduledAt.subtract(const Duration(minutes: 5))) &&
        now.isBefore(scheduledAt.add(const Duration(minutes: 30)));
  }
}

/// Orta tab için: SADECE tıbbi amaçlı canlı görüntülü görüşme kartı.
/// Ya planlı bir randevunun saati gelince katılım sağlar, ya da
/// "Hemen Görüş" ile anlık bir uzmana bağlanır.
///
/// MİMARİ UYARI (ÖNEMLİ — bu kart hiçbir zaman mesajlaşma kartının genel
/// sesli/görüntülü arama akışıyla (`NewCallDialog`/`ChatRoomDialog`)
/// BİRLEŞTİRİLMEMELİ, kod paylaşmamalı):
/// 1. Bu kanalın karşı ucunda HER ZAMAN doğrulanmış bir sağlık uzmanı
///    olmalı — backend bunu garanti etmeli, sıradan bir kullanıcı asla
///    bu kanala bağlanamamalı.
/// 2. Bu kanal ASLA yavaşlamamalı/ağır yük altında bloklanmamalı — tıbbi
///    acil durum potansiyeli taşır. Gerçek entegrasyonda genel
///    mesajlaşma/arama trafiğinden AYRI, öncelikli bir servise/kuyruğa
///    (ayrı WebSocket namespace'i, ayrı medya sunucusu havuzu, rate-limit
///    muafiyeti) yönlendirilmeli.
///
/// Bu yüzden view'daki bağlanma fonksiyonları BİLEREK mesajlaşma
/// kartındaki hiçbir yardımcıyı çağırmıyor; kendi ayrı yer tutucusunu
/// (`_connectToMedicalChannel`) kullanıyor.
class HealthVideoCallCard extends FeedCard {
  final List<UpcomingHealthAppointment> upcomingAppointments;
  final List<MedicalSpecialty> instantSpecialties;

  const HealthVideoCallCard({
    required String id,
    required this.upcomingAppointments,
    required this.instantSpecialties,
  }) : super(id);
}
