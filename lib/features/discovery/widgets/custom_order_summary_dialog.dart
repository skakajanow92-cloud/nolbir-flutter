import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

class CustomOrderRequest {
  final String brandName;
  final JewelryCategory category;
  final MetalType metalType;
  final int karat;
  final String? engravingText;
  final String? gemstonePreference;
  final double budget;
  final String currency;
  final DateTime? desiredDate;
  final String? note;

  const CustomOrderRequest({
    required this.brandName,
    required this.category,
    required this.metalType,
    required this.karat,
    required this.budget,
    required this.currency,
    this.engravingText,
    this.gemstonePreference,
    this.desiredDate,
    this.note,
  });
}

/// Arama sonuç dialog'larının (ticket/hotel/food) aksine burada bir
/// seçenek LİSTESİ yok — tek bir özet gösterilir ve "Talebi gönder"
/// basılınca işletmeye iletilir (mock'ta sadece SnackBar).
class CustomOrderSummaryDialog extends StatelessWidget {
  final CustomOrderRequest request;

  const CustomOrderSummaryDialog({super.key, required this.request});

  static const accent = Color(0xFFD4A947);

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
            color: Color(0xFF1C1710),
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
                "${request.brandName} markasına gönderilecek",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _SummaryRow(label: "Ürün türü", value: request.category.label),
              _SummaryRow(label: "Metal", value: request.metalType.label),
              _SummaryRow(label: "Ayar", value: "${request.karat} Ayar"),
              if (request.gemstonePreference != null &&
                  request.gemstonePreference!.isNotEmpty)
                _SummaryRow(
                  label: "Taş tercihi",
                  value: request.gemstonePreference!,
                ),
              if (request.engravingText != null &&
                  request.engravingText!.isNotEmpty)
                _SummaryRow(
                  label: "İsim/kazıma",
                  value: request.engravingText!,
                ),
              _SummaryRow(
                label: "Bütçe",
                value:
                    "${request.budget.toStringAsFixed(0)} ${request.currency}",
              ),
              if (request.desiredDate != null)
                _SummaryRow(
                  label: "Hedeflenen tarih",
                  value:
                      "${request.desiredDate!.day.toString().padLeft(2, '0')}.${request.desiredDate!.month.toString().padLeft(2, '0')}.${request.desiredDate!.year}",
                ),
              if (request.note != null && request.note!.isNotEmpty)
                _SummaryRow(label: "Not", value: request.note!),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    // NOT: Gerçek gönderim backend bağlanınca eklenecek —
                    // şimdilik sadece arayüz akışını gösteriyor.
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
