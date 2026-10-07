import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/product_card/product_card.dart';
import '../../../core/widgets/vertical_card_feed.dart';

class SocialFeedCardView extends StatefulWidget {
  final SocialFeedCard card;

  const SocialFeedCardView({super.key, required this.card});

  @override
  State<SocialFeedCardView> createState() => _SocialFeedCardViewState();
}

class _SocialFeedCardViewState extends State<SocialFeedCardView> {
  static const accent = Color(0xFFE1306C);

  late final List<SocialPost> _posts;
  final Set<String> _likedIds = {};
  final ScrollController _scrollController = ScrollController();
  int _generatedCount = 0;

  @override
  void initState() {
    super.initState();
    _posts = List.of(widget.card.seedPosts);
    _generatedCount = _posts.length;
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_maybeLoadMore);
    _scrollController.dispose();
    super.dispose();
  }

  /// "Sonsuz" akış illüzyonu: gerçek bir sayfalama API'si yok, sınıra
  /// yaklaşılınca deterministik olarak yeni mock gönderiler üretiliyor.
  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 600;
    if (_scrollController.position.pixels >= threshold) {
      setState(() {
        _posts.addAll(_generateMorePosts(widget.card.id, _generatedCount, 6));
        _generatedCount += 6;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedController = VerticalFeedController.maybeOf(context);

    return SizedBox.expand(
      child: Container(
        color: const Color(0xFF0B0B0B),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _StoriesRow(stories: widget.card.stories),
                  const Divider(color: Colors.white12, height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _posts.length,
                      itemBuilder: (context, i) => _PostTile(
                        post: _posts[i],
                        isLiked: _likedIds.contains(_posts[i].id),
                        onToggleLike: () => setState(() {
                          _likedIds.contains(_posts[i].id)
                              ? _likedIds.remove(_posts[i].id)
                              : _likedIds.add(_posts[i].id);
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              if (feedController != null)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NavArrowButton(
                          icon: Icons.keyboard_arrow_up,
                          onTap: feedController.previousPage,
                        ),
                        const SizedBox(height: 10),
                        _NavArrowButton(
                          icon: Icons.keyboard_arrow_down,
                          onTap: feedController.nextPage,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

List<SocialPost> _generateMorePosts(String cardId, int startIndex, int count) {
  final rnd = Random(cardId.hashCode + startIndex);
  const usernames = [
    "kaan.y",
    "selin_",
    "mertcan",
    "deniz.k",
    "ayseozcan",
    "burak_d",
  ];
  const captions = [
    "Bugün harika bir gündü ☀️",
    "Yeni projeme başlıyorum 🚀",
    "Bu manzaraya bayıldım 🌄",
    "Kahve molası ☕",
    "Hafta sonu planları",
    "Bunu paylaşmadan duramadım",
  ];
  return List.generate(count, (i) {
    final n = startIndex + i;
    return SocialPost(
      id: "post_${cardId}_$n",
      username: usernames[rnd.nextInt(usernames.length)],
      imageUrl: "",
      caption: captions[rnd.nextInt(captions.length)],
      likeCount: 20 + rnd.nextInt(2000),
      commentCount: rnd.nextInt(200),
      postedAt: DateTime.now().subtract(Duration(hours: n)),
    );
  });
}

class _StoriesRow extends StatelessWidget {
  final List<StoryItem> stories;
  const _StoriesRow({required this.stories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _StoryBubble(story: stories[i]),
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final StoryItem story;
  const _StoryBubble({required this.story});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: story.isViewed
                  ? null
                  : const LinearGradient(
                      colors: [
                        Color(0xFFFEDA75),
                        Color(0xFFE1306C),
                        Color(0xFF833AB4),
                      ],
                    ),
              border: story.isViewed
                  ? Border.all(color: Colors.white24, width: 2)
                  : null,
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              child: story.avatarUrl.isEmpty
                  ? Text(
                      story.username.isNotEmpty
                          ? story.username[0].toUpperCase()
                          : "?",
                      style: const TextStyle(color: Colors.white),
                    )
                  : ClipOval(
                      child: Image.network(
                        story.avatarUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            story.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  final SocialPost post;
  final bool isLiked;
  final VoidCallback onToggleLike;
  const _PostTile({
    required this.post,
    required this.isLiked,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  child: post.avatarUrl.isEmpty
                      ? Text(
                          post.username.isNotEmpty
                              ? post.username[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        )
                      : ClipOval(
                          child: Image.network(
                            post.avatarUrl,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  post.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.white38, size: 18),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.white.withValues(alpha: 0.05),
              child: post.imageUrl.isEmpty
                  ? const Icon(
                      Icons.image_outlined,
                      color: Colors.white24,
                      size: 48,
                    )
                  : Image.network(post.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked
                        ? _SocialFeedCardViewState.accent
                        : Colors.white70,
                  ),
                  onPressed: onToggleLike,
                ),
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.send_outlined,
                  color: Colors.white70,
                  size: 22,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              "${post.likeCount + (isLiked ? 1 : 0)} beğenme",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${post.username} ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: post.caption,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          if (post.commentCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Text(
                "${post.commentCount} yorumun tümünü gör",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
