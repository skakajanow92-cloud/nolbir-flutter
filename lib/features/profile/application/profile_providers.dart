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

    // Kullanıcının dolu her sepeti (market, eczane, bilet, sigorta ...)
    // profil akışına birer CartSummaryCard olarak ekleniyor. `allCartsProvider`
    // izlendiği için herhangi bir sepete ekleme yapıldığında (discovery
    // tab'ından "Sepete ekle") bu liste otomatik güncellenir — manuel
    // refresh gerekmez.
    final carts = await ref.watch(allCartsProvider.future);
    final cartCards = carts
        .map((cart) => CartSummaryCard(
              id: "cart_${cart.cartType.id}",
              cartType: cart.cartType,
              itemCount: cart.itemCount,
              subtotal: cart.subtotal,
            ))
        .toList();

    // Sıralama: profil başlığı -> sepetler -> paylaşımlar
    final header = posts.whereType<ProfileHeaderCard>();
    final otherPosts = posts.where((c) => c is! ProfileHeaderCard);

    return [...header, ...cartCards, ...otherPosts];
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// CreatePostSheet'ten (kamera/galeri/dosya) seçilen medyayı yeni bir
  /// paylaşım kartı olarak profile ekler.
  Future<void> addPost(FeedCard post) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.addPost(post);
    final current = state.value ?? [];
    state = AsyncData([...current, post]);
  }
}
