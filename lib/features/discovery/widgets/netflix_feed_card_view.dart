import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_card/product_card.dart';
import '../../../models/cart.dart';
import '../../cart/application/cart_providers.dart';
import 'nav_arrow_buttons.dart';
import 'adult_gate_dialog.dart';
import 'subscription_plans_dialog.dart';
import 'streaming_title_detail_dialog.dart';

class NetflixFeedCardView extends ConsumerStatefulWidget {
  final NetflixFeedCard card;

  const NetflixFeedCardView({super.key, required this.card});

  @override
  ConsumerState<NetflixFeedCardView> createState() =>
      _NetflixFeedCardViewState();
}

class _NetflixFeedCardViewState extends ConsumerState<NetflixFeedCardView> {
  //static const accent = Color(0xFFE50914);

  SubscriptionTier? _subscribedTier;
  bool _hasAdultAddon = false;
  bool _adultAgeConfirmedThisSession = false;

  bool _hasAccess(StreamingTitle title) {
    if (title.isAdult && !_hasAdultAddon) return false;
    if (_subscribedTier == null) return false;
    return _subscribedTier!.index >= title.requiredTier.index;
  }

  String _missingAccessReason(StreamingTitle title) {
    if (title.isAdult && !_hasAdultAddon) {
      return "Bu içerik için Yetişkin İçerik Paketi gerekiyor.";
    }
    return "Bu içerik için ${title.requiredTier.label} plan veya üzeri gerekiyor.";
  }

  Future<void> _subscribe(SubscriptionPlan plan) async {
    setState(() {
      if (plan.isAdultAddon) {
        _hasAdultAddon = true;
      } else {
        _subscribedTier = plan.tier;
      }
    });
    await ref
        .read(cartDetailProvider(CartType.subscription).notifier)
        .addItem(
          CartItem(
            id: "${widget.card.id}_${plan.tier.name}_${plan.isAdultAddon}",
            cartType: CartType.subscription,
            title: "${widget.card.platformName} · ${plan.name}",
            price: plan.monthlyPrice,
            currency: widget.card.currency,
            metadata: {"billing": "monthly"},
          ),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${plan.name} aboneliği eklendi"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _openPlans() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubscriptionPlansDialog(
        plans: widget.card.plans,
        currency: widget.card.currency,
        onSelect: _subscribe,
      ),
    );
  }

  Future<void> _openTitle(StreamingTitle title) async {
    if (title.isAdult && !_adultAgeConfirmedThisSession) {
      final confirmed = await showAdultGateDialog(context);
      if (confirmed != true) return;
      setState(() => _adultAgeConfirmedThisSession = true);
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StreamingTitleDetailDialog(
        title: title,
        hasAccess: _hasAccess(title),
        missingAccessReason: _missingAccessReason(title),
        onRequestSubscribe: () {
          Navigator.of(context).pop();
          _openPlans();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: const Color(0xFF141414),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _Header(
                    platformName: widget.card.platformName,
                    subscribedTier: _subscribedTier,
                    onTapManage: _openPlans,
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      itemCount: widget.card.collections.length,
                      itemBuilder: (context, i) => _CollectionRow(
                        collection: widget.card.collections[i],
                        hasAdultAccess: _hasAdultAddon,
                        onTapTitle: _openTitle,
                      ),
                    ),
                  ),
                ],
              ),
              const NavArrowOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String platformName;
  final SubscriptionTier? subscribedTier;
  final VoidCallback onTapManage;
  const _Header({
    required this.platformName,
    required this.subscribedTier,
    required this.onTapManage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          Text(
            platformName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTapManage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                subscribedTier == null
                    ? "Abone değilsiniz"
                    : "${subscribedTier!.label} Plan",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  final StreamingCollection collection;
  final bool hasAdultAccess;
  final ValueChanged<StreamingTitle> onTapTitle;
  const _CollectionRow({
    required this.collection,
    required this.hasAdultAccess,
    required this.onTapTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              Text(
                collection.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (collection.isAdultCollection && !hasAdultAccess) ...[
                const SizedBox(width: 6),
                const Icon(Icons.lock_outline, color: Colors.amber, size: 14),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: collection.titles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _PosterTile(
              title: collection.titles[i],
              isLocked: collection.isAdultCollection && !hasAdultAccess,
              onTap: () => onTapTitle(collection.titles[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _PosterTile extends StatelessWidget {
  final StreamingTitle title;
  final bool isLocked;
  final VoidCallback onTap;
  const _PosterTile({
    required this.title,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 102,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.white.withValues(alpha: 0.06),
                      child: title.posterUrl.isEmpty
                          ? const Icon(
                              Icons.movie_outlined,
                              color: Colors.white24,
                            )
                          : Image.network(title.posterUrl, fit: BoxFit.cover),
                    ),
                    if (isLocked)
                      Container(
                        color: Colors.black.withValues(alpha: 0.55),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                    if (title.type == StreamingContentType.liveChannel)
                      Positioned(
                        left: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "CANLI",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
