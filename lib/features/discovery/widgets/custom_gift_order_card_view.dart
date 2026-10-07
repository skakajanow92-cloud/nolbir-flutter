import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'custom_gift_order_summary_dialog.dart';

class CustomGiftOrderCardView extends StatefulWidget {
  final CustomGiftOrderCard card;

  const CustomGiftOrderCardView({super.key, required this.card});

  @override
  State<CustomGiftOrderCardView> createState() =>
      _CustomGiftOrderCardViewState();
}

class _CustomGiftOrderCardViewState extends State<CustomGiftOrderCardView> {
  static const _base = Color(0xFF1C1020);
  static const _baseEnd = Color(0xFF261430);
  static const accent = Color(0xFFE06C9F);

  static const _timeSlots = ["Sabah (09-12)", "Öğlen (12-15)", "Akşam (15-19)"];

  GiftCategory? _category;
  Occasion? _occasion;
  String? _timeSlot;
  double _budget = 0;
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _deliveryDate;

  @override
  void initState() {
    super.initState();
    _budget = widget.card.minBudget;
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isValid => _category != null && _occasion != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  void _openSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomGiftOrderSummaryDialog(
        request: CustomGiftOrderRequest(
          businessName: widget.card.businessName,
          category: _category!,
          occasion: _occasion!,
          budget: _budget,
          currency: widget.card.currency,
          recipientName: _recipientController.text.trim(),
          messageCardText: _messageController.text.trim(),
          deliveryDate: _deliveryDate,
          deliveryTimeSlot: _timeSlot,
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
            const _FieldLabel("Vesile"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.availableOccasions
                  .map(
                    (o) => _ToggleChip(
                      label: o.label,
                      selected: _occasion == o,
                      onTap: () => setState(() => _occasion = o),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _recipientController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Alıcı adı (opsiyonel)",
                labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _messageController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Kart mesajı (opsiyonel)",
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
                      _deliveryDate == null
                          ? "Teslimat tarihi seç"
                          : "${_deliveryDate!.day.toString().padLeft(2, '0')}.${_deliveryDate!.month.toString().padLeft(2, '0')}.${_deliveryDate!.year}",
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots
                  .map(
                    (t) => _ToggleChip(
                      label: t,
                      selected: _timeSlot == t,
                      onTap: () => setState(() => _timeSlot = t),
                    ),
                  )
                  .toList(),
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
  final CustomGiftOrderCard card;
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
          child: card.businessLogoUrl.isEmpty
              ? const Icon(
                  Icons.card_giftcard_outlined,
                  color: _CustomGiftOrderCardViewState.accent,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(card.businessLogoUrl, fit: BoxFit.cover),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.businessName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                "Özel Hediye Siparişi",
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
              ? _CustomGiftOrderCardViewState.accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _CustomGiftOrderCardViewState.accent
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
