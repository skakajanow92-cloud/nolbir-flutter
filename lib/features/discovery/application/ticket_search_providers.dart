import 'package:flutter_riverpod/legacy.dart';

enum TripType { oneWay, roundTrip }

class TicketSearchFormState {
  final TripType tripType;
  final String from;
  final String to;
  final DateTime? departDate;
  final DateTime? returnDate;
  final int passengerCount;

  const TicketSearchFormState({
    this.tripType = TripType.roundTrip,
    this.from = "",
    this.to = "",
    this.departDate,
    this.returnDate,
    this.passengerCount = 1,
  });

  bool get isValid =>
      from.trim().isNotEmpty &&
      to.trim().isNotEmpty &&
      departDate != null &&
      (tripType == TripType.oneWay || returnDate != null);

  TicketSearchFormState copyWith({
    TripType? tripType,
    String? from,
    String? to,
    DateTime? departDate,
    DateTime? returnDate,
    int? passengerCount,
    bool clearReturnDate = false,
  }) {
    return TicketSearchFormState(
      tripType: tripType ?? this.tripType,
      from: from ?? this.from,
      to: to ?? this.to,
      departDate: departDate ?? this.departDate,
      returnDate: clearReturnDate ? null : (returnDate ?? this.returnDate),
      passengerCount: passengerCount ?? this.passengerCount,
    );
  }
}

/// `card.id` ile anahtarlanır — kullanıcı karttan uzaklaşıp geri gelse
/// (sayfa yenilense) bile doldurduğu form kaybolmaz (bkz. varyant seçimi
/// provider'ındaki aynı desen).
final ticketSearchFormProvider =
    StateProvider.family<TicketSearchFormState, String>(
      (ref, cardId) => const TicketSearchFormState(),
    );
