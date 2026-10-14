import '../../../models/cart_card/cart_card.dart';
import '../../../models/hosting_cart.dart';
import '../../../models/hosting.dart';
import '../../../models/cart.dart';

HostingCartCard buildHostingCartMock() {
  return HostingCartCard(
    id: "hostingcart1",
    cart: Cart(
      cartType: CartType.hosting,
      items: [
        // Hetzner'den İKİ kalem — firma grubunu ve grup başına ilk ödeme
        // toplamını göstermek için. VPS aylık, dedicated aylık + kurulum ücretli.
        CartItem(
          id: "hsci1",
          cartType: CartType.hosting,
          title: "CPX31 VPS",
          price: 640,
          metadata: const {
            "hostingProvider": "Hetzner",
            "hostingPlanName": "CPX31 VPS",
            "hostingPlanKind": HostingPlanKind.vps,
            "hostingBillingCycle": BillingCycle.monthly,
            "hostingCpuCores": 4,
            "hostingRamGb": 8,
            "hostingDiskGb": 160,
            "hostingBandwidthGb": 20000,
            "hostingDatacenter": "Nürnberg, Almanya",
            "hostingOs": "Ubuntu 24.04",
            "hostingControlPanel": "Yok",
            "hostingUptimeSla": 99.9,
            "hostingFeatures": <String>[
              "20 TB aylık trafik",
              "DDoS koruması",
              "Haftalık otomatik yedekleme (opsiyonel)",
            ],
          },
        ),
        CartItem(
          id: "hsci2",
          cartType: CartType.hosting,
          title: "AX42 Dedicated",
          price: 1950,
          metadata: const {
            "hostingProvider": "Hetzner",
            "hostingPlanName": "AX42 Dedicated",
            "hostingPlanKind": HostingPlanKind.dedicated,
            "hostingBillingCycle": BillingCycle.monthly,
            "hostingCpuCores": 8,
            "hostingRamGb": 64,
            "hostingDiskGb": 1024,
            "hostingUnlimitedBandwidth": true,
            "hostingDatacenter": "Falkenstein, Almanya",
            "hostingOs": "Debian 12",
            "hostingControlPanel": "Yok",
            "hostingUptimeSla": 99.9,
            "hostingSetupFee": 1100.0,
            "hostingFeatures": <String>[
              "Sınırsız trafik",
              "Rescue sistemi",
              "NVMe SSD",
            ],
          },
        ),
        // Yıllık ödemeli paylaşımlı paket — normalize karşılaştırmayı göstermek için.
        CartItem(
          id: "hsci3",
          cartType: CartType.hosting,
          title: "Kurumsal Paylaşımlı Hosting",
          price: 1200,
          metadata: const {
            "hostingProvider": "Natro",
            "hostingPlanName": "Kurumsal Paylaşımlı Hosting",
            "hostingPlanKind": HostingPlanKind.shared,
            "hostingBillingCycle": BillingCycle.yearly,
            "hostingDiskGb": 50,
            "hostingUnlimitedBandwidth": true,
            "hostingDatacenter": "İstanbul, Türkiye",
            "hostingControlPanel": "cPanel",
            "hostingUptimeSla": 99.9,
            "hostingFeatures": <String>[
              "3 alan adı barındırma",
              "Sınırsız e-posta hesabı",
              "Ücretsiz SSL",
              "Günlük yedekleme",
            ],
          },
        ),
        CartItem(
          id: "hsci4",
          cartType: CartType.hosting,
          title: "VDS 2",
          price: 1350, // 3 aylık dönem fiyatı
          metadata: const {
            "hostingProvider": "Turhost",
            "hostingPlanName": "VDS 2",
            "hostingPlanKind": HostingPlanKind.vds,
            "hostingBillingCycle": BillingCycle.quarterly,
            "hostingCpuCores": 2,
            "hostingRamGb": 4,
            "hostingDiskGb": 80,
            "hostingBandwidthGb": 5000,
            "hostingDatacenter": "İstanbul, Türkiye",
            "hostingOs": "Windows Server 2022",
            "hostingControlPanel": "Plesk",
            "hostingUptimeSla": 99.95,
            "hostingFeatures": <String>[
              "Windows lisansı dahil",
              "Plesk Web Admin Edition",
              "7/24 teknik destek",
            ],
          },
        ),
      ],
    ),
    priceComparisons: const [
      HostingPlanComparisonGroup(
        id: "hpc1",
        title: "4 vCPU / 8 GB RAM VPS",
        planKind: HostingPlanKind.vps,
        offers: [
          HostingPlanOffer(
            id: "hpo1",
            provider: "Hetzner",
            planName: "CPX31",
            price: 640,
            uptimeSla: 99.9,
            datacenter: "Nürnberg",
          ),
          HostingPlanOffer(
            id: "hpo2",
            provider: "DigitalOcean",
            planName: "Premium 4 vCPU",
            price: 1250,
            uptimeSla: 99.99,
            datacenter: "Frankfurt",
          ),
          // Yıllık ödemeli: aylık karşılığı 450 — normalize edilince en ucuz
          // bu çıkar, ham dönem fiyatına (5400) bakılsaydı en pahalı görünürdü.
          HostingPlanOffer(
            id: "hpo3",
            provider: "Hostinger",
            planName: "KVM 4",
            price: 5400,
            billingCycle: BillingCycle.yearly,
            uptimeSla: 99.9,
            datacenter: "Amsterdam",
          ),
          HostingPlanOffer(
            id: "hpo4",
            provider: "Turhost",
            planName: "VPS Pro",
            price: 0,
            isAvailable: false,
          ),
        ],
      ),
      HostingPlanComparisonGroup(
        id: "hpc2",
        title: "50 GB Paylaşımlı Hosting",
        planKind: HostingPlanKind.shared,
        offers: [
          HostingPlanOffer(
            id: "hpo5",
            provider: "Natro",
            planName: "Kurumsal",
            price: 1200,
            billingCycle: BillingCycle.yearly,
            uptimeSla: 99.9,
            datacenter: "İstanbul",
          ),
          HostingPlanOffer(
            id: "hpo6",
            provider: "Turhost",
            planName: "Başlangıç Plus",
            price: 140,
            uptimeSla: 99.95,
            datacenter: "İstanbul",
          ),
          HostingPlanOffer(
            id: "hpo7",
            provider: "Hostinger",
            planName: "Business",
            price: 960,
            billingCycle: BillingCycle.yearly,
            uptimeSla: 99.9,
            datacenter: "Frankfurt",
          ),
        ],
      ),
    ],
    addOns: const [
      RecommendedHostingAddOn(
        id: "rha1",
        name: "Otomatik Yedekleme",
        kind: HostingAddOnKind.backup,
        provider: "Hetzner",
        price: 130,
        relatedPlanName: "CPX31 VPS için",
      ),
      RecommendedHostingAddOn(
        id: "rha2",
        name: "Wildcard SSL",
        kind: HostingAddOnKind.ssl,
        provider: "Sectigo",
        price: 890,
        billingCycle: BillingCycle.yearly,
        relatedPlanName: "AX42 Dedicated için",
      ),
      RecommendedHostingAddOn(
        id: "rha3",
        name: ".com.tr Alan Adı",
        kind: HostingAddOnKind.domain,
        provider: "Natro",
        price: 320,
        billingCycle: BillingCycle.yearly,
        relatedPlanName: "Paylaşımlı Hosting için",
      ),
      RecommendedHostingAddOn(
        id: "rha4",
        name: "Uptime İzleme",
        kind: HostingAddOnKind.monitoring,
        provider: "UptimeRobot",
        price: 180,
      ),
    ],
  );
}
