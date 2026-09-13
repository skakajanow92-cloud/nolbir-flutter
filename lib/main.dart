import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'app/main_scaffold.dart';
import 'app/card_registrations.dart';
import 'windows_material_scroll.dart';

void main() {
  MediaKit.ensureInitialized();
  registerAllCardViews(); // tüm kart görünümlerini burada, tek seferde kaydet
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çok Görevli Akış Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      scrollBehavior: WindowsMaterialScrollBehavior(),
      home: const MainScaffold(),
    );
  }
}
