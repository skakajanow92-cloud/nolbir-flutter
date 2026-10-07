import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import 'contact_avatar.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMine;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.sentAt,
  });
}

List<ChatMessage> _mockHistory(ChatContact contact) {
  final now = DateTime.now();
  return [
    ChatMessage(
      id: "1",
      text: "Selam, nasılsın?",
      isMine: false,
      sentAt: now.subtract(const Duration(minutes: 40)),
    ),
    ChatMessage(
      id: "2",
      text: "İyiyim, sağ ol! Sen nasılsın?",
      isMine: true,
      sentAt: now.subtract(const Duration(minutes: 38)),
    ),
    if (contact.lastMessage != null)
      ChatMessage(
        id: "3",
        text: contact.lastMessage!,
        isMine: false,
        sentAt:
            contact.lastMessageTime ?? now.subtract(const Duration(minutes: 5)),
      ),
  ];
}

class ChatRoomDialog extends StatefulWidget {
  final ChatContact contact;

  const ChatRoomDialog({super.key, required this.contact});

  @override
  State<ChatRoomDialog> createState() => _ChatRoomDialogState();
}

class _ChatRoomDialogState extends State<ChatRoomDialog> {
  static const accent = Color(0xFF25D366);

  late final List<ChatMessage> _messages;
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages = _mockHistory(widget.contact);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: "m${_messages.length}",
          text: text,
          isMine: true,
          sentAt: DateTime.now(),
        ),
      );
      _inputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    ContactAvatar(
                      name: widget.contact.name,
                      avatarUrl: widget.contact.avatarUrl,
                      isOnline: widget.contact.isOnline,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.contact.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.contact.isOnline
                                ? "Çevrimiçi"
                                : "Son görülme bilinmiyor",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.call_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.videocam_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) =>
                      _MessageBubble(message: _messages[i]),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Mesaj yaz...",
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.06),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: accent,
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        onPressed: _send,
                      ),
                    ],
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final align = message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMine
        ? _ChatRoomDialogState.accent.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.08);

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              "${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
