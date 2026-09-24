import 'package:flutter/foundation.dart';

/// Backend adreslerinin TEK kaynağı.
///
/// NOT: Aşağıdaki IP/URL değerleri örnek/placeholder'dır — gerçek sunucu
/// adresleri belirlenince sadece burası güncellenir, `ApiClient`'a ya da
/// onu kullanan hiçbir repository'ye dokunulmaz.
class AppConfig {
  AppConfig._();

  // Debug modda aynı makinede çalışırken en stabil yol: localhost.
  // Fiziksel cihaz/release modda makinenin yerel ağ IP'si kullanılır.
  static const String _localIp = "192.168.1.110";

  static String get mainApiUrl =>
      kDebugMode ? "http://127.0.0.1:3000" : "http://$_localIp:3000";

  // İleride ikinci bir servis (ör. medya/CDN, AI, ödeme) eklendiğinde
  // buraya yeni bir getter eklemek yeterli — ApiClient tarafı değişmez.
  // static String get mediaApiUrl => ...
}
