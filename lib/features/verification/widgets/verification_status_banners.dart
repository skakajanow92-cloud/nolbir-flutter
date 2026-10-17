import 'package:flutter/material.dart';

/// `national_document_card_view.dart`/`international_document_card_view.dart`/
/// `full_access_request_card_view.dart` arasında PAYLAŞILAN iki küçük
/// durum göstergesi — admin onayı bekleyen adımlar hepsinde aynı görünmeli,
/// bu yüzden kopya kod yerine tek yerde tutuluyor (bkz. `MediaPicker`/
/// `FullAccessGate` ile aynı merkezileştirme ilkesi).
class PendingNotice extends StatelessWidget {
  final String title;
  final String message;
  const PendingNotice({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top_outlined, color: Colors.white38, size: 40),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class RejectionBanner extends StatelessWidget {
  final String reason;
  const RejectionBanner({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text("Önceki başvuru reddedildi: $reason",
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
