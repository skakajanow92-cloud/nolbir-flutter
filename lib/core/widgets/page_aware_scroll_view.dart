import 'package:flutter/material.dart';
import 'vertical_card_feed.dart';

/// Bir kartın içeriği tam ekrana sığmayıp taşma riski taşıdığında (ör.
/// Career/Food/Engagement modülleri), o içeriği doğrudan bir
/// `SingleChildScrollView` yerine BU widget'la sarmalıyoruz.
///
/// SORUN: `VerticalCardFeed`'deki dıştaki dikey `PageView` ile bu
/// widget'ın içindeki dikey scroll AYNI eksende iç içedir. Masaüstünde
/// (fare tekerleği) bu hiç sorun çıkarmaz — tekerlek olayı, iç scroll
/// sınırına (en üst/en alt) ulaşıldığında tüketilmeden doğal olarak
/// dışarı taşar ve sayfa kayar. Ama dokunmatik sürüklemede Flutter jesti
/// baştan en içteki Scrollable'a verir ve sınıra ulaşılsa bile aynı
/// jest ortasında dışarıya DEVREDİLMEZ — bu da mobilde "kart takılı
/// kalma" hissi yaratır.
///
/// ÇÖZÜM: İçerik zaten sınırındayken (en üstte/en altta) kullanıcı yine
/// de aynı yönde sürüklemeye devam ederse Flutter bunu bir
/// `OverscrollNotification` olarak yayınlar (bu, `ClampingScrollPhysics`
/// ile de — görsel bir "bounce" olmasa dahi — gerçekleşir; ör.
/// `RefreshIndicator` da aynı mekanizmaya dayanır). Bu widget o
/// bildirimi dinler ve jesti `VerticalFeedController` üzerinden dıştaki
/// `PageView`'a devredip bir sonraki/önceki karta yumuşak geçiş yaptırır.
/// Sınır İÇİNDEKİ her sürükleme ise normal şekilde sadece içeriği
/// kaydırır — dışarı hiç taşmaz.
///
/// DİKKAT (bkz. `_isOwnVerticalScroll`): `NotificationListener` ağaçtan
/// yukarı kabarcıklanan TÜM scroll bildirimlerini yakalar — bu kartların
/// içindeki yatay `ListView`'lar da kendi uçlarına geldiğinde
/// `OverscrollNotification` yayınlar. Filtrelenmezse, kullanıcı yatay bir
/// listeyi sağa/sola kaydırıp ucuna geldiğinde kart DEĞİŞİR; bu istenen
/// davranış değildir. Bu yüzden sadece (1) dikey eksenli ve (2) doğrudan
/// bu widget'ın kendi Scrollable'ından gelen (depth == 0) bildirimleri
/// dikkate alıyoruz.
class PageAwareScrollView extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PageAwareScrollView({super.key, required this.child, this.padding});

  @override
  State<PageAwareScrollView> createState() => _PageAwareScrollViewState();
}

class _PageAwareScrollViewState extends State<PageAwareScrollView> {
  // Aynı sürükleme jesti (parmak kalkana kadar) birden fazla
  // OverscrollNotification üretebilir — kart geçişini jest başına SADECE
  // BİR KEZ tetikleriz, yoksa bir sürüklemede birden fazla karta atlanır.
  bool _handoffTriggered = false;
  VerticalFeedController? _feedController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _feedController = VerticalFeedController.maybeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: SingleChildScrollView(
        padding: widget.padding,
        // Android'deki gibi "lastik" görsel taşması istemiyoruz — sınır
        // dışına taşan miktarı zaten kendimiz devralıp sayfa geçişine
        // dönüştürüyoruz.
        physics: const ClampingScrollPhysics(),
        child: widget.child,
      ),
    );
  }

  /// Bildirim gerçekten BU widget'ın kendi dikey scroll'undan mı geliyor?
  ///
  /// - `depth == 0`: doğrudan sarmaladığımız `SingleChildScrollView`'den
  ///   geliyor. İçerideki yatay listeler depth >= 1 ile gelir.
  /// - `axis == Axis.vertical`: yatay bir listenin ucuna gelmek kart
  ///   geçişini ASLA tetiklememeli.
  ///
  /// İkisi de tek başına yeterli görünse de bilinçli olarak ikisini
  /// birden kontrol ediyoruz: ileride bu widget'ın içine iç içe dikey bir
  /// liste konursa (depth filtresi onu eler) ya da doğrudan çocuk olarak
  /// yatay bir yapı gelirse (eksen filtresi onu eler) davranış bozulmasın.
  bool _isOwnVerticalScroll(ScrollNotification notification) {
    return notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical;
  }

  bool _handleNotification(ScrollNotification notification) {
    if (!_isOwnVerticalScroll(notification)) {
      // İçerideki yatay listelerden (favori mekanlar, iş deneyimleri,
      // referanslar...) gelen bildirimler — bunlara hiç karışma, normal
      // kabarcıklanmalarına izin ver.
      return false;
    }

    if (notification is OverscrollNotification) {
      _maybeHandoff(notification.overscroll);
    } else if (notification is ScrollEndNotification) {
      // Parmak kalktı / jest bitti — bir sonraki sürükleme için sıfırla.
      _handoffTriggered = false;
    }
    // false: bildirimi yutma, normal kabarcıklanmaya (ör. Scrollbar,
    // RefreshIndicator gibi başka dinleyicilere) izin ver.
    return false;
  }

  void _maybeHandoff(double overscroll) {
    if (_handoffTriggered || overscroll == 0) return;
    final feedController = _feedController;
    if (feedController == null) {
      return; // bu widget bir feed içinde değilse dokunma
    }

    _handoffTriggered = true;
    if (overscroll > 0) {
      // İçerik zaten en altta, kullanıcı yukarı doğru sürüklemeye devam
      // ediyor -> bir sonraki karta geç.
      feedController.nextPage();
    } else {
      // İçerik zaten en üstte, kullanıcı aşağı doğru sürüklemeye devam
      // ediyor -> bir önceki karta dön.
      feedController.previousPage();
    }
  }
}
