import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

class SubscriptionPlansDialog extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  final String currency;
  final void Function(SubscriptionPlan plan) onSelect;

  const SubscriptionPlansDialog({
    super.key,
    required this.plans,
    required this.currency,
    required this.onSelect,
  });

  static const accent = Color(0xFFE50914);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                "Abonelik Planları",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              for (final plan in plans)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: plan.isAdultAddon
                          ? Border.all(
                              color: Colors.amber.withValues(alpha: 0.4),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "${plan.monthlyPrice.toStringAsFixed(0)} $currency/ay",
                              style: const TextStyle(
                                color: accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (plan.isAdultAddon) ...[
                          const SizedBox(height: 4),
                          const Text(
                            "Ek paket — 18+ içeriklere erişim sağlar",
                            style: TextStyle(color: Colors.amber, fontSize: 11),
                          ),
                        ],
                        const SizedBox(height: 8),
                        for (final perk in plan.perks)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: Colors.white54,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  perk,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              onSelect(plan);
                              Navigator.of(context).pop();
                            },
                            child: const Text("Seç"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
