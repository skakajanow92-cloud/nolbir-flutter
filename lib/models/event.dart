/// Etkinlik kategorisi.
enum EventCategory { concert, theater, cinema, sports, festival, standup, exhibition }

extension EventCategoryLabel on EventCategory {
  String get label => switch (this) {
        EventCategory.concert => "Konser",
        EventCategory.theater => "Tiyatro",
        EventCategory.cinema => "Sinema",
        EventCategory.sports => "Spor",
        EventCategory.festival => "Festival",
        EventCategory.standup => "Stand-up",
        EventCategory.exhibition => "Sergi",
      };
}

/// Kullanıcının favori bir etkinliği/sanatçısı/takımı.
/// (örn. kategori: konser, name: "Duman" — ya da kategori: spor,
/// name: "Fenerbahçe")
class FavoriteEvent {
  final String id;
  final EventCategory category;
  final String name;
  final String? note; // örn. "Her turnesini kaçırmam"

  const FavoriteEvent({
    required this.id,
    required this.category,
    required this.name,
    this.note,
  });
}

/// Satın alınmış tek bir etkinlik bileti (geçmiş ya da gelecek).
///
/// BİLİNÇLİ TASARIM KARARI: `purchaseDate` ile `eventDateTime` AYRI
/// tutuluyor. Bu modülün asıl senaryosu "aylar öncesinden alınmış ama
/// tarihi henüz gelmemiş bilet" — tek bir tarih alanı bu ayrımı
/// taşıyamazdı. Travel/Accommodation modüllerindeki geçmiş/yaklaşan
/// ayrımı ve 7 günlük alarm eşiği burada da aynen izleniyor.
class EventTicket {
  final String id;
  final String eventName;
  final EventCategory category;
  final String venue; // mekan adı
  final String city;
  final DateTime eventDateTime;
  final DateTime purchaseDate;
  final String ticketCode;
  final String? seat; // örn. "A Blok · 14. sıra · 7"
  final int quantity;
  final double price;
  final String currency;

  const EventTicket({
    required this.id,
    required this.eventName,
    required this.category,
    required this.venue,
    required this.city,
    required this.eventDateTime,
    required this.purchaseDate,
    required this.ticketCode,
    this.seat,
    this.quantity = 1,
    required this.price,
    this.currency = "TRY",
  });

  bool get isUpcoming => eventDateTime.isAfter(DateTime.now());

  /// Etkinliğe kalan gün — geçmiş etkinliklerde negatif olur.
  int get daysUntilEvent =>
      eventDateTime.difference(DateTime.now()).inDays;

  /// Biletin ne kadar önceden alındığı (gün). "Önceden alınmış bilet"
  /// vurgusunu göstermek için kullanılır.
  int get daysBoughtInAdvance =>
      eventDateTime.difference(purchaseDate).inDays;

  double get total => price * quantity;
}
