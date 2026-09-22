import '../../../models/cart_card/ticket_cart_card.dart';
import '../../../models/ticket_cart.dart';
import '../../../models/cart.dart';
import '../../../models/travel.dart';

TicketCartCard buildTicketCartMock() {
  return TicketCartCard(
    id: "ticketcart1",
    cart: Cart(
      cartType: CartType.travelTicket,
      items: [
        CartItem(
          id: "tci1",
          cartType: CartType.travelTicket,
          title: "İstanbul → Ankara",
          price: 850,
          metadata: {
            "transportType": TransportType.flight,
            "company": "Pegasus",
            "origin": "İstanbul",
            "destination": "Ankara",
            "departureDateTime": DateTime.now().add(const Duration(days: 6, hours: 3)),
            "selectedSeat": "14A",
            "availableSeats": const <SeatOption>[],
          },
        ),
        CartItem(
          id: "tci2",
          cartType: CartType.travelTicket,
          title: "Ankara → İzmir",
          price: 420,
          metadata: {
            "transportType": TransportType.bus,
            "company": "Metro Turizm",
            "origin": "Ankara",
            "destination": "İzmir",
            "departureDateTime": DateTime.now().add(const Duration(days: 8, hours: 20)),
            // Koltuk henüz seçilmedi — availableSeats dolu, selectedSeat yok.
            "availableSeats": const [
              SeatOption(seatNumber: "5", isWindowSeat: true),
              SeatOption(seatNumber: "6"),
              SeatOption(seatNumber: "11", isWindowSeat: true, extraPrice: 15),
            ],
          },
        ),
      ],
    ),
    alternatives: [
      AlternativeRouteGroup(
        id: "alt1",
        origin: "İstanbul",
        destination: "Ankara",
        options: [
          AlternativeTicketOption(
            id: "opt1",
            company: "Pegasus",
            transportType: TransportType.flight,
            departureDateTime: DateTime.now().add(const Duration(days: 6, hours: 3)),
            price: 850,
            durationMinutes: 70,
            seatsAvailable: 12,
          ),
          AlternativeTicketOption(
            id: "opt2",
            company: "Turkish Airlines",
            transportType: TransportType.flight,
            departureDateTime: DateTime.now().add(const Duration(days: 6, hours: 6)),
            price: 1150,
            durationMinutes: 65,
            seatsAvailable: 4,
          ),
          AlternativeTicketOption(
            id: "opt3",
            company: "TCDD Taşımacılık",
            transportType: TransportType.train,
            departureDateTime: DateTime.now().add(const Duration(days: 6, hours: 1)),
            price: 380,
            durationMinutes: 260,
            seatsAvailable: 40,
          ),
        ],
      ),
      AlternativeRouteGroup(
        id: "alt2",
        origin: "Ankara",
        destination: "İzmir",
        options: [
          AlternativeTicketOption(
            id: "opt4",
            company: "Metro Turizm",
            transportType: TransportType.bus,
            departureDateTime: DateTime.now().add(const Duration(days: 8, hours: 20)),
            price: 420,
            durationMinutes: 300,
            seatsAvailable: 3,
          ),
          AlternativeTicketOption(
            id: "opt5",
            company: "Kamil Koç",
            transportType: TransportType.bus,
            departureDateTime: DateTime.now().add(const Duration(days: 8, hours: 22)),
            price: 390,
            durationMinutes: 310,
            seatsAvailable: 18,
          ),
        ],
      ),
    ],
  );
}
