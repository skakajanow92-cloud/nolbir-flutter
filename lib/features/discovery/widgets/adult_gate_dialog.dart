import 'package:flutter/material.dart';

/// Oturum bazlı yaş onayı — `showDialog` ile açılır, `true`/`false`/`null`
/// (vazgeçildi) döner. Bu dosyadan bağımsız bırakıldı ki ileride başka
/// "18+ içerik" barındıran kart türleri (ör. bahis) de kullanabilsin.
Future<bool?> showAdultGateDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text(
        "18 Yaş ve Üzeri İçerik",
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        "Bu içerik 18 yaş ve üzeri kullanıcılar içindir. Devam etmek istediğinizi onaylıyor musunuz?",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Vazgeç"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Onaylıyorum"),
        ),
      ],
    ),
  );
}
