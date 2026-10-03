//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Bir e-ticaret kartındaki seçili varyantları (beden/renk/...) tutar.
/// `card.id` ile anahtarlanır — PageView o kart widget'ını dispose edip
/// yeniden kursa bile (ör. sayfa yenilenmesi) seçim kaybolmaz, çünkü
/// state widget'ta değil burada, provider container'da yaşıyor.
final productVariantSelectionProvider =
    StateProvider.family<Map<String, String>, String>((ref, cardId) => {});