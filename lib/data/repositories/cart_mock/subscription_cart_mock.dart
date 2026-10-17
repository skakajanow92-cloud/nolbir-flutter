import '../../../models/cart_card/cart_card.dart';
import '../../../models/subscription_cart.dart';
import '../../../models/hosting.dart';
import '../../../models/cart.dart';

SubscriptionCartCard buildSubscriptionCartMock() {
  return SubscriptionCartCard(
    id: "subscriptioncart1",
    cart: Cart(
      cartType: CartType.subscription,
      items: [
        // Koleksiyon sahibi, ücretsiz denemeli, aylık.
        CartItem(
          id: "scci1",
          cartType: CartType.subscription,
          title: "Retro Film Koleksiyonu",
          price: 99,
          metadata: const {
            "subOwnerName": "Retro Film Koleksiyonu",
            "subOwnerKind": SubscriptionOwnerKind.collectionOwner,
            "subPlanName": "Klasikler",
            "subBillingCycle": BillingCycle.monthly,
            "subTrialDays": 7,
            "subAutoRenew": true,
            "subContentSummary": "1.800+ restore edilmiş klasik film",
            "subFeatures": <String>[
              "Restore edilmiş HD arşiv",
              "Yönetmen belgeselleri",
              "Çevrimdışı izleme",
            ],
          },
        ),
        // Koleksiyon sahibi, yıllık, deneme yok, taahhütlü.
        CartItem(
          id: "scci2",
          cartType: CartType.subscription,
          title: "Belgesel Arşivi",
          price: 1190,
          metadata: const {
            "subOwnerName": "Belgesel Arşivi",
            "subOwnerKind": SubscriptionOwnerKind.collectionOwner,
            "subPlanName": "Tam Erişim",
            "subBillingCycle": BillingCycle.yearly,
            "subMinCommitmentMonths": 12,
            "subAutoRenew": true,
            "subContentSummary": "Doğa, tarih ve bilim belgeselleri",
            "subFeatures": <String>["4K belgesel arşivi", "Her ay yeni içerik"],
          },
        ),
        // Yayıncı, uzun denemeli, taahhütsüz.
        CartItem(
          id: "scci3",
          cartType: CartType.subscription,
          title: "Dijital Dergi Yayınları",
          price: 89,
          metadata: const {
            "subOwnerName": "Dijital Dergi Yayınları",
            "subOwnerKind": SubscriptionOwnerKind.publisher,
            "subPlanName": "Premium",
            "subBillingCycle": BillingCycle.monthly,
            "subTrialDays": 14,
            "subAutoRenew": true,
            "subContentSummary": "40+ dergi ve tüm arşiv",
            "subFeatures": <String>[
              "Tüm dergilere sınırsız erişim",
              "Geçmiş sayı arşivi",
              "Reklamsız okuma",
            ],
          },
        ),
        // Yayıncı, deneme yok, otomatik yenileme kapalı.
        CartItem(
          id: "scci4",
          cartType: CartType.subscription,
          title: "Sesli Kitap Yayınevi",
          price: 129,
          metadata: const {
            "subOwnerName": "Sesli Kitap Yayınevi",
            "subOwnerKind": SubscriptionOwnerKind.publisher,
            "subPlanName": "Sınırsız Dinleme",
            "subBillingCycle": BillingCycle.monthly,
            "subAutoRenew": false,
            "subContentSummary": "12.000+ sesli kitap",
          },
        ),
        // Yapımcı şirket, 3 aylık, denemeli.
        CartItem(
          id: "scci5",
          cartType: CartType.subscription,
          title: "Anadolu Yapım",
          price: 450,
          metadata: const {
            "subOwnerName": "Anadolu Yapım",
            "subOwnerKind": SubscriptionOwnerKind.producer,
            "subPlanName": "Dizi & Film Pass",
            "subBillingCycle": BillingCycle.quarterly,
            "subTrialDays": 7,
            "subAutoRenew": true,
            "subContentSummary": "Yapımcının tüm orijinal dizi ve filmleri",
            "subFeatures": <String>[
              "Tüm orijinal yapımlar",
              "Yeni bölümler yayınla aynı gün",
              "Kamera arkası içerikleri",
            ],
          },
        ),
      ],
    ),
    tierComparisons: const [
      SubscriptionTierGroup(
        id: "stg1",
        ownerName: "Dijital Dergi Yayınları",
        selectedTierName: "Premium",
        tiers: [
          SubscriptionTier(
            id: "st1",
            name: "Temel",
            price: 49,
            highlights: ["10 dergi", "Reklamlı"],
          ),
          SubscriptionTier(
            id: "st2",
            name: "Standart",
            price: 69,
            highlights: ["25 dergi", "Reklamsız"],
          ),
          SubscriptionTier(
            id: "st3",
            name: "Premium",
            price: 89,
            highlights: ["40+ dergi", "Tüm arşiv", "Reklamsız"],
          ),
          SubscriptionTier(
            id: "st4",
            name: "Premium Plus",
            price: 119,
            highlights: ["40+ dergi", "Tüm arşiv", "Aile paylaşımı (4 kişi)"],
          ),
        ],
      ),
      SubscriptionTierGroup(
        id: "stg2",
        ownerName: "Anadolu Yapım",
        selectedTierName: "Dizi & Film Pass",
        tiers: [
          SubscriptionTier(
            id: "st5",
            name: "Dizi Pass",
            price: 330,
            billingCycle: BillingCycle.quarterly,
            highlights: ["Sadece diziler"],
          ),
          SubscriptionTier(
            id: "st6",
            name: "Dizi & Film Pass",
            price: 450,
            billingCycle: BillingCycle.quarterly,
            highlights: ["Dizi ve filmler", "HD"],
          ),
          SubscriptionTier(
            id: "st7",
            name: "Dizi & Film Pass 4K",
            price: 570,
            billingCycle: BillingCycle.quarterly,
            highlights: ["Dizi ve filmler", "4K", "Kamera arkası"],
          ),
        ],
      ),
    ],
    recommendations: const [
      RecommendedSubscriptionPlan(
        id: "rsp1",
        ownerName: "Müzik Arşivi",
        ownerKind: SubscriptionOwnerKind.collectionOwner,
        planName: "Nadir Kayıtlar",
        price: 79,
        trialDays: 7,
        reason: SubscriptionRecommendationReason.similarContent,
      ),
      RecommendedSubscriptionPlan(
        id: "rsp2",
        ownerName: "Dijital Dergi Yayınları",
        ownerKind: SubscriptionOwnerKind.publisher,
        planName: "Dergi + Sesli Kitap Paketi",
        price: 169,
        bundleSavingsPercent: 22,
        reason: SubscriptionRecommendationReason.bundleDeal,
      ),
      RecommendedSubscriptionPlan(
        id: "rsp3",
        ownerName: "Belgesel Atölyesi",
        ownerKind: SubscriptionOwnerKind.producer,
        planName: "Tüm Yapımlar",
        price: 320,
        billingCycle: BillingCycle.quarterly,
        trialDays: 14,
        reason: SubscriptionRecommendationReason.popularNow,
      ),
    ],
  );
}
