import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_card/product_card.dart';
import '../../../models/cart.dart';
import '../../cart/application/cart_providers.dart';
import 'ecommerce_shared_widgets.dart';

class PharmacyColors {
  static const accent = Color(0xFF2E9E6B);
}

class PharmacyItemContent extends ConsumerStatefulWidget {
  final PharmacyItemCard item;
  const PharmacyItemContent({super.key, required this.item});

  @override
  ConsumerState<PharmacyItemContent> createState() =>
      _PharmacyItemContentState();
}

class _PharmacyItemContentState extends ConsumerState<PharmacyItemContent> {
  DigitalPrescription? _attachedPrescription;

  Future<void> _addToCart() async {
    final item = widget.item;
    await ref
        .read(cartDetailProvider(CartType.market).notifier)
        .addItem(
          CartItem(
            id: item.id,
            cartType: CartType.market,
            title: "${item.pharmacyName} · ${item.itemName}",
            imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : "",
            price: item.effectivePrice,
            currency: item.currency,
            metadata: _attachedPrescription == null
                ? {"prescriptionId": null}
                : {"prescriptionId": _attachedPrescription!.id},
          ),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item.itemName} sepete eklendi"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _openPrescriptionAttach() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrescriptionAttachSheet(
        requiredItemName: widget.item.itemName,
        onAttached: (prescription) =>
            setState(() => _attachedPrescription = prescription),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final canCheckout =
        !item.requiresPrescription || _attachedPrescription != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImageGallery(imageUrls: item.imageUrls),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.itemName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              PriceRow(
                price: item.price,
                discountedPrice: item.discountedPrice,
                currency: item.currency,
                accentColor: PharmacyColors.accent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            item.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AttributeBadge(
                text: item.requiresPrescription ? "Reçeteli" : "Reçetesiz",
                accentColor: item.requiresPrescription
                    ? Colors.amber
                    : PharmacyColors.accent,
                icon: item.requiresPrescription
                    ? Icons.description_outlined
                    : Icons.check_circle_outline,
              ),
              if (item.activeIngredient != null)
                AttributeBadge(
                  text: item.activeIngredient!,
                  accentColor: PharmacyColors.accent,
                ),
              if (item.packageInfo != null)
                AttributeBadge(
                  text: item.packageInfo!,
                  accentColor: PharmacyColors.accent,
                ),
            ],
          ),
        ),
        if (item.requiresPrescription) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _attachedPrescription == null
                ? const Text(
                    "Bu ürün için geçerli, dijital imzalı bir reçete gerekiyor.",
                    style: TextStyle(color: Colors.amber, fontSize: 12),
                  )
                : _PrescriptionBadge(prescription: _attachedPrescription!),
          ),
        ],
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: PharmacyColors.accent,
              ),
              onPressed: canCheckout ? _addToCart : _openPrescriptionAttach,
              icon: Icon(
                canCheckout
                    ? Icons.add_shopping_cart
                    : Icons.upload_file_outlined,
              ),
              label: Text(canCheckout ? "Sepete Ekle" : "Reçete Ekle"),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrescriptionBadge extends StatelessWidget {
  final DigitalPrescription prescription;
  const _PrescriptionBadge({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: PharmacyColors.accent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Reçete #${prescription.id} · ${prescription.digitalSignatureHash} · imzalı, değiştirilemez",
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reçete numarası girişi + doğrulama. Doğrulanan reçete "kayıt altına
/// alınmış" sayılır (`onAttached` ile çağırana bildirilir) — gerçek
/// kalıcılık (backend'e yazma) kapsam dışı, bu turda sadece akış var.
class PrescriptionAttachSheet extends StatefulWidget {
  final String requiredItemName;
  final ValueChanged<DigitalPrescription> onAttached;

  const PrescriptionAttachSheet({
    super.key,
    required this.requiredItemName,
    required this.onAttached,
  });

  @override
  State<PrescriptionAttachSheet> createState() =>
      _PrescriptionAttachSheetState();
}

class _PrescriptionAttachSheetState extends State<PrescriptionAttachSheet> {
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
    if (!prescription.covers(widget.requiredItemName)) {
      setState(() {
        _result = null;
        _error = "Bu reçete \"${widget.requiredItemName}\" ürününü kapsamıyor.";
      });
      return;
    }
    setState(() {
      _result = prescription;
      _error = null;
    });
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
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
                "Reçete Ekle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Reçete numaranızı girin — sistemde benzersiz bir kimliktir.",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
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
                    onPressed: () {
                      // NOT: Gerçek QR/barkod kamera okuma entegrasyonu
                      // kapsam dışı — sadece ikon yer tutucu.
                    },
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryRow(label: "Hasta", value: _result!.patientName),
                      _SummaryRow(
                        label: "Hekim",
                        value: _result!.issuingDoctorName,
                      ),
                      _SummaryRow(
                        label: "Son geçerlilik",
                        value: _formatDate(_result!.expiresAt),
                      ),
                      _SummaryRow(
                        label: "Dijital imza",
                        value: _result!.digitalSignatureHash,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: PharmacyColors.accent,
                    ),
                    onPressed: () {
                      widget.onAttached(_result!);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Reçeteyi Onayla ve Bağla"),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
