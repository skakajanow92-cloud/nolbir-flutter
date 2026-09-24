import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_auth_context.dart';
import 'api_exception.dart';
import 'app_config.dart';
import 'platform/http_client_config_io.dart'
    if (dart.library.html) 'platform/http_client_config_web.dart' as platform;

/// Uygulama genelinde TÜM API çıkışlarının aktığı TEK merkezi nokta.
///
/// BİLİNÇLİ TASARIM KARARI: her repository kendi Dio örneğini kurmaz —
/// aynı `baseUrl` için TEK bir `ApiClient` (multiton) paylaşılır; JWT
/// ekleme, hata loglama, timeout gibi ortak davranış burada tek yerde
/// tanımlanır. `CartRepository`/`ProfileRepository` gibi repository'ler
/// bugün mock, gerçek API'ye geçerken hepsi bu sınıfın metotlarını
/// çağıracak — backend entegrasyonu her repository'de ayrı ayrı
/// tekrarlanmaz (bkz. `core/media/media_uploader.dart` -> `DioMediaUploader`,
/// bu ilkenin ilk somut örneği).
///
/// [isolationKey] verilirse (ör. bir stüdyo paketinin/modülün kendi
/// kimliği), bu URL için ana uygulamadan TAMAMEN AYRI, kimlik bilgisi
/// EKLENMEYEN bir Dio örneği oluşturulur/döndürülür — Nolbir'in stüdyo/
/// paket mimarisinde izole bir modülün, ana kullanıcının JWT'sini
/// kullanarak ana sunucuya (ya da başka bir yere) istek atmasını
/// engellemek için. Aynı `isolationKey` ile tekrar çağrıldığında aynı
/// örnek yeniden kullanılır (multiton); ana uygulamanın izolasyonsuz
/// örneğiyle asla karışmaz.
class ApiClient {
  static final Map<String, ApiClient> _instances = {};

  final Dio dio;
  final String baseUrl;
  final bool isSandboxed;
  final String _instanceKey;

  ApiClient._internal(
    this.baseUrl,
    this._instanceKey,
    this.dio, {
    this.isSandboxed = false,
  });

  factory ApiClient({required String baseUrl, String? isolationKey}) {
    final bool sandboxed = isolationKey != null && isolationKey.isNotEmpty;
    final String key = sandboxed ? '$baseUrl::sandbox::$isolationKey' : baseUrl;

    final cached = _instances[key];
    if (cached != null) return cached;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // DEBUG modda sertifika kontrolünü esnet (yerel geliştirme, ör.
    // Windows'ta self-signed sertifika ile test). Gerçek implementasyon
    // platform/http_client_config_io.dart'ta (dart:io) — web'de no-op
    // (platform/http_client_config_web.dart) çalışır, bu yüzden ayrı bir
    // kIsWeb kontrolüne gerek yok.
    if (kDebugMode) {
      platform.configureDebugHttpClient(dio);
    }

    final instance =
        ApiClient._internal(baseUrl, key, dio, isSandboxed: sandboxed);
    instance._setupInterceptors();
    _instances[key] = instance;
    return instance;
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!isSandboxed) {
            final token = ApiAuthContext.token;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            options.headers.addAll(ApiAuthContext.extraHeaders);
          } else if (kDebugMode) {
            debugPrint(
              "🔒 [sandbox] '$_instanceKey' -> izole istek, kimlik bilgisi eklenmedi.",
            );
          }
          if (kDebugMode) {
            debugPrint("🚀 İstek: ${options.method} -> ${options.uri}");
          }
          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException error, handler) {
          if (kDebugMode) {
            debugPrint(
              "❌ ${ApiException.fromDio(error).message}: ${error.response?.data}",
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  // --- CRUD ---

  Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    Options? options,
  }) =>
      _run(() => dio.get<T>(endpoint, queryParameters: query, options: options));

  Future<Response<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) =>
      _run(() => dio.post<T>(endpoint,
          data: data, queryParameters: query, options: options));

  Future<Response<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) =>
      _run(() => dio.put<T>(endpoint,
          data: data, queryParameters: query, options: options));

  Future<Response<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) =>
      _run(() => dio.patch<T>(endpoint,
          data: data, queryParameters: query, options: options));

  Future<Response<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    Options? options,
  }) =>
      _run(() =>
          dio.delete<T>(endpoint, queryParameters: query, options: options));

  // --- DOSYA İŞLEMLERİ ---
  // BİLİNÇLİ TASARIM KARARI: `File` (dart:io) değil `Uint8List bytes`
  // alır/döner. `MultipartFile.fromBytes` ve response'u bytes olarak okumak
  // TÜM platformlarda (web dahil) çalışır — bu iki metot için AYRI bir
  // platform dosyasına bile gerek kalmıyor. Baytları diske yazmak (native)
  // ya da IndexedDB'ye koymak (web) `MediaService`in/`LocalMediaStorage`ın
  // işi — network katmanı sadece veri taşır, nereye kalıcı olacağına
  // karışmaz.

  Future<Response> uploadFile(
    String endpoint, {
    required Uint8List bytes,
    required String fileName,
    String fieldName = "file",
    Map<String, dynamic>? extraFields,
    void Function(int sent, int total)? onSendProgress,
  }) {
    return _run(() async {
      final formData = FormData.fromMap({
        ...?extraFields,
        fieldName: MultipartFile.fromBytes(bytes, filename: fileName),
      });
      return dio.post(endpoint, data: formData, onSendProgress: onSendProgress);
    });
  }

  Future<Uint8List> downloadBytes(
    String url, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final response = await _run(
      () => dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      ),
    );
    return Uint8List.fromList(response.data!);
  }

  /// Ham `DioException`'ı okunur `ApiException`'a çevirip fırlatır —
  /// çağıran taraf artık Dio'nun kendi hata tiplerini bilmek zorunda değil.
  Future<R> _run<R>(Future<R> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // --- KOLAY ERİŞİM ---
  static ApiClient get main => ApiClient(baseUrl: AppConfig.mainApiUrl);

  void close({bool force = false}) {
    dio.close(force: force);
    _instances.remove(_instanceKey);
  }
}
