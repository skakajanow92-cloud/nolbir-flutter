import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/feed_card.dart';
import '../application/profile_providers.dart';

/// Profil tab'ındaki "+" butonuna basınca açılan seçim ekranı.
/// Üç farklı paket burada bir araya geliyor:
///  - image_picker (kamera kaynağı): fotoğraf/video çeker, kamera + mikrofon
///    izinlerini kendi içinde otomatik ister.
///  - image_picker (galeri kaynağı): cihazdaki mevcut medyayı seçer.
///  - file_picker: kamera rulosu dışındaki herhangi bir dosyayı seçer.
///
/// Seçilen medya doğrudan ProfileFeed'e yeni bir UserPostCard olarak eklenir.
class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickFromCamera({required bool video}) async {
    await _run(() async {
      final picker = ImagePicker();
      final XFile? file = video
          ? await picker.pickVideo(source: ImageSource.camera)
          : await picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        await _addPost(file.path, caption: video ? "Yeni video" : "Yeni fotoğraf");
      }
    });
  }

  Future<void> _pickFromGallery() async {
    await _run(() async {
      final picker = ImagePicker();
      final XFile? file = await picker.pickMedia(); // fotoğraf ya da video
      if (file != null) {
        await _addPost(file.path, caption: "Galeriden eklendi");
      }
    });
  }

  Future<void> _pickFromFiles() async {
    await _run(() async {
      final result = await FilePicker.pickFiles(type: FileType.media);
      final path = result.single.path;
      if (path != null) {
        await _addPost(path, caption: "Dosyadan eklendi");
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await action();
    } catch (e) {
      // Kullanıcı izni reddettiğinde ya da seçim iptal edildiğinde buraya düşer.
      setState(() => _errorMessage = "İşlem tamamlanamadı: izin verildiğinden emin ol.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addPost(String path, {required String caption}) async {
    final newPost = UserPostCard(
      id: "post_${DateTime.now().millisecondsSinceEpoch}",
      mediaUrl: path,
      caption: caption,
    );
    await ref.read(profileFeedProvider.notifier).addPost(newPost);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.redAccent)),
                    ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera, color: Colors.white),
                    title: const Text("Kameradan fotoğraf çek",
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _pickFromCamera(video: false),
                  ),
                  ListTile(
                    leading: const Icon(Icons.videocam, color: Colors.white),
                    title: const Text("Kameradan video çek",
                        style: TextStyle(color: Colors.white)),
                    onTap: () => _pickFromCamera(video: true),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library, color: Colors.white),
                    title: const Text("Galeriden seç", style: TextStyle(color: Colors.white)),
                    onTap: _pickFromGallery,
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_open, color: Colors.white),
                    title: const Text("Dosyadan seç", style: TextStyle(color: Colors.white)),
                    onTap: _pickFromFiles,
                  ),
                ],
              ),
      ),
    );
  }
}
