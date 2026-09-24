import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// SADECE bu dosya `dart:io` içe aktarır. `api_client.dart` buraya
/// conditional import ile bağlanır — web derlemesi bu dosyayı hiç görmez.
void configureDebugHttpClient(Dio dio) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
}
