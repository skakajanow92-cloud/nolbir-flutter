import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../models/form_card/verification_level.dart';

/// Tek bir adımın güncel durumu — `VerificationStatus.statusFor()` bunu
/// hesaplar, repository/provider katmanı ayrıca saklamaz.
enum StepStatus {
  /// Önceki adım henüz onaylanmadığı için bu adıma girilemez.
  locked,

  /// Sıradaki adım, kullanıcı başlatabilir.
  available,

  /// Kullanıcı gönderdi, admin/sunucu onayı bekleniyor (yalnızca B1/B2/C1
  /// için anlamlı — e-posta/telefon kod onayı anlık, hiç `pending`'e girmez).
  pending,

  /// Bu adım onaylandı, `approvedLevel` bu adımı kapsıyor.
  approved,

  /// Admin reddetti — `VerificationStatus.rejectionReason` dolu olur,
  /// kullanıcı aynı adımı yeniden deneyebilir (adım `available` kalır, ama
  /// UI reddi gösterir).
  rejected,
}

/// C1 adımında kullanıcının seçebileceği iki başvuru türü.
enum FullAccessRequestType { branchVisit, liveInterview }

extension FullAccessRequestTypeX on FullAccessRequestType {
  String get label => switch (this) {
        FullAccessRequestType.branchVisit => "Şubeye Başvuru",
        FullAccessRequestType.liveInterview => "Canlı Görüşme Talebi",
      };
}

/// Kullanıcının doğrulama akışındaki TEK gerçek kaynak.
///
/// `approvedLevel`: o ana kadar ONAYLANMIŞ en yüksek seviye — akış nerede
/// bırakılırsa bırakılsın, buraya kadar verilen izinler çalışmaya devam eder
/// (kullanıcının açık isteği). `pendingLevel`/`rejectionReason` sadece "şu an
/// hangi adımla ilgili bekleyen/reddedilen bir başvuru var" bilgisini taşır —
/// `approvedLevel`i ETKİLEMEZ, o yüzden ayrı alanlar.
class VerificationStatus {
  final VerificationLevel approvedLevel;
  final VerificationLevel? pendingLevel;
  final String? rejectionReason;

  const VerificationStatus({
    this.approvedLevel = VerificationLevel.none,
    this.pendingLevel,
    this.rejectionReason,
  });

  /// Doğrulama akışındaki 5 adım, sıralı (B1/B2/C1 admin onayı gerektirir,
  /// A1/A2 anlık onaylanır — bkz. `StepStatus` doc comment).
  static const steps = [
    VerificationLevel.emailVerified,
    VerificationLevel.phoneVerified,
    VerificationLevel.nationalDocumentVerified,
    VerificationLevel.internationalDocumentVerified,
    VerificationLevel.fullAccess,
  ];

  /// Bir adımın şu anki durumu. Sıralama kuralı burada uygulanıyor: bir
  /// seviye, bir önceki seviye `approvedLevel`e dahil olmadan asla
  /// `available`/`pending`/`rejected` olamaz -> `locked` kalır.
  StepStatus statusFor(VerificationLevel level) {
    if (level.index <= approvedLevel.index) return StepStatus.approved;
    if (pendingLevel == level) return StepStatus.pending;
    final previousApproved = level.index - 1 <= approvedLevel.index;
    if (!previousApproved) return StepStatus.locked;
    if (rejectionReason != null && pendingLevel == null) {
      // En son reddedilen adım, tekrar denenebilir durumda bekliyor.
      return StepStatus.rejected;
    }
    return StepStatus.available;
  }

  VerificationStatus copyWith({
    VerificationLevel? approvedLevel,
    VerificationLevel? pendingLevel,
    bool clearPending = false,
    String? rejectionReason,
    bool clearRejection = false,
  }) {
    return VerificationStatus(
      approvedLevel: approvedLevel ?? this.approvedLevel,
      pendingLevel: clearPending ? null : (pendingLevel ?? this.pendingLevel),
      rejectionReason:
          clearRejection ? null : (rejectionReason ?? this.rejectionReason),
    );
  }
}

/// Kimlik doğrulama akışının veri kaynağı sözleşmesi.
///
/// Diğer tüm repository'lerle AYNI mock/gerçek deseni. Dosya yükleme
/// gerektiren adımlar (B1/B2) bilinçli olarak `String` URL alır/verir —
/// dosyanın kendisini yükleme işi zaten `MediaService`'in sorumluluğu
/// (bkz. `core/media/`); bu repository SADECE "bu URL'deki belge doğrulama
/// başvurusu için gönderildi" bilgisini taşır, iki katman birbirine
/// karışmaz.
abstract class VerificationRepository {
  Future<VerificationStatus> fetchStatus();

  Future<void> sendEmailCode({required String email});
  Future<VerificationStatus> confirmEmailCode({
    required String email,
    required String code,
  });

  Future<void> sendPhoneCode({required String phoneNumber});
  Future<VerificationStatus> confirmPhoneCode({
    required String phoneNumber,
    required String code,
  });

  Future<VerificationStatus> submitNationalDocument({
    required String frontImageUrl,
    String? backImageUrl,
  });

  Future<VerificationStatus> submitInternationalDocument({
    required String passportImageUrl,
  });

  Future<VerificationStatus> submitFullAccessRequest({
    required FullAccessRequestType type,
    String? note,
  });
}

/// Geliştirme/mock implementasyonu.
///
/// B1/B2/C1 gönderimleri gerçek hayatta bir admin'in incelemesini bekler
/// (kullanıcının açık isteği: "admin bile bu doğrulamayı adım adım
/// götürsün"). Burada gerçek bir admin paneli olmadığından, gönderim
/// `pending`'e düşüyor ve kısa bir gecikme sonrasında KENDİLİĞİNDEN
/// onaylanmış sayılıyor — SADECE akışı baştan sona test edebilmek için;
/// gerçek `DioVerificationRepository`de bu asla olmaz, onay sunucu/admin
/// tarafından gelir ve UI'ın `fetchStatus()`u tekrar çağırması
/// (ör. akış ekranı her açıldığında) gerekir.
class MockVerificationRepository implements VerificationRepository {
  VerificationStatus _status = const VerificationStatus();

  @override
  Future<VerificationStatus> fetchStatus() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _status;
  }

  @override
  Future<void> sendEmailCode({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<VerificationStatus> confirmEmailCode({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _requireSixDigitCode(code);
    _status = _status.copyWith(
      approvedLevel: VerificationLevel.emailVerified,
      clearPending: true,
      clearRejection: true,
    );
    return _status;
  }

  @override
  Future<void> sendPhoneCode({required String phoneNumber}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<VerificationStatus> confirmPhoneCode({
    required String phoneNumber,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _requireSixDigitCode(code);
    _status = _status.copyWith(
      approvedLevel: VerificationLevel.phoneVerified,
      clearPending: true,
      clearRejection: true,
    );
    return _status;
  }

  @override
  Future<VerificationStatus> submitNationalDocument({
    required String frontImageUrl,
    String? backImageUrl,
  }) {
    return _submitForReview(VerificationLevel.nationalDocumentVerified);
  }

  @override
  Future<VerificationStatus> submitInternationalDocument({
    required String passportImageUrl,
  }) {
    return _submitForReview(VerificationLevel.internationalDocumentVerified);
  }

  @override
  Future<VerificationStatus> submitFullAccessRequest({
    required FullAccessRequestType type,
    String? note,
  }) {
    return _submitForReview(VerificationLevel.fullAccess);
  }

  Future<VerificationStatus> _submitForReview(VerificationLevel level) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _status = _status.copyWith(pendingLevel: level, clearRejection: true);
    // Mock-only: gerçek admin incelemesini simüle etmek için gecikmeli
    // kendiliğinden onay. DioVerificationRepository'de YOK.
    Future.delayed(const Duration(seconds: 3), () {
      if (_status.pendingLevel == level) {
        _status = _status.copyWith(
          approvedLevel: level,
          clearPending: true,
          clearRejection: true,
        );
      }
    });
    return _status;
  }

  void _requireSixDigitCode(String code) {
    if (code.length != 6 || !RegExp(r'^\d+$').hasMatch(code)) {
      throw const ApiException("Kod 6 haneli olmalı");
    }
  }
}

/// Gerçek backend'e bağlı implementasyon.
///
/// VARSAYIM (backend sözleşmesi henüz doğrulanmadı, kullanıcıdan teyit
/// bekliyor): uç noktalar `POST /verification/email/send`,
/// `POST /verification/email/confirm`, `POST /verification/phone/send`,
/// `POST /verification/phone/confirm`, `POST /verification/documents/national`,
/// `POST /verification/documents/international`,
/// `POST /verification/full-access-request`, `GET /verification/status` —
/// hepsinin cevap gövdesi `VerificationStatus`a eşlenecek şekilde (approvedLevel/
/// pendingLevel/rejectionReason alanları) varsayıldı. Gerçek sözleşme
/// farklıysa sadece bu sınıftaki endpoint string'leri ve JSON eşlemesi
/// güncellenir.
class DioVerificationRepository implements VerificationRepository {
  final ApiClient _client;

  DioVerificationRepository({ApiClient? client}) : _client = client ?? ApiClient.main;

  VerificationLevel _levelFromName(String? name) {
    return VerificationLevel.values.firstWhere(
      (l) => l.name == name,
      orElse: () => VerificationLevel.none,
    );
  }

  VerificationStatus _fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      approvedLevel: _levelFromName(json['approvedLevel'] as String?),
      pendingLevel: json['pendingLevel'] != null
          ? _levelFromName(json['pendingLevel'] as String?)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  @override
  Future<VerificationStatus> fetchStatus() async {
    final response = await _client.get<Map<String, dynamic>>("/verification/status");
    return _fromJson(response.data!);
  }

  @override
  Future<void> sendEmailCode({required String email}) async {
    await _client.post("/verification/email/send", data: {"email": email});
  }

  @override
  Future<VerificationStatus> confirmEmailCode({
    required String email,
    required String code,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      "/verification/email/confirm",
      data: {"email": email, "code": code},
    );
    return _fromJson(response.data!);
  }

  @override
  Future<void> sendPhoneCode({required String phoneNumber}) async {
    await _client.post("/verification/phone/send", data: {"phoneNumber": phoneNumber});
  }

  @override
  Future<VerificationStatus> confirmPhoneCode({
    required String phoneNumber,
    required String code,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      "/verification/phone/confirm",
      data: {"phoneNumber": phoneNumber, "code": code},
    );
    return _fromJson(response.data!);
  }

  @override
  Future<VerificationStatus> submitNationalDocument({
    required String frontImageUrl,
    String? backImageUrl,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      "/verification/documents/national",
      data: {"frontImageUrl": frontImageUrl, "backImageUrl": backImageUrl},
    );
    return _fromJson(response.data!);
  }

  @override
  Future<VerificationStatus> submitInternationalDocument({
    required String passportImageUrl,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      "/verification/documents/international",
      data: {"passportImageUrl": passportImageUrl},
    );
    return _fromJson(response.data!);
  }

  @override
  Future<VerificationStatus> submitFullAccessRequest({
    required FullAccessRequestType type,
    String? note,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      "/verification/full-access-request",
      data: {"type": type.name, "note": note},
    );
    return _fromJson(response.data!);
  }
}
