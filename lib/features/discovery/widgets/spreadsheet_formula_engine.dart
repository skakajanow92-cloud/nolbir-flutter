import 'dart:math' as math;

/// Sütun indeksini ("A", "B", ..., "Z", "AA"...) harfe çevirir.
String columnLabel(int col) {
  var c = col + 1;
  var label = '';
  while (c > 0) {
    final rem = (c - 1) % 26;
    label = String.fromCharCode('A'.codeUnitAt(0) + rem) + label;
    c = (c - 1) ~/ 26;
  }
  return label;
}

String cellRefLabel(int row, int col) => '${columnLabel(col)}${row + 1}';

({int row, int col})? parseCellRef(String ref) {
  final match = RegExp(r'^([A-Z]+)([0-9]+)$').firstMatch(ref);
  if (match == null) return null;
  final colLetters = match.group(1)!;
  final rowNumber = int.parse(match.group(2)!);
  var col = 0;
  for (final char in colLetters.codeUnits) {
    col = col * 26 + (char - 'A'.codeUnitAt(0) + 1);
  }
  return (row: rowNumber - 1, col: col - 1);
}

/// Hücre girişini değerlendirir. "=" ile başlamıyorsa olduğu gibi döner.
/// `depth`, dairesel referanslara karşı bir güvenlik sınırı — bir hücre
/// kendini (doğrudan ya da zincirleme) referans alırsa sonsuz
/// özyinelemeye girmek yerine "#DÖNGÜ" döner.
String evaluateCell(
  List<List<String>> grid,
  int row,
  int col, {
  int depth = 0,
}) {
  if (row < 0 || row >= grid.length || col < 0 || col >= grid[row].length) {
    return "";
  }
  final raw = grid[row][col].trim();
  if (!raw.startsWith('=')) return raw;
  if (depth > 20) return "#DÖNGÜ";

  final expr = raw.substring(1).trim().toUpperCase();

  final funcMatch = RegExp(
    r'^(SUM|AVERAGE|COUNT|MAX|MIN)\(([A-Z]+[0-9]+):([A-Z]+[0-9]+)\)$',
  ).firstMatch(expr);
  if (funcMatch != null) {
    final fn = funcMatch.group(1)!;
    final start = parseCellRef(funcMatch.group(2)!);
    final end = parseCellRef(funcMatch.group(3)!);
    if (start == null || end == null) return "#REF";
    final values = <double>[];
    for (var r = start.row; r <= end.row; r++) {
      for (var c = start.col; c <= end.col; c++) {
        final v = double.tryParse(evaluateCell(grid, r, c, depth: depth + 1));
        if (v != null) values.add(v);
      }
    }
    if (values.isEmpty) return "0";
    switch (fn) {
      case "SUM":
        return _formatNumber(values.reduce((a, b) => a + b));
      case "AVERAGE":
        return _formatNumber(values.reduce((a, b) => a + b) / values.length);
      case "COUNT":
        return values.length.toString();
      case "MAX":
        return _formatNumber(values.reduce(math.max));
      default: // MIN
        return _formatNumber(values.reduce(math.min));
    }
  }

  // Basit aritmetik: hücre referanslarını sayısal değerleriyle değiştirip
  // küçük bir ifade çözümleyiciyle hesapla.
  final substituted = expr.replaceAllMapped(RegExp(r'[A-Z]+[0-9]+'), (m) {
    final ref = parseCellRef(m.group(0)!);
    if (ref == null) return "0";
    final v = double.tryParse(
      evaluateCell(grid, ref.row, ref.col, depth: depth + 1),
    );
    return (v ?? 0).toString();
  });

  final result = _evaluateArithmetic(substituted);
  return result == null ? "#HATA" : _formatNumber(result);
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2);
}

/// Çok küçük, parantez/+-*/ destekleyen bir özyinelemeli-iniş
/// değerlendirici. Gerçek bir ifade kütüphanesi değil — bu kartın mock
/// hesaplama ihtiyacı için bilinçli olarak minimal.
double? _evaluateArithmetic(String expr) {
  final clean = expr.replaceAll(' ', '');
  var pos = 0;

  // Üçü birbirini çağırdığı (parseExpr -> parseTerm -> parseFactor ->
  // parseExpr) için bu bir DÖNGÜ oluşturuyor — hangi sırada yazılırsa
  // yazılsın en az biri kendinden sonra gelen bir fonksiyonu çağırmak
  // zorunda kalıyor, bu da Dart'ta "referenced before declaration"
  // hatası veriyor. Çözüm: önce `late` değişkenler olarak bildirip,
  // gövdelerini sonra atamak — referans artık bildirimden SONRA (sadece
  // atamadan önce), closure'lar da değeri ancak çağrıldıklarında
  // okuduğu için (o an üçü de atanmış olacak) sorun kalmıyor.
  late double? Function() parseExpr;
  late double? Function() parseTerm;
  late double? Function() parseFactor;

  parseFactor = () {
    if (pos >= clean.length) return null;
    if (clean[pos] == '(') {
      pos++;
      final value = parseExpr();
      if (value == null || pos >= clean.length || clean[pos] != ')') {
        return null;
      }
      pos++;
      return value;
    }
    final match = RegExp(r'^-?[0-9]+(\.[0-9]+)?').matchAsPrefix(clean, pos);
    if (match == null) return null;
    pos = match.end;
    return double.tryParse(match.group(0)!);
  };

  parseTerm = () {
    var value = parseFactor();
    if (value == null) return null;
    while (pos < clean.length && (clean[pos] == '*' || clean[pos] == '/')) {
      final op = clean[pos];
      pos++;
      final rhs = parseFactor();
      if (rhs == null) return null;
      if (op == '/' && rhs == 0) return null;
      value = op == '*' ? value! * rhs : value! / rhs;
    }
    return value;
  };

  parseExpr = () {
    var value = parseTerm();
    if (value == null) return null;
    while (pos < clean.length && (clean[pos] == '+' || clean[pos] == '-')) {
      final op = clean[pos];
      pos++;
      final rhs = parseTerm();
      if (rhs == null) return null;
      value = op == '+' ? value! + rhs : value! - rhs;
    }
    return value;
  };

  final result = parseExpr();
  if (result == null || pos != clean.length) return null;
  return result;
}
