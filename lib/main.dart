import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'app/main_scaffold.dart';

void main() {
  // media_kit'in native video motorunu (mpv tabanlı) başlatır.
  // Player()/VideoController oluşturmadan önce mutlaka çağrılmalı.
  MediaKit.ensureInitialized();
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
      home: const MainScaffold(),
    );
  }
}
