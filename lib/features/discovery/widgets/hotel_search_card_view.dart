import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import 'hotel_options_dialog.dart';

/// NOT: Bu kartın state'i şimdilik tamamen local (StatefulWidget). Diğer
/// form kartlarında (TicketSearchCard) olduğu gibi `card.id`'ye bağlı
/// kalıcı bir provider'a BİLEREK taşımadım — "önce tüm arayüzler, sonra
/// ortak state yönetimi" kararının bir parçası. Kart ekrandan çıkıp
/// geri gelirse (PageView dispose eder) doldurulan form şu an kaybolur;
/// bu bilinen, kabul edilmiş bir eksik — refactor turunda diğer form
/// kartlarıyla aynı kalıcı state desenine taşınacak.
class HotelSearchCardView extends StatefulWidget {
  final HotelSearchCard card;

  const HotelSearchCardView({super.key, required this.card});

  @override
  State<HotelSearchCardView> createState() => _HotelSearchCardViewState();
}

class _HotelSearchCardViewState extends State<HotelSearchCardView> {
  static const _base = Color(0xFF14101F);
  static const _baseEnd = Color(0xFF1C1a30);
  static const accent = Color(0xFF6CA0F0);

  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  StayType _stayType = StayType.nightly;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _hourlyDurationHours = 3;
  int _guestCount = 2;
  int _roomCount = 1;
  bool _petFriendly = false;
  bool _wifiRequired = false;
  MealPlan _mealPlan = MealPlan.none;

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final hasLocation =
        _cityController.text.trim().isNotEmpty ||
        _countryController.text.trim().isNotEmpty;
    final hasDates = _stayType == StayType.hourly
        ? _checkIn != null
        : (_checkIn != null &&
              _checkOut != null &&
              _checkOut!.isAfter(_checkIn!));
    return hasLocation && hasDates;
  }

  Future<void> _pickDate({required bool isCheckOut}) async {
    final now = DateTime.now();
    final initial =
        (isCheckOut ? _checkOut : _checkIn) ??
        (isCheckOut ? (_checkIn ?? now) : now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckOut) {
        _checkOut = picked;
      } else {
        _checkIn = picked;
        if (_checkOut != null && !_checkOut!.isAfter(picked)) _checkOut = null;
      }
    });
  }

  void _applyDestinationChip(String destination) {
    // Basit bir dağıtım: ilk boş alana yaz. Gerçek autocomplete gelince
    // (ülke/kent/mahalle ayrımı backend'den) bu kalkacak.
    setState(() {
      if (_cityController.text.trim().isEmpty) {
        _cityController.text = destination;
      } else if (_neighborhoodController.text.trim().isEmpty) {
        _neighborhoodController.text = destination;
      }
    });
  }

  void _openResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HotelOptionsDialog(
        destinationLabel: [
          _neighborhoodController.text,
          _cityController.text,
          _countryController.text,
        ].where((s) => s.trim().isNotEmpty).join(", "),
        guestCount: _guestCount,
        roomCount: _roomCount,
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
            const _FieldLabel("Konum"),
            const SizedBox(height: 8),
            _TextInput(label: "Ülke", controller: _countryController),
            const SizedBox(height: 8),
            _TextInput(label: "Kent", controller: _cityController),
            const SizedBox(height: 8),
            _TextInput(
              label: "Mahalle (opsiyonel)",
              controller: _neighborhoodController,
            ),
            if (widget.card.popularDestinations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.card.popularDestinations
                    .map(
                      (d) => ActionChip(
                        label: Text(d, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        onPressed: () => _applyDestinationChip(d),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            const _FieldLabel("Konaklama Türü"),
            const SizedBox(height: 8),
            Row(
              children: [
                _ToggleChip(
                  label: "Gecelik",
                  selected: _stayType == StayType.nightly,
                  onTap: () => setState(() => _stayType = StayType.nightly),
                ),
                const SizedBox(width: 8),
                _ToggleChip(
                  label: "Saatlik",
                  selected: _stayType == StayType.hourly,
                  onTap: () => setState(() => _stayType = StayType.hourly),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_stayType == StayType.nightly)
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: "Giriş",
                      date: _checkIn,
                      onTap: () => _pickDate(isCheckOut: false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      label: "Çıkış",
                      date: _checkOut,
                      onTap: () => _pickDate(isCheckOut: true),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: "Tarih",
                      date: _checkIn,
                      onTap: () => _pickDate(isCheckOut: false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StepperField(
                      label: "Süre (saat)",
                      value: _hourlyDurationHours,
                      min: 1,
                      max: 12,
                      onChanged: (v) =>
                          setState(() => _hourlyDurationHours = v),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const _FieldLabel("Misafir ve Oda"),
            const SizedBox(height: 10),
            _StepperRow(
              label: "Misafir sayısı",
              value: _guestCount,
              min: 1,
              max: 12,
              onChanged: (v) => setState(() => _guestCount = v),
            ),
            const SizedBox(height: 8),
            _StepperRow(
              label: "Oda sayısı",
              value: _roomCount,
              min: 1,
              max: 6,
              onChanged: (v) => setState(() => _roomCount = v),
            ),
            const SizedBox(height: 20),
            const _FieldLabel("Tercihler"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ToggleChip(
                  label: "Evcil Hayvan Dostu",
                  selected: _petFriendly,
                  onTap: () => setState(() => _petFriendly = !_petFriendly),
                ),
                _ToggleChip(
                  label: "Wi-Fi",
                  selected: _wifiRequired,
                  onTap: () => setState(() => _wifiRequired = !_wifiRequired),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MealPlan.values
                  .map(
                    (m) => _ToggleChip(
                      label: m.label,
                      selected: _mealPlan == m,
                      onTap: () => setState(() => _mealPlan = m),
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
                child: const Text("Otel ara"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HotelSearchCard card;
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
                  Icons.hotel_outlined,
                  color: _HotelSearchCardViewState.accent,
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

class _TextInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _TextInput({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
              ? _HotelSearchCardViewState.accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _HotelSearchCardViewState.accent : Colors.white24,
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

class _StepperField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _StepperField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Text(
                "$value",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.white54,
              ),
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            Text(
              "$value",
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
