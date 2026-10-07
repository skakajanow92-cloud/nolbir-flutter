import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

class CustomGiftOrderRequest {
  final String businessName;
  final GiftCategory category;
  final Occasion occasion;
  final String? recipientName;
  final String? messageCardText;
  final double budget;
  final String currency;
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;
  final String? note;

  const CustomGiftOrderRequest({
    required this.businessName,
    required this.category,
    required this.occasion,
    required this.budget,
    required this.currency,
    this.recipientName,
    this.messageCardText,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.note,
  });
}

class CustomGiftOrderSummaryDialog extends StatelessWidget {
  final CustomGiftOrderRequest request;

  const CustomGiftOrderSummaryDialog({super.key, required this.request});

  static const accent = Color(0xFFE06C9F);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1020),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                "Talep Özeti",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${request.businessName} işletmesine gönderilecek",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _SummaryRow(label: "Ürün türü", value: request.category.label),
              _SummaryRow(label: "Vesile", value: request.occasion.label),
              if (request.recipientName != null &&
                  request.recipientName!.isNotEmpty)
                _SummaryRow(label: "Alıcı", value: request.recipientName!),
              if (request.messageCardText != null &&
                  request.messageCardText!.isNotEmpty)
                _SummaryRow(
                  label: "Kart mesajı",
                  value: request.messageCardText!,
                ),
              _SummaryRow(
                label: "Bütçe",
                value:
                    "${request.budget.toStringAsFixed(0)} ${request.currency}",
              ),
              if (request.deliveryDate != null)
                _SummaryRow(
                  label: "Teslimat tarihi",
                  value:
                      "${request.deliveryDate!.day.toString().padLeft(2, '0')}.${request.deliveryDate!.month.toString().padLeft(2, '0')}.${request.deliveryDate!.year}",
                ),
              if (request.deliveryTimeSlot != null)
                _SummaryRow(
                  label: "Teslimat dilimi",
                  value: request.deliveryTimeSlot!,
                ),
              if (request.note != null && request.note!.isNotEmpty)
                _SummaryRow(label: "Not", value: request.note!),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Talebiniz iletildi (mock)"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text("Talebi gönder"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
