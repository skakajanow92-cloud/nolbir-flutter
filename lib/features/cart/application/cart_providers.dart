import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../models/cart.dart';

part 'cart_providers.g.dart';

@riverpod
CartRepository cartRepository(Ref ref) {
  return MockCartRepository();
}

/// Profil akışında gösterilecek sepet özetleri (dolu olan tüm sepetler).
@riverpod
Future<List<Cart>> allCarts(Ref ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return repo.fetchAllCarts();
}

/// Tek bir sepetin (örn. sadece market ya da sadece eczane) detay state'i.
/// `family` olduğu için her `CartType` kendi bağımsız state'ine sahip —
/// market sepetini güncellemek eczane sepetini yeniden yüklemez.
@riverpod
class CartDetail extends _$CartDetail {
  @override
  Future<Cart> build(CartType type) async {
    final repo = ref.watch(cartRepositoryProvider);
    return repo.fetchCart(type);
  }

  Future<void> addItem(CartItem item) async {
    final repo = ref.read(cartRepositoryProvider);
    await repo.addItem(type, item);
    await _reload();
    ref.invalidate(allCartsProvider); // profildeki sepet özetleri de güncellensin
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final repo = ref.read(cartRepositoryProvider);
    await repo.updateQuantity(type, itemId, quantity);
    await _reload();
    ref.invalidate(allCartsProvider);
  }

  Future<void> removeItem(String itemId) async {
    final repo = ref.read(cartRepositoryProvider);
    await repo.removeItem(type, itemId);
    await _reload();
    ref.invalidate(allCartsProvider);
  }

  Future<void> _reload() async {
    final repo = ref.read(cartRepositoryProvider);
    state = AsyncData(await repo.fetchCart(type));
  }
}
