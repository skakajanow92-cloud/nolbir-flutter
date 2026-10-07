import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'contact_avatar.dart';

class NewCallDialog extends StatefulWidget {
  final List<ChatContact> contacts;

  const NewCallDialog({super.key, required this.contacts});

  @override
  State<NewCallDialog> createState() => _NewCallDialogState();
}

class _NewCallDialogState extends State<NewCallDialog> {
  static const accent = Color(0xFF25D366);

  String? _selectedId;

  void _startCall({required bool isVideo}) {
    final contact = widget.contacts.firstWhere((c) => c.id == _selectedId);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${contact.name} ${isVideo ? 'görüntülü' : 'sesli'} arama başlatılıyor (mock)",
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedId == null
        ? null
        : widget.contacts.firstWhere((c) => c.id == _selectedId);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Yeni Arama",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.contacts.length,
                  itemBuilder: (context, i) {
                    final contact = widget.contacts[i];
                    final isSelected = contact.id == _selectedId;
                    return ListTile(
                      onTap: () => setState(() => _selectedId = contact.id),
                      tileColor: isSelected
                          ? accent.withValues(alpha: 0.12)
                          : null,
                      leading: ContactAvatar(
                        name: contact.name,
                        avatarUrl: contact.avatarUrl,
                        isOnline: contact.isOnline,
                      ),
                      title: Text(
                        contact.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: accent)
                          : null,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.call_outlined),
                        onPressed: selected != null
                            ? () => _startCall(isVideo: false)
                            : null,
                        label: const Text("Sesli Ara"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: accent),
                        icon: const Icon(Icons.videocam_outlined),
                        onPressed: selected != null
                            ? () => _startCall(isVideo: true)
                            : null,
                        label: const Text("Görüntülü Ara"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
