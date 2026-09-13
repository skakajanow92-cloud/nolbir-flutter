import '../../models/cart.dart';

/// Sepet veri kaynağı sözleşmesi. Tek bir repository TÜM sepet türlerini
/// yönetiyor (market, eczane, bilet, sigorta...) çünkü işlemler (ekle,
/// miktar güncelle, çıkar, listele) her türde aynı şekilde çalışıyor —
/// fark sadece `CartType` parametresinde. Bu sayede 17+ tür için 17 ayrı
/// repository yazmak zorunda kalmıyoruz.
abstract class CartRepository {
  /// Kullanıcının dolu olan tüm sepetlerinin özetini getirir
  /// (profil akışında "Market Sepetin", "Eczane Sepetin" gibi kartlar için).
  Future<List<Cart>> fetchAllCarts();

  Future<Cart> fetchCart(CartType type);
  Future<void> addItem(CartType type, CartItem item);
  Future<void> updateQuantity(CartType type, String itemId, int quantity);
  Future<void> removeItem(CartType type, String itemId);
}

class MockCartRepository implements CartRepository {
  // Gerçek uygulamada her sepet türü muhtemelen farklı bir mikroservise/API'ye
  // gider; burada demo amaçlı tek bir bellek-içi map ile simüle ediliyor.
  final Map<String, List<CartItem>> _store = {
    CartType.market.id: [
      const CartItem(
          id: "m1", cartType: CartType.market, title: "Zeytinyağı 1L", price: 189.90),
      const CartItem(
          id: "m2", cartType: CartType.market, title: "Tam Buğday Ekmek", price: 24.50, quantity: 2),
    ],
    CartType.food.id: [
      const CartItem(
          id: "f1", cartType: CartType.food, title: "Karışık Pizza", price: 245.00),
    ],
    CartType.pharmacy.id: [
      const CartItem(
        id: "ph1",
        cartType: CartType.pharmacy,
        title: "Parol 500mg",
        price: 42.75,
        quantity: 1,
        metadata: {"dosage": "Günde 3 kez 1 tablet", "prescriptionRequired": false},
      ),
    ],
    CartType.subscription.id: [
      const CartItem(
          id: "sub1", cartType: CartType.subscription, title: "Premium Üyelik", price: 49.90),
    ],
  };

  @override
  Future<List<Cart>> fetchAllCarts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _store.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => Cart(cartType: CartType(e.key), items: List.unmodifiable(e.value)))
        .toList();
  }

  @override
  Future<Cart> fetchCart(CartType type) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final items = _store[type.id] ?? [];
    return Cart(cartType: type, items: List.unmodifiable(items));
  }

  @override
  Future<void> addItem(CartType type, CartItem item) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final items = _store.putIfAbsent(type.id, () => []);
    final existingIndex = items.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + item.quantity,
      );
    } else {
      items.add(item);
    }
  }

  @override
  Future<void> updateQuantity(CartType type, String itemId, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final items = _store[type.id];
    if (items == null) return;
    final index = items.indexWhere((i) => i.id == itemId);
    if (index < 0) return;
    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: quantity);
    }
  }

  @override
  Future<void> removeItem(CartType type, String itemId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _store[type.id]?.removeWhere((i) => i.id == itemId);
  }
}
