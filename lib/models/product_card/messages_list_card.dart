import '../feed_card/base.dart';

class ChatContact {
  final String id;
  final String name;
  final String avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ChatContact({
    required this.id,
    required this.name,
    this.avatarUrl = "",
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}

/// Diğer kartlardan farklı: dış bir işletme/ürün tanıtmıyor, doğrudan
/// kullanıcının kişi listesini ve sohbetlerini gösteriyor.
class MessagesListCard extends FeedCard {
  final List<ChatContact> contacts;

  const MessagesListCard({required String id, required this.contacts})
    : super(id);
}
