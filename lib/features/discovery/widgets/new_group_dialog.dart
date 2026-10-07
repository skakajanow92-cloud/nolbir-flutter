import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'contact_avatar.dart';

class NewGroupDialog extends StatefulWidget {
  final List<ChatContact> contacts;

  const NewGroupDialog({super.key, required this.contacts});

  @override
  State<NewGroupDialog> createState() => _NewGroupDialogState();
}

class _NewGroupDialogState extends State<NewGroupDialog> {
  static const accent = Color(0xFF25D366);

  final _nameController = TextEditingController();
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _selectedIds.isNotEmpty;

  void _createGroup() {
    // NOT: Gerçek grup oluşturma backend bağlanınca eklenecek.
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "\"${_nameController.text.trim()}\" grubu ${_selectedIds.length} kişiyle oluşturuldu (mock)",
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Yeni Grup",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: "Grup adı",
                        labelStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Katılımcı seç (${_selectedIds.length})",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.contacts.length,
                  itemBuilder: (context, i) {
                    final contact = widget.contacts[i];
                    final selected = _selectedIds.contains(contact.id);
                    return CheckboxListTile(
                      value: selected,
                      activeColor: accent,
                      onChanged: (_) => setState(() {
                        selected
                            ? _selectedIds.remove(contact.id)
                            : _selectedIds.add(contact.id);
                      }),
                      secondary: ContactAvatar(
                        name: contact.name,
                        avatarUrl: contact.avatarUrl,
                      ),
                      title: Text(
                        contact.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    onPressed: _isValid ? _createGroup : null,
                    child: const Text("Grup Oluştur"),
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
