import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../models/feed_card.dart';
import '../../cart/application/cart_providers.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return MockProfileRepository();
}

/// Şu an sabit "mevcut kullanıcı" — auth katmanı eklenince
/// gerçek userId buradan (örn. authStateProvider) okunacak.
@riverpod
class ProfileFeed extends _$ProfileFeed {
  @override
  Future<List<FeedCard>> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final posts = await repo.fetchProfileFeed("current_user");

    final carts = await ref.watch(allCartsProvider.future);
    final cartCards = carts
        .map(
          (cart) => CartSummaryCard(
            id: "cart_${cart.cartType.id}",
            cartType: cart.cartType,
            itemCount: cart.itemCount,
            subtotal: cart.subtotal,
          ),
        )
        .toList();

    final header = posts.whereType<ProfileHeaderCard>();
    final otherPosts = posts.where((c) => c is! ProfileHeaderCard);

    return [...header, ...cartCards, ...otherPosts];
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> addPost(FeedCard post) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.addPost(post);
    final current = state.value ?? [];
    state = AsyncData([...current, post]);
  }

  /// "Temel Bilgiler" kartı düzenlendiğinde çağrılır.
  ///
  /// NOT (bilinçli, geçici tasarım kararı): Şu an sadece yerel state
  /// güncelleniyor — repository'ye persist etme (gerçek backend/API çağrısı)
  /// bilerek bu adıma dahil edilmedi. Görsel arayüzü tam teşekküllü
  /// tamamladıktan sonra buraya `repo.updateHeader(...)` gibi bir çağrı
  /// eklenecek; o zamana kadar düzenlemeler sayfa yenilenince (provider
  /// invalidate/refresh) kaybolur.
  void updateHeader(ProfileHeaderCard updated) {
    final current = state.value ?? [];
    state = AsyncData([
      for (final c in current) c is ProfileHeaderCard ? updated : c,
    ]);
  }
}
