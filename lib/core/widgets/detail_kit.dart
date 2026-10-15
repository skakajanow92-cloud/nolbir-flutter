import 'package:flutter/material.dart';

/// Detay panelinin (ve ileride benzer "bilgi satırı" ihtiyaçlarının) ortak
/// yapı taşları — koyu tema paletine bağlı. Kart view'larındaki
/// `_SectionLabel` / `_EmptyHint` / `_DetailRow` kopyalarının tek yerdeki
/// karşılığıdır.

Color _soft(Color c) => Color.lerp(c, Colors.white, 0.55) ?? c;

/// Panelin tam sayfa iskeleti: başlık bloğu + kaydırılabilir içerik.
class DetailPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accent;
  final List<Widget> children;

  const DetailPage({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    this.subtitle,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Birincil scroll controller'a bağlanmasın (mobilde dikey kaydırmalar
      // otomatik olarak ona bağlanır; panelin kendi bağımsız scroll'u olsun).
      primary: false,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        subtitle!,
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        ...children,
      ],
    );
  }
}

/// Başlıklı bölüm. `spacing: 0` satır grupları (DetailRow) için, varsayılan
/// değer kutu/kart listeleri (DetailItem) için.
class DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double spacing;

  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0 && spacing > 0) SizedBox(height: spacing),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Modül renginde tonlanmış kutu — bir poliçe, bilet, rezervasyon, iş
/// deneyimi gibi tek bir varlığı gösterir.
class DetailItem extends StatelessWidget {
  final Color accent;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final List<Widget> rows;
  final Widget? footer;

  const DetailItem({
    super.key,
    required this.accent,
    required this.title,
    this.icon,
    this.subtitle,
    this.badge,
    this.rows = const [],
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 18, color: _soft(accent)),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              if (badge != null) ...[const SizedBox(width: 8), badge!],
            ],
          ),
          if (rows.isNotEmpty) ...[const SizedBox(height: 10), ...rows],
          if (footer != null) ...[const SizedBox(height: 10), footer!],
        ],
      ),
    );
  }
}

/// Etiket — değer satırı.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.white,
                fontSize: emphasize ? 15 : 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBadge extends StatelessWidget {
  final String label;
  final Color color;

  const DetailBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// İlerleme çubuğu (kredi kartı kullanımı, damga, yetenek seviyesi...).
class DetailProgress extends StatelessWidget {
  final double value;
  final String? label;
  final String? caption;
  final Color color;

  const DetailProgress({
    super.key,
    required this.value,
    this.label,
    this.caption,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null || caption != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                Text(caption ?? '',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              minHeight: 5,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailChips extends StatelessWidget {
  final List<String> labels;
  final Color accent;

  const DetailChips({super.key, required this.labels, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final l in labels)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Text(l,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
      ],
    );
  }
}

class DetailParagraph extends StatelessWidget {
  final String text;

  const DetailParagraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
      ),
    );
  }
}

class DetailEmpty extends StatelessWidget {
  final String text;

  const DetailEmpty(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(color: Colors.white38, fontSize: 13));
  }
}
