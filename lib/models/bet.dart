/// Bir bahis kuponunun sonuç durumu.
enum BetStatus { pending, won, lost, voided, cashedOut }

extension BetStatusLabel on BetStatus {
  String get label => switch (this) {
        BetStatus.pending => "Sonuçlanmadı",
        BetStatus.won => "Kazandı",
        BetStatus.lost => "Kaybetti",
        BetStatus.voided => "İptal (İade)",
        BetStatus.cashedOut => "Erken Bozdu",
      };
}

/// Bir kupondaki tek bir bahis seçimi (maç/etkinlik + tahmin).
class BetSelection {
  final String id;
  final String eventName; // örn. "Fenerbahçe - Galatasaray"
  final String market; // örn. "Maç Sonucu", "Alt/Üst 2.5"
  final String pick; // seçilen sonuç, örn. "MS1", "Üst"
  final double odds;

  const BetSelection({
    required this.id,
    required this.eventName,
    required this.market,
    required this.pick,
    required this.odds,
  });
}

/// Kullanıcının oynadığı ya da oynamayı planladığı tek bir bahis kuponu.
///
/// BİLİNÇLİ TASARIM KARARI: Geçmiş/gelecek ayrımı kupon oluşturma
/// tarihine değil `eventDateTime`e (kupondaki etkinliğin ne zaman
/// oynanacağına) dayanır — Travel/Event modüllerindeki aynı yaklaşım.
/// Birden fazla seçim içeren kombine kuponlarda `eventDateTime` en son
/// etkinliğin tarihidir (hepsi sonuçlanmadan kupon sonuçlanmaz).
class BetCoupon {
  final String id;
  final String bookmaker;
  final String couponCode;
  final DateTime placedDate;
  final DateTime eventDateTime;
  final double stake;
  final double totalOdds;
  final String currency;
  final BetStatus status;
  final double? cashedOutAmount; // sadece status == cashedOut için anlamlı
  final List<BetSelection> selections;

  const BetCoupon({
    required this.id,
    required this.bookmaker,
    required this.couponCode,
    required this.placedDate,
    required this.eventDateTime,
    required this.stake,
    required this.totalOdds,
    this.currency = "TRY",
    this.status = BetStatus.pending,
    this.cashedOutAmount,
    this.selections = const [],
  });

  bool get isUpcoming => eventDateTime.isAfter(DateTime.now());

  double get potentialReturn => stake * totalOdds;

  /// Kuponun net sonucu (kâr/zarar) — henüz sonuçlanmadıysa `null`.
  double? get netResult => switch (status) {
        BetStatus.won => potentialReturn - stake,
        BetStatus.lost => -stake,
        BetStatus.voided => 0,
        BetStatus.cashedOut => (cashedOutAmount ?? 0) - stake,
        BetStatus.pending => null,
      };
}

/// Kullanıcının bahis için ayırdığı toplam bütçe.
///
/// NOT: `remainingBudget` burada SAKLANMIYOR — `BetProfileCard` üzerinde
/// `totalBudget` ile henüz sonuçlanmamış kuponların `stake` toplamından
/// CANLI hesaplanıyor (bkz. taxi.dart/cargo.dart'taki aynı "saklamak
/// yerine türet" yaklaşımı).
class BettingBudget {
  final double totalBudget;
  final String currency;

  const BettingBudget({required this.totalBudget, this.currency = "TRY"});
}
