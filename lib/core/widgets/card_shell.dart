import 'package:flutter/material.dart';

/// Her feed kartının ortak dış çerçevesi.
/// Arka plan (video/görsel/renk), üstte içerik, sağ altta aksiyon butonları,
/// alt kısımda başlık/açıklama alanı — bunların hepsi burada standartlaşır.
/// Kart tipleri (VideoCardView, ProductCardView, ...) sadece `background`
/// ve `actions` gibi slotları doldurur.
class CardShell extends StatelessWidget {
  final Widget background;
  final Widget? bottomContent;
  final List<Widget> actions;
  final Widget? topContent;

  const CardShell({
    super.key,
    required this.background,
    this.bottomContent,
    this.actions = const [],
    this.topContent,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan katmanı (video, resim, gradient vs.)
          Positioned.fill(child: background),

          // Üst içerik (opsiyonel: kullanıcı bilgisi, başlık vb.)
          if (topContent != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: topContent!,
            ),

          // Sağ alt: aksiyon butonları (beğen, sepete ekle, kaydet vb.)
          if (actions.isNotEmpty)
            Positioned(
              right: 12,
              bottom: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: actions
                    .map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: a,
                        ))
                    .toList(),
              ),
            ),

          // Alt bilgi alanı (kullanıcı adı, açıklama, fiyat vb.)
          if (bottomContent != null)
            Positioned(
              left: 16,
              right: 90,
              bottom: 32,
              child: bottomContent!,
            ),
        ],
      ),
    );
  }
}

/// Aksiyon butonları için ortak, tekrar kullanılabilir buton.
class CardActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color? color;

  const CardActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 32),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
