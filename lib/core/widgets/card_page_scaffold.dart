import 'package:flutter/material.dart';
import 'page_aware_scroll_view.dart';

/// Medya arka planlı olmayan, bilgi yoğun kartlar (banka ürünleri, profil
/// modülleri vb.) için ortak dış çerçeve: sabit üst `header` + kaydırılabilir
/// `body`. `CardShell`'in aksine sağda sabit bir aksiyon sütunu yok — bu tür
/// kartlarda aksiyonlar genelde gövde içinde, tam genişlikte butonlar.
class CardPageScaffold extends StatelessWidget {
  final Color baseColor;
  final Color baseEndColor;
  final Widget header;
  final Widget body;

  const CardPageScaffold({
    super.key,
    required this.baseColor,
    required this.baseEndColor,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [baseColor, baseEndColor],
          ),
        ),
        child: SafeArea(
          child: PageAwareScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: header,
                ),
                const SizedBox(height: 24),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardSectionLabel extends StatelessWidget {
  final String text;
  const CardSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}