import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Belge yükleme satırı: dosya seç / kaldır, resim önizlemesi (PDF için
/// ikon) ve belge yüklendiyse opsiyonel "Belge No" alanı.
///
/// BİLİNÇLİ OLARAK modelden bağımsız: `AdminDocument`, `UploadedDocument`
/// gibi tipleri değil, düz değerleri (isim, bayt, vb.) alıyor. Böylece
/// bundan sonraki her belge-yüklemeli form (alt şirket kurma, çalışma
/// başvurusu...) kendi modelini koruyarak aynı satırı kullanabilir.
class DocumentUploadTile extends StatefulWidget {
  final String label;
  final String description;
  final bool isRequired;
  final String? fileName;
  final Uint8List? bytes;
  final bool isImage;
  final String? documentNumber;
  final Color accent;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final ValueChanged<String> onDocumentNumberChanged;

  const DocumentUploadTile({
    super.key,
    required this.label,
    required this.description,
    required this.accent,
    required this.onPick,
    required this.onRemove,
    required this.onDocumentNumberChanged,
    this.isRequired = false,
    this.fileName,
    this.bytes,
    this.isImage = false,
    this.documentNumber,
  });

  @override
  State<DocumentUploadTile> createState() => _DocumentUploadTileState();
}

class _DocumentUploadTileState extends State<DocumentUploadTile> {
  late final TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _numberController =
        TextEditingController(text: widget.documentNumber ?? "");
  }

  @override
  void didUpdateWidget(covariant DocumentUploadTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dosya değişti/kaldırıldıysa numara alanını da sıfırla; kullanıcı
    // yazarken (dosya aynı) alana dokunma.
    if (oldWidget.fileName != widget.fileName) {
      _numberController.text = widget.documentNumber ?? "";
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploaded = widget.fileName != null;
    final accent = widget.accent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (uploaded ? accent : Colors.white)
            .withValues(alpha: uploaded ? 0.14 : 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: uploaded ? accent.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Preview(
                bytes: widget.bytes,
                isImage: widget.isImage,
                uploaded: uploaded,
                accent: accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (widget.isRequired) ...[
                          const SizedBox(width: 4),
                          const Text("*",
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 13)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      uploaded ? widget.fileName! : widget.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: uploaded ? Colors.white70 : Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  uploaded ? Icons.close : Icons.upload_file_outlined,
                  color: uploaded ? Colors.white54 : accent,
                ),
                onPressed: uploaded ? widget.onRemove : widget.onPick,
              ),
            ],
          ),
          if (uploaded) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _numberController,
              onChanged: widget.onDocumentNumberChanged,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                labelText: "Belge No (opsiyonel)",
                labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final Uint8List? bytes;
  final bool isImage;
  final bool uploaded;
  final Color accent;

  const _Preview({
    required this.bytes,
    required this.isImage,
    required this.uploaded,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (!uploaded) {
      return _box(
        Colors.white.withValues(alpha: 0.06),
        const Icon(Icons.description_outlined, color: Colors.white24, size: 20),
      );
    }
    if (isImage && bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          bytes!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fileIcon(),
        ),
      );
    }
    // PDF/diğer: gerçek sayfa önizlemesi için ayrı bir PDF render paketi
    // gerekir; şimdilik dosya türü ikonla gösteriliyor.
    return _fileIcon();
  }

  Widget _fileIcon() => _box(
        accent.withValues(alpha: 0.25),
        Icon(Icons.picture_as_pdf_outlined, color: accent, size: 20),
      );

  Widget _box(Color color, Widget child) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
}
