import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

class DatingFilterDialog extends StatefulWidget {
  final DatingFilterPreferences initialFilters;
  final ValueChanged<DatingFilterPreferences> onApply;

  const DatingFilterDialog({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<DatingFilterDialog> createState() => _DatingFilterDialogState();
}

class _DatingFilterDialogState extends State<DatingFilterDialog> {
  static const accent = Color(0xFFFF5864);

  late RangeValues _ageRange;
  late double _maxDistance;
  late GenderPreference _gender;

  @override
  void initState() {
    super.initState();
    _ageRange = RangeValues(
      widget.initialFilters.minAge.toDouble(),
      widget.initialFilters.maxAge.toDouble(),
    );
    _maxDistance = widget.initialFilters.maxDistanceKm;
    _gender = widget.initialFilters.genderPreference;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF17121A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                "Filtreler",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Yaş aralığı: ${_ageRange.start.round()} - ${_ageRange.end.round()}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              RangeSlider(
                values: _ageRange,
                min: 18,
                max: 65,
                divisions: 47,
                activeColor: accent,
                onChanged: (v) => setState(() => _ageRange = v),
              ),
              const SizedBox(height: 10),
              Text(
                "Maksimum mesafe: ${_maxDistance.round()} km",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Slider(
                value: _maxDistance,
                min: 1,
                max: 200,
                activeColor: accent,
                onChanged: (v) => setState(() => _maxDistance = v),
              ),
              const SizedBox(height: 14),
              const Text(
                "Tercih",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: GenderPreference.values
                    .map(
                      (g) => ChoiceChip(
                        label: Text(g.label),
                        selected: _gender == g,
                        selectedColor: accent.withValues(alpha: 0.3),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        labelStyle: const TextStyle(color: Colors.white),
                        onSelected: (_) => setState(() => _gender = g),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    widget.onApply(
                      DatingFilterPreferences(
                        minAge: _ageRange.start.round(),
                        maxAge: _ageRange.end.round(),
                        maxDistanceKm: _maxDistance,
                        genderPreference: _gender,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text("Filtreleri Uygula"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
