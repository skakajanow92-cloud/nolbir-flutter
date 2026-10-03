import '../feed_card/base.dart';
import 'ecommerce_product_card.dart';

/// Backend'in hazırladığı küçük bir ürün paketini (10-20 ürün) tek bir
/// feed sayfasında grid halinde sunan kart. Ürünler farklı mağazalardan,
/// farklı kategorilerden olabilir — ortak tema sadece `title` ile ifade
/// edilir (ör. "Bu haftanın fırsatları"). Her hücre, ayrı küçültülmüş bir
/// "özet" tipi yerine `EcommerceProductCard`'ın TAM veri modelini taşır
/// — böylece detay bottom sheet'i ek bir veri çekme/haritalama adımına
/// gerek kalmadan doğrudan açılabilir.
class ProductGridCard extends FeedCard {
  final String title;
  final String? subtitle;
  final List<EcommerceProductCard> products;

  const ProductGridCard({
    required String id,
    required this.title,
    required this.products,
    this.subtitle,
  }) : super(id);
}