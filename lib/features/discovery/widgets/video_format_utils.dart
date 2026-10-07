import 'dart:math';

String formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  if (hours > 0) {
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
  return "$minutes:${seconds.toString().padLeft(2, '0')}";
}

String formatCompactCount(int count) {
  if (count >= 1000000) return "${(count / 1000000).toStringAsFixed(1)} Mn";
  if (count >= 1000) return "${(count / 1000).toStringAsFixed(1)} B";
  return "$count";
}

String formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 365) return "${(diff.inDays / 365).floor()} yıl önce";
  if (diff.inDays >= 30) return "${(diff.inDays / 30).floor()} ay önce";
  if (diff.inDays >= 1) return "${diff.inDays} gün önce";
  if (diff.inHours >= 1) return "${diff.inHours} saat önce";
  return "${max(1, diff.inMinutes)} dakika önce";
}
