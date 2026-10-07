import '../../../models/cart_card/cart_card.dart';
import '../../../models/pharmacy_cart.dart';
import '../../../models/cart.dart';

PharmacyCartCard buildPharmacyCartMock() {
  return PharmacyCartCard(
    id: "pharmacycart1",
    cart: Cart(
      cartType: CartType.pharmacy,
      items: [
        // Reçeteli — reçete numarasına bağlı, izin verilen adetten az
        // talep ediliyor.
        CartItem(
          id: "pci1",
          cartType: CartType.pharmacy,
          title: "Augmentin 1000mg 14 Tablet",
          price: 112.50,
          quantity: 1,
          metadata: const {
            "requiresPrescription": true,
            "prescriptionNumber": "ERX-2026-884213",
            "prescribedQuantity": 2,
            "pharmacyName": "Sağlık Eczanesi",
            "pharmacyLicenseNumber": "TR-ECZ-34-10492",
          },
        ),
        // Aynı reçeteye bağlı ikinci kalem.
        CartItem(
          id: "pci2",
          cartType: CartType.pharmacy,
          title: "Parol 500mg 20 Tablet",
          price: 42.75,
          quantity: 1,
          metadata: const {
            "requiresPrescription": true,
            "prescriptionNumber": "ERX-2026-884213",
            "prescribedQuantity": 1,
            "pharmacyName": "Sağlık Eczanesi",
            "pharmacyLicenseNumber": "TR-ECZ-34-10492",
          },
        ),
        // Reçetesiz (OTC) ürün.
        CartItem(
          id: "pci3",
          cartType: CartType.pharmacy,
          title: "D Vitamini Damla",
          price: 89.90,
          metadata: const {
            "requiresPrescription": false,
            "pharmacyName": "Sağlık Eczanesi",
            "pharmacyLicenseNumber": "TR-ECZ-34-10492",
          },
        ),
      ],
    ),
    prescriptions: [
      DigitalPrescription(
        id: "rx1",
        prescriptionNumber: "ERX-2026-884213",
        doctorName: "Dr. Elif Korkmaz",
        doctorSpecialty: "Kulak Burun Boğaz",
        healthInstitution: "Acıbadem Hastanesi",
        digitalSignatureRef: "SIG-7F3A-99C1-4B2E",
        issuedDate: DateTime.now().subtract(const Duration(days: 2)),
        // Alarm banner'ını göstermek için kısa geçerlilik süresi.
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        status: PrescriptionStatus.active,
      ),
    ],
    priceComparisons: const [
      MedicineComparisonGroup(
        id: "mc1",
        medicineName: "Augmentin 1000mg 14 Tablet",
        requiresPrescription: true,
        offers: [
          PharmacyOffer(
            id: "pho1",
            pharmacyName: "Sağlık Eczanesi",
            licenseNumber: "TR-ECZ-34-10492",
            country: "Türkiye",
            price: 112.50,
          ),
          PharmacyOffer(
            id: "pho2",
            pharmacyName: "Merkez Eczanesi",
            licenseNumber: "TR-ECZ-06-77310",
            country: "Türkiye",
            price: 108.90,
          ),
          PharmacyOffer(
            id: "pho3",
            pharmacyName: "Yıldız Eczanesi",
            licenseNumber: "TR-ECZ-35-22841",
            country: "Türkiye",
            price: 0,
            inStock: false,
          ),
        ],
      ),
      MedicineComparisonGroup(
        id: "mc2",
        medicineName: "D Vitamini Damla",
        requiresPrescription: false,
        offers: [
          PharmacyOffer(
            id: "pho4",
            pharmacyName: "Sağlık Eczanesi",
            licenseNumber: "TR-ECZ-34-10492",
            country: "Türkiye",
            price: 89.90,
          ),
          PharmacyOffer(
            id: "pho5",
            pharmacyName: "Merkez Eczanesi",
            licenseNumber: "TR-ECZ-06-77310",
            country: "Türkiye",
            price: 82.00,
          ),
        ],
      ),
    ],
    recommendations: const [
      RecommendedPharmacyProduct(
        id: "rpp1",
        title: "Çinko Takviyesi",
        category: OtcCategory.supplement,
        price: 145.00,
        pharmacyName: "Sağlık Eczanesi",
      ),
      RecommendedPharmacyProduct(
        id: "rpp2",
        title: "Probiyotik Kapsül",
        category: OtcCategory.supplement,
        price: 210.00,
        pharmacyName: "Merkez Eczanesi",
      ),
      RecommendedPharmacyProduct(
        id: "rpp3",
        title: "El Dezenfektanı 100ml",
        category: OtcCategory.personalCare,
        price: 38.50,
        pharmacyName: "Sağlık Eczanesi",
      ),
    ],
  );
}
