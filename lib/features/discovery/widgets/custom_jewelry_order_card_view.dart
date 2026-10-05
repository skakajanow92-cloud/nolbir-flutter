import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'custom_order_summary_dialog.dart';

class CustomJewelryOrderCardView extends StatefulWidget {
  final CustomJewelryOrderCard card;

  const CustomJewelryOrderCardView({super.key, required this.card});

  @override
  State<CustomJewelryOrderCardView> createState() =>
      _CustomJewelryOrderCardViewState();
}

class _CustomJewelryOrderCardViewState
    extends State<CustomJewelryOrderCardView> {
  static const _base = Color(0xFF1C1710);
  static const _baseEnd = Color(0xFF26200F);
  static const accent = Color(0xFFD4A947);

  JewelryCategory? _category;
  MetalType? _metalType;
  int? _karat;
  double _budget = 0;
  final _engravingController = TextEditingController();
  final _gemstoneController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _desiredDate;

  @override
  void initState() {
    super.initState();
    _budget = widget.card.minBudget;
  }

  @override
  void dispose() {
    _engravingController.dispose();
    _gemstoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _category != null && _metalType != null && _karat != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _desiredDate ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _desiredDate = picked);
  }

  void _openSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomOrderSummaryDialog(
        request: CustomOrderRequest(
          brandName: widget.card.brandName,
          category: _category!,
          metalType: _metalType!,
          karat: _karat!,
          budget: _budget,
          currency: widget.card.currency,
          engravingText: _engravingController.text.trim(),
          gemstonePreference: _gemstoneController.text.trim(),
          desiredDate: _desiredDate,
          note: _noteController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
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
            const _FieldLabel("Ürün Türü"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.availableCategories
                  .map(
                    (c) => _ToggleChip(
                      label: c.label,
                      selected: _category == c,
                      onTap: () => setState(() => _category = c),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const _FieldLabel("Metal"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.availableMetals
                  .map(
                    (m) => _ToggleChip(
                      label: m.label,
                      selected: _metalType == m,
                      onTap: () => setState(() => _metalType = m),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const _FieldLabel("Ayar"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.availableKarats
                  .map(
                    (k) => _ToggleChip(
                      label: "$k Ayar",
                      selected: _karat == k,
                      onTap: () => setState(() => _karat = k),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _engravingController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "İsim / Kazıma metni (opsiyonel)",
                labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _gemstoneController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Taş tercihi (opsiyonel)",
                labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (card.maxBudget > card.minBudget) ...[
              const _FieldLabel("Bütçe"),
              const SizedBox(height: 8),
              Slider(
                value: _budget.clamp(card.minBudget, card.maxBudget),
                min: card.minBudget,
                max: card.maxBudget,
                divisions: 20,
                activeColor: accent,
                label: "${_budget.toStringAsFixed(0)} ${card.currency}",
                onChanged: (v) => setState(() => _budget = v),
              ),
              const SizedBox(height: 10),
            ],
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_outlined,
                      color: Colors.white54,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _desiredDate == null
                          ? "Hedeflenen teslim tarihi (opsiyonel)"
                          : "${_desiredDate!.day.toString().padLeft(2, '0')}.${_desiredDate!.month.toString().padLeft(2, '0')}.${_desiredDate!.year}",
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Ek not (opsiyonel)",
                labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: _isValid ? _openSummary : null,
                child: const Text("Talep özetini gör"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CustomJewelryOrderCard card;
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
          child: card.brandLogoUrl.isEmpty
              ? const Icon(
                  Icons.design_services_outlined,
                  color: _CustomJewelryOrderCardViewState.accent,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(card.brandLogoUrl, fit: BoxFit.cover),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.brandName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                "Özel Sipariş",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? _CustomJewelryOrderCardViewState.accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _CustomJewelryOrderCardViewState.accent
                : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
