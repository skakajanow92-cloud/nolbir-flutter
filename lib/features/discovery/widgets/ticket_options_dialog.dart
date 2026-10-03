import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/cart.dart';
import '../../cart/application/cart_providers.dart';
import '../application/ticket_search_providers.dart';

class TicketOption {
  final String id;
  final String carrierName;
  final String departTime; // "08:30" gibi gösterim metni
  final String arriveTime;
  final String durationLabel;
  final String stopsLabel;
  final double price;

  const TicketOption({
    required this.id,
    required this.carrierName,
    required this.departTime,
    required this.arriveTime,
    required this.durationLabel,
    required this.stopsLabel,
    required this.price,
  });
}

/// Aramayla ilgisi olmayan, salt deterministik bir mock üretici — aynı
/// from/to/date için her seferinde aynı sonuçları döner (gerçek bir API
/// çağrısı gelene kadar).
List<TicketOption> generateMockTicketOptions(TicketSearchFormState query) {
  final seed = (query.from + query.to).hashCode.abs();
  const carriers = ["Nova", "Mavi Yol", "Kuzey Ekspres", "Aydın"];
  return List.generate(4, (i) {
    final price = 400.0 + ((seed + i * 137) % 900);
    final hour = 6 + ((seed + i * 53) % 14);
    return TicketOption(
      id: "opt_${query.from}_${query.to}_$i",
      carrierName: carriers[(seed + i) % carriers.length],
      departTime: "${hour.toString().padLeft(2, '0')}:00",
      arriveTime: "${((hour + 3) % 24).toString().padLeft(2, '0')}:30",
      durationLabel: "3s 30d",
      stopsLabel: i == 0 ? "Direkt" : "$i aktarma",
      price: price,
    );
  })..sort((a, b) => a.price.compareTo(b.price));
}

class TicketOptionsDialog extends ConsumerWidget {
  final TicketSearchFormState query;

  const TicketOptionsDialog({super.key, required this.query});

  Future<void> _addToCart(
    BuildContext context,
    WidgetRef ref,
    TicketOption option,
  ) async {
    // NOT: CartType içinde bilet/seyahat için özel bir değer olup olmadığını
    // göremedim — şimdilik CartType.market kullanıldı. models/cart.dart'ı
    // paylaşırsan uygun türe (ör. CartType.travel) güncellerim.
    await ref
        .read(cartDetailProvider(CartType.market).notifier)
        .addItem(
          CartItem(
            id: option.id,
            cartType: CartType.market,
            title: "${query.from} → ${query.to} · ${option.carrierName}",
            price: option.price,
            metadata: {
              "from": query.from,
              "to": query.to,
              "departDate": query.departDate?.toIso8601String() ?? "",
              "passengerCount": query.passengerCount.toString(),
            },
          ),
        );
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bilet sepete eklendi"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = generateMockTicketOptions(query);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF14181A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                "${query.from} → ${query.to}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${options.length} seçenek bulundu",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final option in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                                option.carrierName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${option.departTime} - ${option.arriveTime} · ${option.durationLabel} · ${option.stopsLabel}",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${option.price.toStringAsFixed(0)} TRY",
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: () => _addToCart(context, ref, option),
                              child: const Text("Sepete ekle"),
                            ),
                          ],
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
