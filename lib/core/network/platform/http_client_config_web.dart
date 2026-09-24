import 'package:dio/dio.dart';

/// Web'de sertifika bypass kavramı yok (tarayıcı kendi TLS'ini yönetir) —
/// no-op. `dart:io` burada YOK, bu yüzden web derlemesi sorunsuz geçer.
void configureDebugHttpClient(Dio dio) {}
