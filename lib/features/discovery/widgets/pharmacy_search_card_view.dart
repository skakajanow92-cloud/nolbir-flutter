import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'pharmacy_fulfillment_dialog.dart';
import 'pharmacy_shared.dart';

class PharmacySearchCardView extends StatefulWidget {
  final PharmacySearchCard card;
  const PharmacySearchCardView({super.key, required this.card});

  @override
  State<PharmacySearchCardView> createState() => _PharmacySearchCardViewState();
}

class _PharmacySearchCardViewState extends State<PharmacySearchCardView> {
  final _controller = TextEditingController();
  DigitalPrescription? _result;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    final prescription = lookupPrescription(_controller.text);
    if (prescription == null) {
      setState(() {
        _result = null;
        _error = "Reçete numarası bulunamadı.";
      });
      return;
    }
    if (prescription.isExpired) {
      setState(() {
        _result = null;
        _error = "Bu reçetenin süresi dolmuş.";
      });
      return;
    }
    setState(() {
      _result = prescription;
      _error = null;
    });
  }

  void _openFulfillment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PharmacyFulfillmentDialog(prescription: _result!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return CardPageScaffold(
      baseColor: const Color(0xFF0E1A16),
      baseEndColor: const Color(0xFF14241C),
      header: _Header(card: card),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Reçete numarası",
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white54,
                  ),
                  onPressed: () {}, // NOT: kamera entegrasyonu kapsam dışı
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _verify,
                child: const Text("Doğrula"),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 18),
              const Text(
                "Reçetedeki Ürünler",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              for (final itemName in _result!.prescribedItemNames)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medication_outlined,
                        color: PharmacyColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        itemName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: PharmacyColors.accent,
                  ),
                  onPressed: _openFulfillment,
                  icon: const Icon(Icons.near_me_outlined),
                  label: const Text("En Yakın Eczaneden Tamamla"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PharmacySearchCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: card.platformLogoUrl.isEmpty
              ? const Icon(Icons.search, color: PharmacyColors.accent)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(card.platformLogoUrl, fit: BoxFit.cover),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            card.platformName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
