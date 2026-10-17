/// Projenin paylaşılan biçimlendirme yardımcıları (TR gösterimi: binlik
/// ayracı nokta, ondalık ayracı virgül). Kart view dosyalarındaki özel
/// `_formatDate` / `_formatMoney` kopyalarının ortak karşılığı — yeni kod
/// bunları kullanır, eski view'lar sırası geldikçe buraya taşınabilir.

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';

String formatDateTime(DateTime d) =>
    '${formatDate(d)} · ${_two(d.hour)}:${_two(d.minute)}';

String formatMonth(DateTime d) {
  const months = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];
  return '${months[d.month - 1]} ${d.year}';
}

String formatInt(int value) => formatMoney(value.toDouble());

String formatMoney(double value, {int decimals = 0}) {
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  if (parts.length > 1) buffer.write(',${parts[1]}');
  return buffer.toString();
}

/// Ay sayısını "2 yıl 3 ay" biçiminde yazar.
String formatDuration(int months) {
  if (months <= 0) return '1 aydan az';
  final years = months ~/ 12;
  final rest = months % 12;
  if (years == 0) return '$rest ay';
  if (rest == 0) return '$years yıl';
  return '$years yıl $rest ay';
}

/// Süreyi video/parça uzunluğu gibi "4:05" ya da "1:02:09" biçiminde yazar.
String formatClock(Duration d) {
  final seconds = d.inSeconds % 60;
  if (d.inHours > 0) {
    return '${d.inHours}:${_two(d.inMinutes % 60)}:${_two(seconds)}';
  }
  return '${d.inMinutes}:${_two(seconds)}';
}
