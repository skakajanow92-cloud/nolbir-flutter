import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';

/// AYRI, tıbbi kanala bağlanma yer tutucusu — mesajlaşma kartındaki
/// `NewCallDialog`'un `_startCall`'ından KASITLI olarak bağımsız. Gerçek
/// entegrasyonda bu fonksiyon genel arama altyapısına DEĞİL, ayrı bir
/// medikal-görüşme servisine istek atmalı (bkz. HealthVideoCallCard
/// yorumları).
Future<void> connectToMedicalChannel(
  BuildContext context, {
  required MedicalSpecialty specialty,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF0E1A1A),
      content: Row(
        children: [
          const CircularProgressIndicator(color: Color(0xFF1FA2A6)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "${specialty.label} branşından bir uzman aranıyor...",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

class InstantConsultDialog extends StatelessWidget {
  final List<MedicalSpecialty> specialties;

  const InstantConsultDialog({super.key, required this.specialties});

  static const accent = Color(0xFF1FA2A6);

  Future<void> _connect(
    BuildContext context,
    MedicalSpecialty specialty,
  ) async {
    Navigator.of(context).pop(); // seçim dialog'unu kapat
    await connectToMedicalChannel(context, specialty: specialty);
    // NOT: Gerçek bağlantı sonucu (uzman bulundu/bulunamadı) backend'den
    // gelecek — şimdilik sabit bir gecikme sonrası mock onay.
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // "aranıyor" dialog'u
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${specialty.label} ile bağlantı kuruldu (mock)"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
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
                "Hemen Görüş",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Hangi branştan bir uzmana bağlanmak istersiniz?",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final specialty in specialties)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: accent),
                      onPressed: () => _connect(context, specialty),
                      icon: const Icon(Icons.videocam_outlined),
                      label: Text(specialty.label),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
