import '../feed_card/base.dart';

/// Kullanıcının yazdığı tek bir belge. Hafif bir markdown ile biçimlendirme
/// destekler: **kalın**, _italik_, __altı çizili__, satır başı "- " ile
/// madde işareti. Gerçek bir rich-text motoru değil, bilinçli bir
/// basitleştirme (bkz. view'daki `parseInlineMarkdown`).
class WritingDocument {
  final String id;
  String title;
  String body;
  DateTime updatedAt;

  WritingDocument({
    required this.id,
    this.title = "Başlıksız Belge",
    this.body = "",
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  int get wordCount =>
      body.trim().isEmpty ? 0 : body.trim().split(RegExp(r'\s+')).length;
}

/// Orta tab için: not defteri/Word tarzı yazı aracı kartı. Kullanıcı
/// belge oluşturur, düzenler, blog yazısı olarak paylaşır ya da fiziki
/// çıktı alır. `ToolCard` — pasif içerik değil, bir araç önerisi.
/// `LiveCollectible` — mesajlaşma/sosyal akış gibi tekrar dönülecek bir
/// merkez, koleksiyona eklenince statik önizleme değil canlı haliyle
/// kalmalı.
class WritingToolCard extends FeedCard
    implements Collectible, LiveCollectible, ToolCard {
  final String toolName;
  final String description;

  const WritingToolCard({
    required String id,
    this.toolName = "Not Defteri",
    this.description = "Yazılarını kaydet, paylaş veya yazdır.",
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (toolName, "");
}
