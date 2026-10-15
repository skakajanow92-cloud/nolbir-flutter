import 'package:flutter/material.dart';
import '../../../core/layout/card_detail_registry.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/detail_kit.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../../models/accommodation.dart';
import '../../../models/career.dart';
import '../../../models/dating.dart';
import '../../../models/engagement.dart';
import '../../../models/insurance.dart';
import '../../../models/travel.dart';
import '../../../models/wallet.dart';
import 'accommodation_profile_card_view.dart';
import 'career_profile_card_view.dart';
import 'dating_profile_card_view.dart';
import 'engagement_profile_card_view.dart';
import 'food_profile_card_view.dart';
import 'insurance_profile_card_view.dart';
import 'profile_header_card_view.dart';
import 'travel_profile_card_view.dart';
import 'wallet_profile_card_view.dart';

const _ok = Color(0xFF7FD98A);
const _postAccent = Color(0xFF3E4A5A);

/// Profil modüllerinin masaüstü detay paneli görünümleri. Her modül, mobildeki
/// mini kartlara sığmayan ayrıntıyı (poliçe no, onay no, iş tanımı, tüm
/// ilgi alanları...) tam liste olarak gösterir; vurgu rengi modülün kendi
/// rengiyle aynıdır. Yeni bir modül için: buraya bir fonksiyon yaz, aşağıya
/// bir satır kayıt ekle.
void registerProfileCardDetails() {
  CardDetailRegistry.register<ProfileHeaderCard>(_headerDetail);
  CardDetailRegistry.register<WalletProfileCard>(_walletDetail);
  CardDetailRegistry.register<InsuranceProfileCard>(_insuranceDetail);
  CardDetailRegistry.register<TravelProfileCard>(_travelDetail);
  CardDetailRegistry.register<AccommodationProfileCard>(_accommodationDetail);
  CardDetailRegistry.register<FoodProfileCard>(_foodDetail);
  CardDetailRegistry.register<EngagementProfileCard>(_engagementDetail);
  CardDetailRegistry.register<CareerProfileCard>(_careerDetail);
  CardDetailRegistry.register<DatingProfileCard>(_datingDetail);
  CardDetailRegistry.register<UserPostCard>(_userPostDetail);
}

String _orDash(String s) => s.isEmpty ? '—' : s;

// --- Temel Bilgiler ---------------------------------------------------------

Widget _headerDetail(BuildContext context, ProfileHeaderCard card) {
  return DetailPage(
    title: card.fullName.isEmpty ? '@${card.username}' : card.fullName,
    subtitle: '@${card.username}',
    icon: Icons.person_outline,
    accent: ProfileHeaderCardView.accent,
    children: [
      DetailSection(
        title: 'Temel Bilgiler',
        spacing: 0,
        children: [
          DetailRow(label: 'Ülke', value: _orDash(card.country)),
          DetailRow(label: 'Cinsiyet', value: _orDash(card.gender)),
          DetailRow(label: 'Takipçi', value: formatInt(card.followerCount)),
        ],
      ),
      DetailSection(
        title: 'Biyografi',
        children: [
          card.bio.isEmpty
              ? const DetailEmpty('Henüz biyografi eklenmedi')
              : DetailParagraph(card.bio),
        ],
      ),
    ],
  );
}

// --- Cüzdan -----------------------------------------------------------------

Widget _walletDetail(BuildContext context, WalletProfileCard card) {
  const accent = WalletProfileCardView.moduleAccent;
  return DetailPage(
    title: 'Cüzdan',
    subtitle: '${formatMoney(card.totalBalance, decimals: 2)} TRY toplam bakiye',
    icon: Icons.account_balance_wallet_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Hesaplar (${card.accounts.length})',
        children: [
          if (card.accounts.isEmpty) const DetailEmpty('Henüz bağlı hesap yok'),
          for (final a in card.accounts)
            DetailItem(
              accent: accent,
              icon: Icons.account_balance_outlined,
              title: a.bankName,
              subtitle: a.type.label,
              rows: [
                DetailRow(
                  label: 'Bakiye',
                  value: '${formatMoney(a.balance, decimals: 2)} ${a.currency}',
                  emphasize: true,
                ),
                if (a.interestRate != null)
                  DetailRow(label: 'Yıllık faiz', value: '%${a.interestRate}'),
                if (a.maturityDate != null)
                  DetailRow(label: 'Vade', value: formatDate(a.maturityDate!)),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'Kredi Kartları (${card.creditCards.length})',
        children: [
          if (card.creditCards.isEmpty)
            const DetailEmpty('Henüz kayıtlı kredi kartı yok'),
          for (final c in card.creditCards)
            DetailItem(
              accent: accent,
              icon: Icons.credit_card,
              title: c.bankName,
              subtitle: c.maskedNumber,
              rows: [
                DetailRow(
                    label: 'Limit',
                    value: '${formatMoney(c.limit)} ${c.currency}'),
                DetailRow(
                    label: 'Kullanılan',
                    value: '${formatMoney(c.used)} ${c.currency}'),
                DetailRow(
                  label: 'Kullanılabilir',
                  value: '${formatMoney(c.available)} ${c.currency}',
                  emphasize: true,
                ),
              ],
              footer: DetailProgress(
                value: c.usageRatio,
                caption: '%${(c.usageRatio * 100).round()} kullanım',
              ),
            ),
        ],
      ),
    ],
  );
}

// --- Sigorta ----------------------------------------------------------------

Widget _insuranceDetail(BuildContext context, InsuranceProfileCard card) {
  const accent = InsuranceProfileCardView.moduleAccent;
  return DetailPage(
    title: 'Sigorta',
    subtitle: '${card.activeCount} aktif poliçe',
    icon: Icons.shield_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Poliçeler (${card.policies.length})',
        children: [
          if (card.policies.isEmpty)
            const DetailEmpty('Henüz kayıtlı poliçe yok'),
          for (final p in card.policies)
            DetailItem(
              accent: accent,
              icon: Icons.shield_outlined,
              title: p.company,
              subtitle: p.type.label,
              badge: DetailBadge(
                label: p.isActive ? 'Aktif' : 'Süresi Doldu',
                color: p.isActive ? _ok : Colors.white54,
              ),
              rows: [
                DetailRow(label: 'Poliçe No', value: p.policyNumber),
                DetailRow(
                  label: 'Teminat',
                  value: '${formatMoney(p.coverageAmount)} ${p.currency}',
                  emphasize: true,
                ),
                DetailRow(
                    label: 'Prim',
                    value: '${formatMoney(p.premium)} ${p.currency}'),
                DetailRow(label: 'Başlangıç', value: formatDate(p.startDate)),
                DetailRow(label: 'Bitiş', value: formatDate(p.endDate)),
              ],
            ),
        ],
      ),
    ],
  );
}

// --- Seyahat ----------------------------------------------------------------

IconData _transportIcon(TransportType type) => switch (type) {
      TransportType.flight => Icons.flight_takeoff,
      TransportType.bus => Icons.directions_bus_outlined,
      TransportType.train => Icons.train_outlined,
      TransportType.ferry => Icons.directions_boat_outlined,
    };

Widget _ticketItem(TravelTicket t, Color accent) {
  return DetailItem(
    accent: accent,
    icon: _transportIcon(t.transportType),
    title: '${t.origin} → ${t.destination}',
    subtitle: '${t.company} · ${t.transportType.label}',
    rows: [
      DetailRow(label: 'Kalkış', value: formatDateTime(t.departureDateTime)),
      if (t.arrivalDateTime != null)
        DetailRow(label: 'Varış', value: formatDateTime(t.arrivalDateTime!)),
      DetailRow(label: 'Bilet No', value: t.ticketNumber),
      if (t.seatNumber != null)
        DetailRow(label: 'Koltuk', value: t.seatNumber!),
      DetailRow(
        label: 'Ücret',
        value: '${formatMoney(t.price, decimals: 2)} ${t.currency}',
        emphasize: true,
      ),
    ],
  );
}

Widget _travelDetail(BuildContext context, TravelProfileCard card) {
  const accent = TravelProfileCardView.moduleAccent;
  final upcoming = card.upcoming;
  final past = card.past;
  return DetailPage(
    title: 'Seyahat',
    subtitle: '${upcoming.length} yaklaşan · ${past.length} geçmiş yolculuk',
    icon: Icons.explore_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Yaklaşan Yolculuklar (${upcoming.length})',
        children: [
          if (upcoming.isEmpty) const DetailEmpty('Yaklaşan yolculuk yok'),
          for (final t in upcoming) _ticketItem(t, accent),
        ],
      ),
      DetailSection(
        title: 'Geçmiş Yolculuklar (${past.length})',
        children: [
          if (past.isEmpty) const DetailEmpty('Geçmiş yolculuk yok'),
          for (final t in past) _ticketItem(t, accent),
        ],
      ),
    ],
  );
}

// --- Konaklama --------------------------------------------------------------

Widget _stayItem(AccommodationReservation r, Color accent) {
  return DetailItem(
    accent: accent,
    icon: Icons.king_bed_outlined,
    title: r.hotelName,
    subtitle: r.location,
    rows: [
      DetailRow(label: 'Oda', value: r.roomType),
      DetailRow(label: 'Giriş', value: formatDate(r.checkIn)),
      DetailRow(label: 'Çıkış', value: formatDate(r.checkOut)),
      DetailRow(
          label: 'Süre', value: '${r.nights} gece · ${r.guestCount} misafir'),
      DetailRow(label: 'Onay No', value: r.confirmationNumber),
      DetailRow(
        label: 'Ücret',
        value: '${formatMoney(r.price)} ${r.currency}',
        emphasize: true,
      ),
    ],
  );
}

Widget _accommodationDetail(BuildContext context, AccommodationProfileCard card) {
  const accent = AccommodationProfileCardView.moduleAccent;
  final upcoming = card.upcoming;
  final past = card.past;
  return DetailPage(
    title: 'Konaklama',
    subtitle: '${upcoming.length} yaklaşan · ${past.length} geçmiş rezervasyon',
    icon: Icons.hotel_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Yaklaşan Rezervasyonlar (${upcoming.length})',
        children: [
          if (upcoming.isEmpty) const DetailEmpty('Yaklaşan rezervasyon yok'),
          for (final r in upcoming) _stayItem(r, accent),
        ],
      ),
      DetailSection(
        title: 'Geçmiş Rezervasyonlar (${past.length})',
        children: [
          if (past.isEmpty) const DetailEmpty('Geçmiş rezervasyon yok'),
          for (final r in past) _stayItem(r, accent),
        ],
      ),
    ],
  );
}

// --- Yemek ------------------------------------------------------------------

Widget _foodDetail(BuildContext context, FoodProfileCard card) {
  const accent = FoodProfileCardView.moduleAccent;
  return DetailPage(
    title: 'Yemek',
    subtitle: '${card.favoriteRestaurants.length} favori mekan',
    icon: Icons.restaurant_menu_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Favori Yemekler (${card.favoriteFoods.length})',
        children: [
          card.favoriteFoods.isEmpty
              ? const DetailEmpty('Henüz favori yemek eklenmedi')
              : DetailChips(
                  accent: accent,
                  labels: [
                    for (final f in card.favoriteFoods)
                      f.cuisine != null ? '${f.name} · ${f.cuisine}' : f.name,
                  ],
                ),
        ],
      ),
      DetailSection(
        title: 'Favori Mekanlar (${card.favoriteRestaurants.length})',
        children: [
          if (card.favoriteRestaurants.isEmpty)
            const DetailEmpty('Henüz favori mekan yok'),
          for (final r in card.favoriteRestaurants)
            DetailItem(
              accent: accent,
              icon: Icons.storefront_outlined,
              title: r.name,
              subtitle: '${r.cuisine} · ${r.location}',
            ),
        ],
      ),
      DetailSection(
        title: 'Düzenli Siparişler (${card.recurringOrders.length})',
        children: [
          if (card.recurringOrders.isEmpty)
            const DetailEmpty('Henüz düzenli sipariş yok'),
          for (final o in card.recurringOrders)
            DetailItem(
              accent: accent,
              icon: Icons.repeat,
              title: o.orderDescription,
              subtitle: o.restaurantName,
              rows: [DetailRow(label: 'Sıklık', value: o.frequency)],
            ),
        ],
      ),
      DetailSection(
        title: 'Kafe Kartları (${card.loyaltyCards.length})',
        children: [
          if (card.loyaltyCards.isEmpty)
            const DetailEmpty('Henüz kayıtlı kafe kartı yok'),
          for (final c in card.loyaltyCards)
            DetailItem(
              accent: accent,
              icon: Icons.local_cafe_outlined,
              title: c.cafeName,
              rows: [
                if (c.hasStampProgress)
                  DetailProgress(
                    value: c.progress,
                    label: 'Damga',
                    caption: '${c.stampsCollected}/${c.stampsRequired}',
                  ),
                if (c.discountPercent != null)
                  DetailRow(
                    label: 'İndirim',
                    value: '%${c.discountPercent!.toStringAsFixed(0)}',
                  ),
                if (c.rewardDescription != null)
                  DetailRow(label: 'Ödül', value: c.rewardDescription!),
              ],
            ),
        ],
      ),
    ],
  );
}

// --- Etkileşim --------------------------------------------------------------

Widget _engagementDetail(BuildContext context, EngagementProfileCard card) {
  const accent = EngagementProfileCardView.moduleAccent;
  final s = card.summary;
  return DetailPage(
    title: 'Etkileşim',
    subtitle: '${formatInt(s.followerCount)} takipçi · ${formatInt(s.followingCount)} takip',
    icon: Icons.insights_outlined,
    accent: accent,
    children: [
      DetailSection(
        title: 'Özet',
        spacing: 0,
        children: [
          DetailRow(label: 'Gönderi', value: formatInt(s.totalPosts)),
          DetailRow(label: 'İzlenim', value: formatInt(s.totalImpressions)),
          DetailRow(label: 'Yorum', value: formatInt(s.totalComments)),
          DetailRow(label: 'Tartışma', value: formatInt(s.totalReplies)),
          DetailRow(label: 'Referans', value: formatInt(s.totalReferrals)),
        ],
      ),
      DetailSection(
        title: 'Referanslar & Tavsiyeler (${card.referrals.length})',
        children: [
          if (card.referrals.isEmpty)
            const DetailEmpty('Henüz referans/tavsiye yok'),
          for (final r in card.referrals)
            DetailItem(
              accent: accent,
              icon: Icons.alternate_email,
              title: '@${r.fromUsername}',
              subtitle: r.type.label,
              rows: [
                if (r.note != null) DetailParagraph(r.note!),
                DetailRow(label: 'Tarih', value: formatDate(r.date)),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'En Çok Tartışılan Gönderiler (${card.topDiscussions.length})',
        children: [
          if (card.topDiscussions.isEmpty)
            const DetailEmpty('Henüz yorum/tartışma yok'),
          for (final d in card.topDiscussions)
            DetailItem(
              accent: accent,
              icon: Icons.forum_outlined,
              title: d.postCaption,
              rows: [
                DetailRow(label: 'Yorum', value: formatInt(d.commentCount)),
                DetailRow(label: 'Tartışma', value: formatInt(d.replyCount)),
                DetailRow(
                    label: 'İzlenim', value: formatInt(d.impressionCount)),
              ],
            ),
        ],
      ),
    ],
  );
}

// --- Kariyer ----------------------------------------------------------------

Widget _careerDetail(BuildContext context, CareerProfileCard card) {
  const accent = CareerProfileCardView.moduleAccent;
  final experiences = card.sortedExperiences;
  final educations = card.sortedEducations;
  return DetailPage(
    title: card.headline.isNotEmpty ? card.headline : 'Kariyer',
    subtitle: card.currentExperience != null
        ? '${card.currentExperience!.title} · ${card.currentExperience!.company}'
        : null,
    icon: Icons.work_outline,
    accent: accent,
    children: [
      DetailSection(
        title: 'İş Deneyimi (${experiences.length})',
        children: [
          if (experiences.isEmpty)
            const DetailEmpty('Henüz iş deneyimi eklenmedi'),
          for (final e in experiences)
            DetailItem(
              accent: accent,
              icon: Icons.apartment_outlined,
              title: e.title,
              subtitle: '${e.company} · ${e.employmentType.label}',
              badge: e.isCurrent
                  ? const DetailBadge(label: 'Devam ediyor', color: _ok)
                  : null,
              rows: [
                DetailRow(
                  label: 'Dönem',
                  value: '${formatMonth(e.startDate)} - '
                      '${e.endDate != null ? formatMonth(e.endDate!) : 'Günümüz'}',
                ),
                DetailRow(label: 'Süre', value: formatDuration(e.durationInMonths)),
                DetailRow(label: 'Konum', value: e.location),
                if (e.description != null && e.description!.isNotEmpty)
                  DetailParagraph(e.description!),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'Eğitim (${educations.length})',
        children: [
          if (educations.isEmpty)
            const DetailEmpty('Henüz eğitim bilgisi eklenmedi'),
          for (final e in educations)
            DetailItem(
              accent: accent,
              icon: Icons.school_outlined,
              title: e.school,
              subtitle: '${e.degree} · ${e.fieldOfStudy}',
              rows: [
                DetailRow(
                  label: 'Dönem',
                  value: '${e.startDate.year} - '
                      '${e.endDate != null ? e.endDate!.year.toString() : 'Devam ediyor'}',
                ),
                if (e.note != null && e.note!.isNotEmpty)
                  DetailParagraph(e.note!),
              ],
            ),
        ],
      ),
      DetailSection(
        title: 'Yetenekler (${card.skills.length})',
        spacing: 4,
        children: [
          if (card.skills.isEmpty) const DetailEmpty('Henüz yetenek eklenmedi'),
          for (final s in card.skills)
            DetailProgress(
              label: s.name,
              caption: s.level.label,
              value: s.level.progress,
              color: const Color(0xFFB8C4D6),
            ),
        ],
      ),
    ],
  );
}

// --- Tanışma ----------------------------------------------------------------

Widget _datingDetail(BuildContext context, DatingProfileCard card) {
  const accent = DatingProfileCardView.moduleAccent;

  // İlgi alanlarını kategoriye göre grupla (ilk görülme sırası korunur).
  final categories = <InterestCategory>[];
  for (final tag in card.interests) {
    if (!categories.contains(tag.category)) categories.add(tag.category);
  }

  return DetailPage(
    title: 'Tanışma Profili',
    subtitle: card.relationshipGoal.label,
    icon: Icons.favorite_outline,
    accent: accent,
    children: [
      DetailSection(
        title: 'Tercihler',
        spacing: 0,
        children: [
          DetailRow(label: 'Yönelim', value: card.sexualOrientation.label),
          DetailRow(label: 'Aranan ilişki', value: card.relationshipGoal.label),
          DetailRow(label: 'Fotoğraf', value: '${card.photoUrls.length}'),
        ],
      ),
      if (card.tagline.isNotEmpty)
        DetailSection(
          title: 'Tanıtım',
          children: [DetailParagraph(card.tagline)],
        ),
      if (categories.isEmpty)
        const DetailSection(
          title: 'İlgi Alanları',
          children: [DetailEmpty('Henüz ilgi alanı eklenmedi')],
        ),
      for (final c in categories)
        DetailSection(
          title: '${c.label} (${card.interestsOf(c).length})',
          children: [
            DetailChips(
              accent: accent,
              labels: [for (final t in card.interestsOf(c)) t.label],
            ),
          ],
        ),
    ],
  );
}

// --- Gönderi ----------------------------------------------------------------

String _basename(String path) => path.split(RegExp(r'[\\/]')).last;

Widget _userPostDetail(BuildContext context, UserPostCard card) {
  return DetailPage(
    title: 'Gönderi',
    subtitle: card.caption.isEmpty ? null : card.caption,
    icon: Icons.image_outlined,
    accent: _postAccent,
    children: [
      DetailSection(
        title: 'Açıklama',
        children: [
          card.caption.isEmpty
              ? const DetailEmpty('Açıklama yok')
              : DetailParagraph(card.caption),
        ],
      ),
      if (card.mediaUrl.isNotEmpty)
        DetailSection(
          title: 'Medya',
          spacing: 0,
          children: [DetailRow(label: 'Dosya', value: _basename(card.mediaUrl))],
        ),
    ],
  );
}
