import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'food_place_options_dialog.dart';

class FoodPlaceSearchCardView extends StatefulWidget {
  final FoodPlaceSearchCard card;

  const FoodPlaceSearchCardView({super.key, required this.card});

  @override
  State<FoodPlaceSearchCardView> createState() =>
      _FoodPlaceSearchCardViewState();
}

class _FoodPlaceSearchCardViewState extends State<FoodPlaceSearchCardView> {
  static const _base = Color(0xFF1A1208);
  static const _baseEnd = Color(0xFF221A0E);
  static const accent = Color(0xFFE08A3E);

  final _locationController = TextEditingController();
  final Set<String> _selectedCuisines = {};
  final Set<DiningOption> _selectedDiningOptions = {};

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  bool get _isValid => _locationController.text.trim().isNotEmpty;

  void _openResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodPlaceOptionsDialog(
        locationLabel: _locationController.text.trim(),
        selectedCuisines: _selectedCuisines.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(card: widget.card),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.card.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _locationController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Konum",
                labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            if (widget.card.popularLocations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.card.popularLocations
                    .map(
                      (loc) => ActionChip(
                        label: Text(loc, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        onPressed: () =>
                            setState(() => _locationController.text = loc),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            if (widget.card.cuisineTypes.isNotEmpty) ...[
              const Text(
                "Mutfak Türü",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.card.cuisineTypes
                    .map(
                      (c) => _ToggleChip(
                        label: c,
                        selected: _selectedCuisines.contains(c),
                        onTap: () => setState(() {
                          _selectedCuisines.contains(c)
                              ? _selectedCuisines.remove(c)
                              : _selectedCuisines.add(c);
                        }),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              "Sipariş Türü",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DiningOption.values
                  .map(
                    (o) => _ToggleChip(
                      label: o.label,
                      selected: _selectedDiningOptions.contains(o),
                      onTap: () => setState(() {
                        _selectedDiningOptions.contains(o)
                            ? _selectedDiningOptions.remove(o)
                            : _selectedDiningOptions.add(o);
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: _isValid ? _openResults : null,
                child: const Text("İşletme ara"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final FoodPlaceSearchCard card;
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
              ? const Icon(
                  Icons.restaurant_menu,
                  color: _FoodPlaceSearchCardViewState.accent,
                )
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
              ? _FoodPlaceSearchCardViewState.accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _FoodPlaceSearchCardViewState.accent
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
