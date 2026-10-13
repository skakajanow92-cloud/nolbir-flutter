import '../feed_card/base.dart';

/// `WritingDocument` gibi bilerek mutable — kullanıcı tarafından aktif
/// düzenlenen bir içerik.
class SpreadsheetDocument {
  final String id;
  String title;
  List<List<String>> grid; // grid[row][col] ham değer (metin/sayı/"=formül")
  DateTime updatedAt;

  SpreadsheetDocument({
    required this.id,
    this.title = "Başlıksız Tablo",
    List<List<String>>? grid,
    DateTime? updatedAt,
  }) : grid = grid ?? List.generate(12, (_) => List.filled(6, "")),
       updatedAt = updatedAt ?? DateTime.now();

  int get rowCount => grid.length;
  int get colCount => grid.isEmpty ? 0 : grid[0].length;
}

/// Orta tab için: Excel tarzı tablo/hesaplama aracı kartı. `WritingToolCard`
/// ile aynı aile (`ToolCard`, `LiveCollectible`) — paylaşım ve yazdırma
/// akışları da aynı desenle (bkz. `PrintDocumentDialog`, artık genel).
class SpreadsheetToolCard extends FeedCard
    implements Collectible, LiveCollectible, ToolCard {
  final String toolName;
  final String description;

  const SpreadsheetToolCard({
    required String id,
    this.toolName = "Tablo",
    this.description =
        "Satır/sütun bazlı kayıtlar tut, hızlı hesapla, paylaş veya yazdır.",
  }) : super(id);

  @override
  (String, String) toCollectionPreview() => (toolName, "");
}
