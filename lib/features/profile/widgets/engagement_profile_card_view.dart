import 'package:flutter/material.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/engagement.dart';
import '../../../core/widgets/page_aware_scroll_view.dart';

/// Etkileşim Analizi Profili — yedinci profil modülü.
///
/// TASARIM NOTU: Bu modül somut varlıklar (hesap, poliçe, bilet, mekan...)
/// değil, sayısal bir özet + iki liste (referanslar, en çok tartışılan
/// gönderiler) gösteriyor. Food modülündeki gibi tek ekrana sığmayabilecek
/// içerik olduğu için dikey `SingleChildScrollView` kullanıldı.
///
/// Modül vurgu rengi: koyu petrol-teal — önceki altı modülden (bordo/
/// zümrüt/indigo/amber/mor/hardal) ayrışan, "veri/analiz" hissi.
class EngagementProfileCardView extends StatelessWidget {
  final EngagementProfileCard card;

  const EngagementProfileCardView({super.key, required this.card});

  static const moduleAccent = Color(0xFF2E6E7A);
  static const _base = Color(0xFF0D1214);
  static const _baseEnd = Color(0xFF151C1E);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final summary = card.summary;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_base, _baseEnd],
          ),
        ),
        child: SafeArea(
          child: PageAwareScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Header(summary: summary),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _StatsGrid(summary: summary),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text: "Referanslar & Tavsiyeler (${card.referrals.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: card.referrals.isEmpty
                      ? const _EmptyHint(text: "Henüz referans/tavsiye yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.referrals.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _ReferralMiniCard(referral: card.referrals[i]),
                        ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  text:
                      "En Çok Tartışılan Gönderiler (${card.topDiscussions.length})",
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: card.topDiscussions.isEmpty
                      ? const _EmptyHint(text: "Henüz yorum/tartışma yok")
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: card.topDiscussions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _DiscussionMiniCard(
                            discussion: card.topDiscussions[i],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final EngagementSummary summary;
  const _Header({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.insights_outlined,
              color: EngagementProfileCardView.moduleAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Etkileşim",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${summary.followerCount}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                "takipçi",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "${summary.followingCount}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Text(
                "takip",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final EngagementSummary summary;
  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String)>[
      ("Gönderi", "${summary.totalPosts}"),
      ("İzlenim", _formatCompact(summary.totalImpressions)),
      ("Yorum", "${summary.totalComments}"),
      ("Tartışma", "${summary.totalReplies}"),
      ("Referans", "${summary.totalReferrals}"),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: stats.map((s) => _StatChip(label: s.$1, value: s.$2)).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: EngagementProfileCardView.moduleAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: EngagementProfileCardView.moduleAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ),
    );
  }
}

class _ReferralMiniCard extends StatelessWidget {
  final ReferralMention referral;
  const _ReferralMiniCard({required this.referral});

  @override
  Widget build(BuildContext context) {
    final color = _personColor(referral.fromUsername);

    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconFor(referral.type), color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "@${referral.fromUsername}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            referral.type.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (referral.note != null) ...[
            const SizedBox(height: 6),
            Text(
              referral.note!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
          const Spacer(),
          Text(
            _formatDate(referral.date),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DiscussionMiniCard extends StatelessWidget {
  final PostDiscussion discussion;
  const _DiscussionMiniCard({required this.discussion});

  @override
  Widget build(BuildContext context) {
    final color = _personColor(discussion.postCaption);

    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            discussion.postCaption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.mode_comment_outlined, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                "${discussion.commentCount} yorum",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.forum_outlined, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                "${discussion.replyCount} tartışma",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${_formatCompact(discussion.impressionCount)} izlenim",
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(ReferralType type) => switch (type) {
  ReferralType.mention => Icons.alternate_email,
  ReferralType.recommendation => Icons.thumb_up_outlined,
  ReferralType.share => Icons.ios_share,
};

// Kişi/gönderi başına sabit, elle seçilmiş uyumlu bir palet (bkz. diğer
// modüllerdeki aynı yaklaşım).
const _personPalette = <Color>[
  Color(0xFF255A5F),
  Color(0xFF3E4A5A),
  Color(0xFF2E5A4A),
  Color(0xFF3E5A57),
];

Color _personColor(String seed) {
  final index = seed.hashCode.abs() % _personPalette.length;
  return _personPalette[index];
}

String _formatDate(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

String _formatCompact(int value) {
  if (value >= 1000000) return "${(value / 1000000).toStringAsFixed(1)}M";
  if (value >= 1000) return "${(value / 1000).toStringAsFixed(1)}B";
  return "$value";
}
