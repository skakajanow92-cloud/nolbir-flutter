import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'app/main_scaffold.dart';
import 'app/card_registrations.dart';
import 'windows_material_scroll.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  registerAllCardViews(); // tüm kart görünümlerini burada, tek seferde kaydet

  _enableImmersiveFullScreen();

  runApp(const ProviderScope(child: MyApp()));
}

/// Android'de üstteki durum çubuğunu (saat/batarya/sinyal) ve alttaki
/// gezinme çubuğunu (geri/ana ekran/son uygulamalar tuşları) tamamen
/// arka plana alıp oyunlardaki gibi tam ekran kaplamayı sağlar.
///
/// `immersiveSticky`: çubuklar tamamen gizlenir; kullanıcı kenardan içeri
/// kaydırırsa yarı saydam olarak geçici görünür, kısa süre sonra kendiliğinden
/// tekrar gizlenir (oyun/medya uygulamalarının kullandığı mod). iOS'ta bu
/// çağrının bir etkisi yok — iOS'ta tam ekran farklı ele alınır, şimdilik
/// kapsam dışı bırakıldı.
void _enableImmersiveFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Uygulama arka plandan öne döndüğünde (resume) Android bazen sistem
  // çubuklarını tekrar gösterir — bu yüzden her lifecycle değişiminde
  // immersive modu yeniden uyguluyoruz.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enableImmersiveFullScreen();
    }
  }

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
