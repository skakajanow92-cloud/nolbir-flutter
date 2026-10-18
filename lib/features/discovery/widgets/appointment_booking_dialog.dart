import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

class AppointmentBookingDialog extends StatelessWidget {
  final DoctorAppointmentCard doctor;
  final AppointmentSlot slot;

  const AppointmentBookingDialog({
    super.key,
    required this.doctor,
    required this.slot,
  });

  static const accent = Color(0xFF1FA2A6);

  String _formatDateTime(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} · "
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                "Randevu Özeti",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _Row(label: "Doktor", value: doctor.doctorName),
              _Row(label: "Branş", value: doctor.specialty.label),
              _Row(label: "Klinik", value: doctor.clinicName),
              _Row(
                label: "Tarih / Saat",
                value: _formatDateTime(slot.dateTime),
              ),
              _Row(
                label: "Tür",
                value: slot.isOnline ? "Online Görüntülü" : "Yüz Yüze",
              ),
              _Row(
                label: "Ücret",
                value:
                    "${doctor.consultationFee.toStringAsFixed(0)} ${doctor.currency}",
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    // NOT: Gerçek randevu oluşturma/ödeme backend
                    // bağlanınca eklenecek.
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Randevunuz oluşturuldu (mock)"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text("Randevuyu Onayla"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
