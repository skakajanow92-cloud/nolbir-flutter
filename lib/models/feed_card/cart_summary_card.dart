import '../cart.dart';
import 'base.dart';

/// Kullanıcının dolu her sepeti için profil akışında gösterilen özet kart.
class CartSummaryCard extends FeedCard implements Collectible {
  final CartType cartType;
  final int itemCount;
  final double subtotal;
  final String currency;

  const CartSummaryCard({
    required String id,
    required this.cartType,
    required this.itemCount,
    required this.subtotal,
    this.currency = "TRY",
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => ("Sepet", "");
}
