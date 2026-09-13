import 'package:flutter/material.dart';
import '../../models/cart.dart';

/// Bir sepet türünün nasıl görüneceği (ikon, renk, görünen ad).
class CartTypeMeta {
  final String displayName;
  final IconData icon;
  final Color color;

  const CartTypeMeta({
    required this.displayName,
    required this.icon,
    required this.color,
  });
}

/// CartType -> CartTypeMeta eşlemesi. Kayıtlı olmayan (yani şu an
/// bilmediğimiz, ileride eklenecek) her tür otomatik olarak
/// `_fallbackFor()` ile makul bir görünüm alır — yeni bir sepet türü
/// UI çökmeden, kod değişikliği gerekmeden çalışır.
class CartVisuals {
  CartVisuals._();

  static final Map<String, CartTypeMeta> _registry = {
    CartType.market.id: const CartTypeMeta(
        displayName: "Market Sepeti", icon: Icons.local_grocery_store, color: Colors.green),
    CartType.secondHand.id: const CartTypeMeta(
        displayName: "İkinci El Sepeti", icon: Icons.recycling, color: Colors.brown),
    CartType.food.id: const CartTypeMeta(
        displayName: "Yemek Sepeti", icon: Icons.restaurant, color: Colors.deepOrange),
    CartType.pharmacy.id: const CartTypeMeta(
        displayName: "Eczane Sepeti", icon: Icons.medication, color: Colors.redAccent),
    CartType.travelTicket.id: const CartTypeMeta(
        displayName: "Seyahat Bileti Sepeti", icon: Icons.flight, color: Colors.blue),
    CartType.eventTicket.id: const CartTypeMeta(
        displayName: "Etkinlik Bileti Sepeti", icon: Icons.event, color: Colors.purple),
    CartType.hosting.id: const CartTypeMeta(
        displayName: "Hosting Sepeti", icon: Icons.dns, color: Colors.indigo),
    CartType.subscription.id: const CartTypeMeta(
        displayName: "Abonelik Sepeti", icon: Icons.subscriptions, color: Colors.pinkAccent),
    CartType.investment.id: const CartTypeMeta(
        displayName: "Yatırım Portföyü", icon: Icons.trending_up, color: Colors.teal),
    CartType.insurance.id: const CartTypeMeta(
        displayName: "Sigorta Sepeti", icon: Icons.shield, color: Colors.blueGrey),
    CartType.banking.id: const CartTypeMeta(
        displayName: "Banka Ürünleri Sepeti", icon: Icons.account_balance, color: Colors.blue),
    CartType.healthAppointment.id: const CartTypeMeta(
        displayName: "Sağlık Randevu Sepeti", icon: Icons.medical_services, color: Colors.red),
    CartType.legalFinanceConsulting.id: const CartTypeMeta(
        displayName: "Hukuk/Mali Danışmanlık Sepeti", icon: Icons.gavel, color: Colors.brown),
    CartType.betting.id: const CartTypeMeta(
        displayName: "Bahis Kuponu Sepeti", icon: Icons.casino, color: Colors.deepPurple),
    CartType.sportsGear.id: const CartTypeMeta(
        displayName: "Spor Malzemeleri Sepeti", icon: Icons.sports_soccer, color: Colors.lightGreen),
    CartType.wholesale.id: const CartTypeMeta(
        displayName: "Toptan Ticaret Sepeti", icon: Icons.warehouse, color: Colors.grey),
    CartType.education.id: const CartTypeMeta(
        displayName: "Eğitim/Kurs Sepeti", icon: Icons.school, color: Colors.deepPurpleAccent),
  };

  /// Yeni bir sepet türü için özel görünüm kaydet (opsiyonel).
  /// Kaydetmezsen tür yine çalışır, sadece generic ikon/renk kullanılır.
  static void register(CartType type, CartTypeMeta meta) {
    _registry[type.id] = meta;
  }

  static CartTypeMeta of(CartType type) {
    return _registry[type.id] ?? _fallbackFor(type);
  }

  static CartTypeMeta _fallbackFor(CartType type) {
    final readable = type.id
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return CartTypeMeta(
      displayName: "$readable Sepeti",
      icon: Icons.shopping_bag,
      color: Colors.blueGrey,
    );
  }
}
