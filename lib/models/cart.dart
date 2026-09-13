/// Sepet türü.
///
/// BİLİNÇLİ TASARIM KARARI: Bu bir Dart `enum` değil, string'i saran hafif bir
/// sınıf. Neden önemli: Market/eczane/bilet/sigorta/yatırım... gibi onlarca
/// (ve zamanla artacak, öngörülemeyen) sepet türü olacağını biliyoruz.
/// `enum` kullansaydık her yeni tür için TEK bir dosyayı (bu dosyayı)
/// değiştirmen gerekirdi — o kısım kaçınılmaz zaten. Ama asıl kazanç şurada:
/// aşağıdaki tüm sistem (repository, provider, kart görünümü, sepet detay
/// listesi) switch-case ile DEĞİL, registry/fallback pattern'iyle çalışıyor.
/// Yani listelenmemiş, hatta hiç bilmediğin bir `CartType` bile otomatik
/// olarak makul bir arayüzle çalışır (bkz. core/cart/cart_visuals.dart ve
/// core/cart/cart_item_registry.dart içindeki fallback'ler).
///
/// Backend'den "cart_type": "her_hangi_bir_yeni_sey" gibi bir string gelse
/// bile `CartType('her_hangi_bir_yeni_sey')` ile hiç kod değişikliği
/// gerekmeden çalışır; sadece görünümünü özelleştirmek istediğinde bir
/// builder/visual kaydedersin.
class CartType {
  final String id;
  const CartType(this.id);

  // Şimdiden bilinen türler — bunlar sadece kolaylık sabitleri,
  // sistemin çalışması için şart değil.
  static const market = CartType('market'); // market/e-ticaret sepeti
  static const secondHand = CartType('second_hand'); // ikinci el alışveriş
  static const food = CartType('food'); // yemek siparişi
  static const pharmacy = CartType('pharmacy'); // eczane/ilaç
  static const travelTicket = CartType('travel_ticket'); // gezi/seyahat bileti
  static const eventTicket = CartType('event_ticket'); // etkinlik/organizasyon bileti
  static const hosting = CartType('hosting'); // hosting hizmetleri
  static const subscription = CartType('subscription'); // video/koleksiyon aboneliği
  static const investment = CartType('investment'); // yatırım portföyü
  static const insurance = CartType('insurance'); // sigorta poliçeleri
  static const banking = CartType('banking'); // banka ürün/hizmetleri
  static const healthAppointment = CartType('health_appointment'); // sağlık randevusu
  static const legalFinanceConsulting =
      CartType('legal_finance_consulting'); // hukuk/mali danışmanlık
  static const betting = CartType('betting'); // bahis kuponu
  static const sportsGear = CartType('sports_gear'); // spor malzemesi
  static const wholesale = CartType('wholesale'); // toptan ticari ürünler
  static const education = CartType('education'); // ders/kurs

  @override
  bool operator ==(Object other) => other is CartType && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CartType($id)';
}

/// Bir sepetteki tek bir ürün/hizmet satırı.
///
/// Domain'e özel alanlar (ilaç dozajı, koltuk numarası, poliçe süresi vb.)
/// için sabit alanlar eklemek yerine `metadata` kullanılıyor — böylece yeni
/// bir sepet türü eklerken bu sınıfı değiştirmene gerek kalmıyor.
class CartItem {
  final String id;
  final CartType cartType;
  final String title;
  final String? imageUrl;
  final double price;
  final String currency;
  final int quantity;
  final Map<String, dynamic> metadata;

  const CartItem({
    required this.id,
    required this.cartType,
    required this.title,
    required this.price,
    this.imageUrl,
    this.currency = "TRY",
    this.quantity = 1,
    this.metadata = const {},
  });

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      cartType: cartType,
      title: title,
      imageUrl: imageUrl,
      price: price,
      currency: currency,
      quantity: quantity ?? this.quantity,
      metadata: metadata,
    );
  }
}

/// Tek bir türe ait sepetin tamamı (örn. kullanıcının "market sepeti").
class Cart {
  final CartType cartType;
  final List<CartItem> items;

  const Cart({required this.cartType, this.items = const []});

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => items.isEmpty;
}
