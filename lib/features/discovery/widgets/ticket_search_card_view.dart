import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../application/ticket_search_providers.dart';
import 'ticket_options_dialog.dart';

class TicketSearchCardView extends ConsumerWidget {
  final TicketSearchCard card;

  const TicketSearchCardView({super.key, required this.card});

  static const _base = Color(0xFF0E1420);
  static const _baseEnd = Color(0xFF17213A);
  static const accent = Color(0xFFFFA23E);

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    TicketSearchFormState form, {
    required bool isReturn,
  }) async {
    final now = DateTime.now();
    final initial =
        (isReturn ? form.returnDate : form.departDate) ??
        (isReturn ? (form.departDate ?? now) : now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    final notifier = ref.read(ticketSearchFormProvider(card.id).notifier);
    notifier.update(
      (state) => isReturn
          ? state.copyWith(returnDate: picked)
          : state.copyWith(departDate: picked),
    );
  }

  void _openResults(BuildContext context, TicketSearchFormState form) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TicketOptionsDialog(query: form),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(ticketSearchFormProvider(card.id));
    final notifier = ref.read(ticketSearchFormProvider(card.id).notifier);

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
            _TripTypeToggle(
              tripType: form.tripType,
              onChanged: (t) => notifier.update(
                (s) => s.copyWith(
                  tripType: t,
                  clearReturnDate: t == TripType.oneWay,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _RouteFields(
              from: form.from,
              to: form.to,
              popularCities: card.popularCities,
              onFromChanged: (v) => notifier.update((s) => s.copyWith(from: v)),
              onToChanged: (v) => notifier.update((s) => s.copyWith(to: v)),
              onSwap: () =>
                  notifier.update((s) => s.copyWith(from: s.to, to: s.from)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: "Gidiş",
                    date: form.departDate,
                    onTap: () => _pickDate(context, ref, form, isReturn: false),
                  ),
                ),
                if (form.tripType == TripType.roundTrip) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      label: "Dönüş",
                      date: form.returnDate,
                      onTap: () =>
                          _pickDate(context, ref, form, isReturn: true),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _PassengerStepper(
              count: form.passengerCount,
              onChanged: (c) =>
                  notifier.update((s) => s.copyWith(passengerCount: c)),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: form.isValid
                    ? () => _openResults(context, form)
                    : null,
                child: const Text("Bilet ara"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TicketSearchCard card;
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
              ? Icon(
                  card.transportMode.icon,
                  color: TicketSearchCardView.accent,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(card.platformLogoUrl, fit: BoxFit.cover),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.platformName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card.transportMode.label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripTypeToggle extends StatelessWidget {
  final TripType tripType;
  final ValueChanged<TripType> onChanged;
  const _TripTypeToggle({required this.tripType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleChip(
          label: "Gidiş-Dönüş",
          selected: tripType == TripType.roundTrip,
          onTap: () => onChanged(TripType.roundTrip),
        ),
        const SizedBox(width: 8),
        _ToggleChip(
          label: "Tek Yön",
          selected: tripType == TripType.oneWay,
          onTap: () => onChanged(TripType.oneWay),
        ),
      ],
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
              ? TicketSearchCardView.accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? TicketSearchCardView.accent : Colors.white24,
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

class _RouteFields extends StatelessWidget {
  final String from;
  final String to;
  final List<String> popularCities;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
  final VoidCallback onSwap;

  const _RouteFields({
    required this.from,
    required this.to,
    required this.popularCities,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CityField(
                label: "Nereden",
                value: from,
                onChanged: onFromChanged,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.white54),
              onPressed: onSwap,
            ),
            Expanded(
              child: _CityField(
                label: "Nereye",
                value: to,
                onChanged: onToChanged,
              ),
            ),
          ],
        ),
        if (popularCities.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularCities
                .map(
                  (city) => ActionChip(
                    label: Text(city, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    onPressed: () {
                      if (from.isEmpty) {
                        onFromChanged(city);
                      } else if (to.isEmpty) {
                        onToChanged(city);
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _CityField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const _CityField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              date == null
                  ? "Tarih seç"
                  : "${date!.day.toString().padLeft(2, '0')}.${date!.month.toString().padLeft(2, '0')}.${date!.year}",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassengerStepper extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  const _PassengerStepper({required this.count, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Yolcu sayısı",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.white54,
              ),
              onPressed: count > 1 ? () => onChanged(count - 1) : null,
            ),
            Text(
              "$count",
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
              onPressed: count < 9 ? () => onChanged(count + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
