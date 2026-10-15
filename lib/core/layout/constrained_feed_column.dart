import 'package:flutter/material.dart';

/// Geniş ekranlarda feed'i telefon genişliğindeki sütuna oturtur.
///
/// Asıl daraltmayı sütunun SIKI kısıtları yapar (PageView sayfaları bu
/// kısıtlara göre boyutlanır). Ek olarak alt ağacın `MediaQuery.size`'ını da
/// sütunun gerçek ölçüsüyle değiştiriyoruz: kart view'larının çoğu
/// `MediaQuery.of(context).size` okuyor — bunu düzeltmezsek ekranın tamamını
/// (ör. 1920px) kendi ölçüsü sanıp yanlış hesap yapabilirler. Böylece tek
/// bir noktadan, hiçbir kart dosyasına dokunmadan tutarlılık sağlanır.
class ConstrainedFeedColumn extends StatelessWidget {
  final Widget child;

  const ConstrainedFeedColumn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Sütun kenarlarındaki ince çizgi: içeriğin ÜSTÜNE çizilir ki kartlar
      // örtmesin.
      position: DecorationPosition.foreground,
      decoration: const BoxDecoration(
        border: Border.symmetric(vertical: BorderSide(color: Colors.white10)),
      ),
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
