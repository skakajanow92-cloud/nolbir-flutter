import 'dart:ui' show Size;

/// Uygulamanın üç yerleşim modu.
enum ShellMode {
  /// Telefon / dar pencere: tam ekran feed + alttaki tab çubuğu (eski davranış).
  compact,

  /// Orta genişlik: yan NavigationRail + ortalanmış, telefon genişliğinde feed.
  rail,

  /// Geniş masaüstü: rail + feed + aktif karta bağlı detay paneli.
  railWithDetail,
}

/// Yerleşim sabitleri ve mod seçimi — tüm eşikler tek yerde.
abstract final class AppLayout {
  /// Geniş ekranlarda feed sütununun genişliği (telefon simülasyonu).
  static const double feedColumnWidth = 430;

  /// Bu genişliğin altı: compact (alt tab çubuğu, tam ekran feed).
  static const double railBreakpoint = 720;

  /// Bu genişlik ve üstü: feed'in yanında detay paneli de gösterilir.
  static const double detailBreakpoint = 1000;

  /// Pencere bundan kısaysa (ör. yatay tutulan telefon) geniş mod
  /// kullanılmaz — 430px genişliğinde, alçacık bir feed sütunu anlamsız olur.
  static const double minWideHeight = 480;

  static const double panelGap = 24;
  static const double outerPadding = 24;
  static const double detailMinWidth = 340;
  static const double detailMaxWidth = 520;

  static ShellMode modeFor(Size size) {
    if (size.width < railBreakpoint || size.height < minWideHeight) {
      return ShellMode.compact;
    }
    if (size.width < detailBreakpoint) return ShellMode.rail;
    return ShellMode.railWithDetail;
  }
}
