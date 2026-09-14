/// Bir ilgi alanı/beğeni etiketinin kategorisi.
///
/// BİLİNÇLİ TASARIM KARARI: cart.dart'taki `CartType` ile AYNI yaklaşım —
/// `enum` değil, string'i saran hafif bir sınıf. Hobi/spor/sanatçı/film/
/// oyun/kitap/müzik gibi kategoriler zamanla artabilir (ve öngörülemeyen
/// yeni kategoriler gelebilir); `enum` olsaydı her yeni kategori için bu
/// dosyayı değiştirmen gerekirdi. Bu şekilde backend'den yeni bir kategori
/// string'i gelse bile (örn. "yemek_tarzı") kod değişikliği gerekmeden
/// çalışır — sadece görünümünü özelleştirmek istediğinde bir ikon eklersin.
class InterestCategory {
  final String id;
  const InterestCategory(this.id);

  static const hobby = InterestCategory('hobby');
  static const sport = InterestCategory('sport');
  static const artist = InterestCategory('artist');
  static const movie = InterestCategory('movie');
  static const game = InterestCategory('game');
  static const book = InterestCategory('book');
  static const music = InterestCategory('music');

  @override
  bool operator ==(Object other) =>
      other is InterestCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'InterestCategory($id)';
}

extension InterestCategoryLabel on InterestCategory {
  String get label => switch (id) {
        'hobby' => "Hobi",
        'sport' => "Spor",
        'artist' => "Sanatçı",
        'movie' => "Film",
        'game' => "Oyun",
        'book' => "Kitap",
        'music' => "Müzik",
        _ => id, // kayıtlı olmayan yeni bir kategori gelirse ham id fallback
      };
}

/// Kullanıcının tek bir ilgi alanı/beğeni etiketi
/// (örn. kategori: film, label: "Interstellar").
class InterestTag {
  final String id;
  final InterestCategory category;
  final String label;

  const InterestTag({
    required this.id,
    required this.category,
    required this.label,
  });
}

/// Cinsel yönelim tercihi. `preferNotToSay` varsayılan — kullanıcı
/// paylaşmayı seçmediyse profil bunu zorlamamalı.
enum SexualOrientation { heterosexual, homosexual, bisexual, other, preferNotToSay }

extension SexualOrientationLabel on SexualOrientation {
  String get label => switch (this) {
        SexualOrientation.heterosexual => "Heteroseksüel",
        SexualOrientation.homosexual => "Homoseksüel",
        SexualOrientation.bisexual => "Biseksüel",
        SexualOrientation.other => "Diğer",
        SexualOrientation.preferNotToSay => "Belirtmek istemiyorum",
      };
}

/// Kullanıcının aradığı ilişki türü.
enum RelationshipGoal { longTerm, friendship, dating, marriage }

extension RelationshipGoalLabel on RelationshipGoal {
  String get label => switch (this) {
        RelationshipGoal.longTerm => "Uzun Soluklu İlişki",
        RelationshipGoal.friendship => "Güvenli / Ortak Fikir Arkadaşlığı",
        RelationshipGoal.dating => "Sevgili Arayışı",
        RelationshipGoal.marriage => "Eş Arayışı",
      };
}
