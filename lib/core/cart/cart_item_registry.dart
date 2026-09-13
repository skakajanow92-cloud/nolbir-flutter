import 'package:flutter/material.dart';
import '../../models/cart.dart';
import 'widgets/default_cart_item_tile.dart';

typedef CartItemViewBuilder = Widget Function(BuildContext context, CartItem item);

/// `card_factory.dart`'daki switch-case yaklaşımının aksine burada BİLEREK
/// bir registry (Map) kullanıldı: sepet türü sayısı büyük ve açık uçlu
/// olduğu için (kullanıcının listelediği 17+ tür, üstüne "aklıma gelmeyenler").
/// switch-case her yeni türde büyür ve merkezi dosyayı şişirirdi; registry
/// ise her feature kendi builder'ını kaydeder, merkezi dosyaya hiç dokunulmaz.
/// En önemlisi: kayıt YOKSA bile `DefaultCartItemTile` devreye girer —
/// yani "bugün bilmediğimiz" bir sepet türü bile otomatik çalışır.
class CartItemRegistry {
  CartItemRegistry._();

  static final Map<String, CartItemViewBuilder> _builders = {};

  /// Belirli bir sepet türü için özel bir satır görünümü kaydet.
  /// Örnek: eczane sepetindeki dozaj bilgisini göstermek için
  /// bkz. features/cart/widgets/pharmacy_cart_item_tile.dart
  static void register(CartType type, CartItemViewBuilder builder) {
    _builders[type.id] = builder;
  }

  static Widget build(BuildContext context, CartItem item) {
    final builder = _builders[item.cartType.id];
    if (builder != null) return builder(context, item);
    return DefaultCartItemTile(item: item); // fallback — kod değişikliği gerekmez
  }
}
