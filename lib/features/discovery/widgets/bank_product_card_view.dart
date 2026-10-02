import 'package:flutter/material.dart';
import '../../../core/widgets/card_page_scaffold.dart';
import '../../../models/product_card/product_card.dart';
import '../../collection/widgets/save_to_collection_button.dart';

/// Banka ürünü kartı — kredi, vadesiz hesap ya da vadeli mevduat.
/// Üç ürün türü de aynı üst kısmı (logo, banka adı, reklam metni,
/// puanlama) paylaşır; gövde `card.productType`'a göre değişir.
class BankProductCardView extends StatelessWidget {
  final BankProductCard card;

  const BankProductCardView({super.key, required this.card});

  static const _base = Color(0xFF0D1420);
  static const _baseEnd = Color(0xFF141C2B);
  static const accent = Color(0xFF3E7BFA);

  @override
  Widget build(BuildContext context) {
    return CardPageScaffold(
      baseColor: _base,
      baseEndColor: _baseEnd,
      header: _Header(card: card),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(card.description,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.4)),
          ),
          const SizedBox(height: 20),
          if (card.imageUrls.isNotEmpty) ...[
            _ImageGallery(imageUrls: card.imageUrls),
            const SizedBox(height: 20),
          ],
          CardSectionLabel(text: _productLabel(card.productType)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ProductBody(card: card),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ActionRow(card: card),
          ),
          if (card.detailUrl != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Banka hakkında detaylı bilgi: ${card.detailUrl}",
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _productLabel(BankProductType type) {
  switch (type) {
    case BankProductType.loan:
      return "Kredi Koşulları";
    case BankProductType.checkingAccount:
      return "Hesap ve Kart";
    case BankProductType.timeDeposit:
      return "Vade Seçenekleri";
  }
}

class _Header extends StatelessWidget {
  final BankProductCard card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BankLogo(logoUrl: card.bankLogoUrl, bankName: card.bankName),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.bankName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(card.title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        _RatingBadge(rating: card.rating, reviewCount: card.reviewCount),
      ],
    );
  }
}

class _BankLogo extends StatelessWidget {
  final String logoUrl;
  final String bankName;
  const _BankLogo({required this.logoUrl, required this.bankName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: logoUrl.isEmpty
          ? Text(
              bankName.isNotEmpty ? bankName[0].toUpperCase() : "?",
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.account_balance, color: Colors.white54),
              ),
            ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;
  const _RatingBadge({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 2),
            Text(rating.toStringAsFixed(1),
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        Text("$reviewCount değerlendirme",
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  const _ImageGallery({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 220,
            color: Colors.white.withValues(alpha: 0.06),
            child: Image.network(
              imageUrls[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_outlined, color: Colors.white24),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  final BankProductCard card;
  const _ProductBody({required this.card});

  @override
  Widget build(BuildContext context) {
    switch (card.productType) {
      case BankProductType.loan:
        return _LoanBody(details: card.loanDetails!);
      case BankProductType.checkingAccount:
        return _CheckingAccountBody(details: card.checkingAccountDetails!);
      case BankProductType.timeDeposit:
        return _TimeDepositBody(details: card.timeDepositDetails!);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LoanBody extends StatelessWidget {
  final LoanDetails details;
  const _LoanBody({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
            label: "Faiz oranı",
            value: "%${details.interestRate.toStringAsFixed(2)}",
            valueColor: BankProductCardView.accent),
        _InfoRow(label: "Azami vade", value: "${details.maxTermMonths} ay"),
        _InfoRow(
            label: "Azami tutar",
            value: "${details.maxAmount.toStringAsFixed(0)} TRY"),
        _InfoRow(
          label: "Kart",
          value: details.hasDigitalCard
              ? "Dijital kart tanımlı"
              : "Sadece hesap üzerinden",
          valueColor: details.hasDigitalCard ? Colors.greenAccent : Colors.white54,
        ),
      ],
    );
  }
}

class _CheckingAccountBody extends StatelessWidget {
  final CheckingAccountDetails details;
  const _CheckingAccountBody({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          label: "Bağlı kart",
          value: details.hasLinkedCard ? (details.cardName ?? "Var") : "Kart yok",
          valueColor: details.hasLinkedCard ? Colors.greenAccent : Colors.white54,
        ),
        if (details.hasLinkedCard)
          _InfoRow(
            label: "Yıllık kart ücreti",
            value: (details.annualFee == null || details.annualFee == 0)
                ? "Ücretsiz"
                : "${details.annualFee!.toStringAsFixed(0)} TRY",
          ),
      ],
    );
  }
}

class _TimeDepositBody extends StatelessWidget {
  final TimeDepositDetails details;
  const _TimeDepositBody({required this.details});

  @override
  Widget build(BuildContext context) {
    final best = details.bestOption;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final option in details.termOptions)
          _InfoRow(
            label: "${option.months} ay vade",
            value: "%${option.annualInterestRate.toStringAsFixed(1)}",
            valueColor: identical(option, best) ? Colors.amberAccent : Colors.white,
          ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final BankProductCard card;
  const _ActionRow({required this.card});

  String get _primaryLabel {
    switch (card.productType) {
      case BankProductType.loan:
        return "Krediye başvur";
      case BankProductType.checkingAccount:
      case BankProductType.timeDeposit:
        return "Hesap aç";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: BankProductCardView.accent),
            onPressed: () {
              // TODO: başvuru/hesap açma akışı — form sistemine bağlanacak
            },
            child: Text(_primaryLabel),
          ),
        ),
        const SizedBox(width: 10),
        SaveToCollectionButton(card: card),
      ],
    );
  }
}