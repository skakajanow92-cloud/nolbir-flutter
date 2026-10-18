import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'pharmacy_shared.dart';

class FulfillmentAssignment {
  final String itemName;
  final String pharmacyName;
  final String branch;
  final double distanceKm;

  const FulfillmentAssignment({
    required this.itemName,
    required this.pharmacyName,
    required this.branch,
    required this.distanceKm,
  });
}

/// Mock tamamlama planı — reçetedeki her kalemi, konuma en yakın bir
/// eczane/şubeye dağıtıyor. Gerçekte bu eşleştirme (stok, mesafe,
/// birden fazla şubeden parça parça tamamlama) backend'de ayrı bir
/// kanaldan/servisten yürütülmeli — tek bir eczanenin API'sini çağırmak
/// yetmez, sipariş birden fazla eczane/şubeden toplanabilir.
List<FulfillmentAssignment> generateFulfillmentPlan(
  DigitalPrescription prescription,
) {
  final rnd = Random(prescription.id.hashCode);
  const pharmacies = ["Sağlık Eczanesi", "Merkez Eczane", "Yıldız Eczane"];
  const branches = ["Merkez Şube", "Kadıköy Şube", "Beşiktaş Şube"];
  return prescription.prescribedItemNames.map((item) {
    return FulfillmentAssignment(
      itemName: item,
      pharmacyName: pharmacies[rnd.nextInt(pharmacies.length)],
      branch: branches[rnd.nextInt(branches.length)],
      distanceKm: 0.5 + rnd.nextDouble() * 5,
    );
  }).toList();
}

class PharmacyFulfillmentDialog extends StatelessWidget {
  final DigitalPrescription prescription;

  const PharmacyFulfillmentDialog({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final plan = generateFulfillmentPlan(prescription);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E1A16),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                "En Yakın Noktadan Tamamlama",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Reçete #${prescription.id} için ${plan.length} kalem bulundu",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final a in plan)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.itemName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${a.pharmacyName} · ${a.branch}",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${a.distanceKm.toStringAsFixed(1)} km",
                          style: const TextStyle(
                            color: PharmacyColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: PharmacyColors.accent,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Sipariş tamamlanıyor (mock)"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text("Siparişi Tamamla"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
