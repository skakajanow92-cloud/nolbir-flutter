import 'package:dio/dio.dart';

/// `ApiClient`'ın fırlattığı, kullanıcıya gösterilebilir okunur mesaj
/// taşıyan hata. Repository/provider katmanı artık Dio'nun kendi hata
/// tipleriyle değil bu tek sınıfla uğraşır.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException("Sunucuya bağlanılamadı (zaman aşımı).");
      case DioExceptionType.badResponse:
        return ApiException(
          "Sunucu hatası: ${error.response?.statusCode}",
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.connectionError:
        return const ApiException("İnternet bağlantınızı kontrol edin.");
      case DioExceptionType.cancel:
        return const ApiException("İstek iptal edildi.");
      default:
        return const ApiException("Beklenmedik bir hata oluştu.");
    }
  }

  @override
  String toString() => message;
}
