// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cartRepository)
final cartRepositoryProvider = CartRepositoryProvider._();

final class CartRepositoryProvider
    extends $FunctionalProvider<CartRepository, CartRepository, CartRepository>
    with $Provider<CartRepository> {
  CartRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cartRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartRepositoryHash();

  @$internal
  @override
  $ProviderElement<CartRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CartRepository create(Ref ref) {
    return cartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartRepository>(value),
    );
  }
}

String _$cartRepositoryHash() => r'9a12a025a3fd0e93fe026373bfb043fbbd18c7aa';

/// Profil akışında gösterilecek sepet özetleri (dolu olan tüm sepetler).

@ProviderFor(allCarts)
final allCartsProvider = AllCartsProvider._();

/// Profil akışında gösterilecek sepet özetleri (dolu olan tüm sepetler).

final class AllCartsProvider extends $FunctionalProvider<AsyncValue<List<Cart>>,
        List<Cart>, FutureOr<List<Cart>>>
    with $FutureModifier<List<Cart>>, $FutureProvider<List<Cart>> {
  /// Profil akışında gösterilecek sepet özetleri (dolu olan tüm sepetler).
  AllCartsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allCartsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allCartsHash();

  @$internal
  @override
  $FutureProviderElement<List<Cart>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Cart>> create(Ref ref) {
    return allCarts(ref);
  }
}

String _$allCartsHash() => r'4d764b6b2a68b7b7138290f9f29979ccfc7ec97f';

/// Tek bir sepetin (örn. sadece market ya da sadece eczane) detay state'i.
/// `family` olduğu için her `CartType` kendi bağımsız state'ine sahip —
/// market sepetini güncellemek eczane sepetini yeniden yüklemez.

@ProviderFor(CartDetail)
final cartDetailProvider = CartDetailFamily._();

/// Tek bir sepetin (örn. sadece market ya da sadece eczane) detay state'i.
/// `family` olduğu için her `CartType` kendi bağımsız state'ine sahip —
/// market sepetini güncellemek eczane sepetini yeniden yüklemez.
final class CartDetailProvider
    extends $AsyncNotifierProvider<CartDetail, Cart> {
  /// Tek bir sepetin (örn. sadece market ya da sadece eczane) detay state'i.
  /// `family` olduğu için her `CartType` kendi bağımsız state'ine sahip —
  /// market sepetini güncellemek eczane sepetini yeniden yüklemez.
  CartDetailProvider._(
      {required CartDetailFamily super.from, required CartType super.argument})
      : super(
          retry: null,
          name: r'cartDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartDetailHash();

  @override
  String toString() {
    return r'cartDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CartDetail create() => CartDetail();

  @override
  bool operator ==(Object other) {
    return other is CartDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cartDetailHash() => r'dd28a45a14f7a57fb7852cdc46cf56b0f1c85002';

/// Tek bir sepetin (örn. sadece market ya da sadece eczane) detay state'i.
/// `family` olduğu için her `CartType` kendi bağımsız state'ine sahip —
/// market sepetini güncellemek eczane sepetini yeniden yüklemez.

final class CartDetailFamily extends $Family
    with
        $ClassFamilyOverride<CartDetail, AsyncValue<Cart>, Cart, FutureOr<Cart>,
            CartType> {
  CartDetailFamily._()
      : super(
          retry: null,
          name: r'cartDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Tek bir sepetin (örn. sadece market ya da sadece eczane) detay state'i.
  /// `family` olduğu için her `CartType` kendi bağımsız state'ine sahip —
  /// market sepetini güncellemek eczane sepetini yeniden yüklemez.

  CartDetailProvider call(
    CartType type,
  ) =>
      CartDetailProvider._(argument: type, from: this);

  @override
  String toString() => r'cartDetailProvider';
}

/// Tek bir sepetin (örn. sadece market ya da sadece eczane) detay state'i.
/// `family` olduğu için her `CartType` kendi bağımsız state'ine sahip —
/// market sepetini güncellemek eczane sepetini yeniden yüklemez.

abstract class _$CartDetail extends $AsyncNotifier<Cart> {
  late final _$args = ref.$arg as CartType;
  CartType get type => _$args;

  FutureOr<Cart> build(
    CartType type,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Cart>, Cart>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Cart>, Cart>,
        AsyncValue<Cart>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
