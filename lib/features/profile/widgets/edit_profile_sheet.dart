import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/feed_card/feed_card.dart';
import '../application/profile_providers.dart';
import 'profile_header_card_view.dart';

/// "Temel Bilgiler" kartındaki Düzenle butonundan açılan form.
///
/// NOT: Kaydet, şu an yalnızca `ProfileFeed.updateHeader` üzerinden yerel
/// state'i günceller — gerçek persist (repository/API çağrısı) backend
/// adımında eklenecek.
class EditProfileSheet extends ConsumerStatefulWidget {
  final ProfileHeaderCard card;

  const EditProfileSheet({super.key, required this.card});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  static const _genders = ["Kadın", "Erkek", "Belirtmek istemiyorum"];

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _username;
  late final TextEditingController _country;
  late final TextEditingController _bio;
  late String _gender;

  @override
  void initState() {
    super.initState();
    final c = widget.card;
    _firstName = TextEditingController(text: c.firstName);
    _lastName = TextEditingController(text: c.lastName);
    _username = TextEditingController(text: c.username);
    _country = TextEditingController(text: c.country);
    _bio = TextEditingController(text: c.bio);
    _gender = c.gender.isNotEmpty ? c.gender : _genders.first;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _country.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.card.copyWith(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      username: _username.text.trim(),
      country: _country.text.trim(),
      bio: _bio.text.trim(),
      gender: _gender,
    );
    ref.read(profileFeedProvider.notifier).updateHeader(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Temel bilgileri düzenle",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _field("Ad", _firstName)),
                  const SizedBox(width: 12),
                  Expanded(child: _field("Soyad", _lastName)),
                ],
              ),
              const SizedBox(height: 12),
              _field("Kullanıcı adı", _username, prefix: "@"),
              const SizedBox(height: 12),
              _field("Ülke", _country),
              const SizedBox(height: 12),
              _genderSelector(),
              const SizedBox(height: 12),
              _field("Biyografi", _bio, maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ProfileHeaderCardView.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _save,
                  child: const Text("Kaydet"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(String label, TextEditingController controller,
      {String? prefix, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ProfileHeaderCardView.accent),
        ),
      ),
    );
  }

  Widget _genderSelector() {
    return Wrap(
      spacing: 8,
      children: _genders.map((g) {
        final selected = g == _gender;
        return ChoiceChip(
          label: Text(g),
          selected: selected,
          onSelected: (_) => setState(() => _gender = g),
          selectedColor: ProfileHeaderCardView.accent,
          backgroundColor: Colors.white10,
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
        );
      }).toList(),
    );
  }
}
