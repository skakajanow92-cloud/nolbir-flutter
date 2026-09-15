import '../channel.dart';
import 'base.dart';

/// On birinci profil modülü: kullanıcının oluşturup yönettiği kanallar —
/// YouTube benzeri, uzun video içerikleri paylaşılan kanallar. Her kanal
/// kendi abone/izlenme/video/yorum verisine sahip (bkz. channel.dart'taki
/// çoklu-varlık deseni — WalletProfileCard'daki "birden fazla hesap"
/// yaklaşımına benzer, ama EngagementProfileCard'daki (7. modül) genel
/// profil etkileşim özetinden BAĞIMSIZ).
class ChannelsProfileCard extends FeedCard implements Collectible {
  final List<Channel> channels;

  const ChannelsProfileCard({required String id, this.channels = const []})
    : super(id);

  int get totalSubscribers =>
      channels.fold(0, (sum, c) => sum + c.subscriberCount);

  int get totalViews => channels.fold(0, (sum, c) => sum + c.totalViews);

  int get totalVideos => channels.fold(0, (sum, c) => sum + c.videoCount);

  int get totalUnreviewedComments =>
      channels.fold(0, (sum, c) => sum + c.unreviewedCommentCount);

  @override
  (String, String) toCollectionPreview() => ("Kanallar Profili", "");
}
