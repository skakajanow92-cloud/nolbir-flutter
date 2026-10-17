import 'package:flutter/material.dart';

/// Zaman çizelgesindeki tek bir kayıt.
class DetailTimelineEntry {
  final String title;
  final String? subtitle;
  final String? caption;

  const DetailTimelineEntry({required this.title, this.subtitle, this.caption});
}

/// Dikey zaman çizelgesi — kargo takip geçmişi gibi sıralı olay listeleri
/// için. Listenin SON kaydı "güncel" kabul edilir ve vurgulanır; kayıtlar
/// eskiden yeniye sıralı verilmelidir.
class DetailTimeline extends StatelessWidget {
  final List<DetailTimelineEntry> entries;
  final Color accent;

  const DetailTimeline({super.key, required this.entries, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(
            entry: entries[i],
            isLast: i == entries.length - 1,
            accent: accent,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final DetailTimelineEntry entry;
  final bool isLast;
  final Color accent;

  const _TimelineRow({
    required this.entry,
    required this.isLast,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor =
        isLast ? (Color.lerp(accent, Colors.white, 0.55) ?? accent) : Colors.white24;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 12,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.white12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      color: isLast ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: isLast ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  if (entry.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(entry.subtitle!,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ),
                  if (entry.caption != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(entry.caption!,
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
