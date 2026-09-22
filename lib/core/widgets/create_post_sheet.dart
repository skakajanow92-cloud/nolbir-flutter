import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/media/media_pick_result.dart';
import '../../../core/media/media_providers.dart';
import '../../../models/feed_card/feed_card.dart';
import '../../features/profile/application/profile_providers.dart';

/// Profil tab'ındaki "+" butonuna basınca açılan seçim ekranı.
///
/// ÖNCEKİ HALİNDEN FARKI: image_picker/file_picker çağrıları artık burada
/// yazılmıyor — hepsi `core/media/MediaService`'e taşındı. Bu sheet sadece
/// (1) hangi kaynağın seçildiğini sorar, (2) `MediaService` ile seçip
/// kalıcı diske kaydeder, (3) sonucu `ProfileFeed`'e yeni bir
/// `UserPostCard` olarak ekler. Aynı `MediaService` ileride başka
/// modüllerde (ör. destek eki, ürün görseli) tekrar yazılmadan kullanılır.
class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handle(
    Future<MediaPickResult?> Function() pick, {
    required String caption,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final media = await pick();
      if (media == null) return; // kullanıcı iptal etti — hata değil
      await _addPost(media.path, caption: caption);
    } catch (e) {
      setState(() =>
          _errorMessage = "İşlem tamamlanamadı: izin verildiğinden emin ol.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addPost(String localPath, {required String caption}) async {
    final newPost = UserPostCard(
      id: "post_${DateTime.now().millisecondsSinceEpoch}",
      mediaUrl: localPath,
      caption: caption,
    );
    await ref.read(profileFeedProvider.notifier).addPost(newPost);
    if (mounted) Navigator.of(context).pop();
    // TODO: arka planda mediaServiceProvider.upload(...) ile backend'e
    // yükleyip dönen URL ile kartı güncelle (mediaUrl: local -> remote).
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.read(mediaServiceProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.redAccent)),
                    ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera, color: Colors.white),
                    title: const Text("Kameradan fotoğraf çek",
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _handle(media.captureImageAndPersist,
                        caption: "Yeni fotoğraf"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.videocam, color: Colors.white),
                    title: const Text("Kameradan video çek",
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _handle(media.captureVideoAndPersist,
                        caption: "Yeni video"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library, color: Colors.white),
                    title: const Text("Galeriden seç",
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _handle(media.pickFromGalleryAndPersist,
                        caption: "Galeriden eklendi"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_open, color: Colors.white),
                    title: const Text("Dosyadan seç",
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _handle(media.pickAnyFileAndPersist,
                        caption: "Dosyadan eklendi"),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Uygulamanın HERHANGİ bir yerinden (bir kartın aksiyon butonu, farklı
/// bir modül, ileride eklenecek başka bir "+" vb.) aynı "medya ekle"
/// menüsünü açmak için TEK, paylaşılan giriş noktası.
///
/// Profil tab'ındaki FAB kaldırıldı (tasarımda yeri yoktu) ama menünün
/// kendisi (view) bilerek burada bırakıldı — `MediaPicker`/`MediaService`
/// ile aynı ilke: bir kart bu menüyü açmak isterse `CreatePostSheet`'in
/// nasıl kurulduğuyla uğraşmaz, sadece bu fonksiyonu çağırır.
void showCreatePostSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey.shade900,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const CreatePostSheet(),
  );
}
