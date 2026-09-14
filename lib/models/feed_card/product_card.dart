import '../cart.dart';
import 'base.dart';

class ProductCard extends FeedCard implements Collectible {
  final String title;
  final String imageUrl;
  final double price;
  final String currency;

  /// "Sepete ekle" basılınca hangi sepete gideceğini belirler.
  final CartType cartType;

  const ProductCard({
    required String id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.currency = "TRY",
    this.cartType = CartType.market,
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (title, imageUrl);
}
