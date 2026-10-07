import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'contact_avatar.dart';
import 'chat_room_dialog.dart';
import 'new_group_dialog.dart';
import 'new_call_dialog.dart';

/// NOT: Diğer kartlar `CardPageScaffold` kullanıyor, ama o iskelet sabit
/// bir header + altında akan içerik varsayıyor; burada liste tüm ekranı
/// kaplayıp kendi scroll'una sahip olmalı (uzun kişi listesi). Bu yüzden
/// bilerek `CardPageScaffold` kullanılmadı — `WalletProfileCardView`'daki
/// "her kart türü ortak iskelete mecbur değil" kararıyla aynı mantık.
class MessagesListCardView extends StatelessWidget {
  final MessagesListCard card;

  const MessagesListCardView({super.key, required this.card});

  static const accent = Color(0xFF25D366);
  static const _base = Color(0xFF0E1511);
  static const _baseEnd = Color(0xFF121212);

  void _openChatRoom(BuildContext context, ChatContact contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChatRoomDialog(contact: contact),
    );
  }

  void _openNewGroup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewGroupDialog(contacts: card.contacts),
    );
  }

  void _openNewCall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewCallDialog(contacts: card.contacts),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Row(
                  children: [
                    const Text(
                      "Mesajlar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.call_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () => _openNewCall(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.group_add_outlined, color: accent),
                      onPressed: () => _openNewGroup(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: card.contacts.length,
                  itemBuilder: (context, i) {
                    final contact = card.contacts[i];
                    return ListTile(
                      onTap: () => _openChatRoom(context, contact),
                      leading: ContactAvatar(
                        name: contact.name,
                        avatarUrl: contact.avatarUrl,
                        isOnline: contact.isOnline,
                      ),
                      title: Text(
                        contact.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: contact.lastMessage != null
                          ? Text(
                              contact.lastMessage!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            )
                          : null,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (contact.lastMessageTime != null)
                            Text(
                              "${contact.lastMessageTime!.hour.toString().padLeft(2, '0')}:${contact.lastMessageTime!.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          if (contact.unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${contact.unreadCount}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
