import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/auth_providers.dart';

/// Temel Giriş/Kayıt formu.
///
/// TASARIM NOTU: Diğer kartların aksine bu bir `CardShell`/aksiyon-rayı
/// düzeni kullanmıyor — bu bir swipe-feed kartı değil, `isUserProvider`
/// false olduğunda ProfileTab'ın normal akış YERİNE gösterdiği bağımsız
/// bir ekran (bkz. ProfileTab'daki gate mantığı). Görsel dil (koyu
/// gradient arka plan) uygulamanın geri kalanıyla tutarlı kalsın diye
/// korundu.
///
/// Vurgu rengi: nötr arduvaz mavisi — bu bir "profil modülü" değil,
/// modüllerin renk setiyle yarışmaması için kasıtlı olarak nötr seçildi.
class LoginRegisterCardView extends ConsumerStatefulWidget {
  const LoginRegisterCardView({super.key});

  @override
  ConsumerState<LoginRegisterCardView> createState() =>
      _LoginRegisterCardViewState();
}

class _LoginRegisterCardViewState extends ConsumerState<LoginRegisterCardView> {
  static const accent = Color(0xFF3D4F63);
  static const _base = Color(0xFF0D1013);
  static const _baseEnd = Color(0xFF151A1F);
  static const _pinLength = 6;

  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscurePin = true;

  final _identifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinConfirmController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _loginPasswordController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  void _toggleMode() => setState(() => _isRegisterMode = !_isRegisterMode);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(isUserProvider.notifier);
    if (_isRegisterMode) {
      notifier.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        pin: _pinController.text,
      );
    } else {
      notifier.login(
        identifier: _identifierController.text.trim(),
        password: _loginPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_outline, color: accent, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      _isRegisterMode ? "Hesap Oluştur" : "Giriş Yap",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 28),
                    if (_isRegisterMode) ..._registerFields() else ..._loginFields(),
                    const SizedBox(height: 22),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submit,
                      child: Text(_isRegisterMode ? "Kayıt Ol" : "Giriş Yap"),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isRegisterMode
                            ? "Zaten hesabın var mı? Giriş Yap"
                            : "Hesabın yok mu? Kayıt Ol",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _loginFields() {
    return [
      _field(
        controller: _identifierController,
        label: "T.C. Kimlik No / E-posta / Telefon",
        icon: Icons.person_outline,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? "Bu alan zorunlu" : null,
      ),
      const SizedBox(height: 14),
      _field(
        controller: _loginPasswordController,
        label: "Şifre",
        icon: Icons.lock_outline,
        obscure: _obscurePassword,
        toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
        validator: (v) => (v == null || v.isEmpty) ? "Şifre zorunlu" : null,
      ),
    ];
  }

  List<Widget> _registerFields() {
    return [
      _field(
        controller: _emailController,
        label: "E-posta",
        icon: Icons.alternate_email,
        keyboardType: TextInputType.emailAddress,
        validator: _validateEmail,
      ),
      const SizedBox(height: 14),
      _field(
        controller: _passwordController,
        label: "Şifre",
        icon: Icons.lock_outline,
        obscure: _obscurePassword,
        toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
        validator: (v) => (v == null || v.length < 6) ? "En az 6 karakter olmalı" : null,
      ),
      const SizedBox(height: 14),
      _field(
        controller: _passwordConfirmController,
        label: "Şifre Tekrar",
        icon: Icons.lock_outline,
        obscure: _obscurePassword,
        validator: (v) => v != _passwordController.text ? "Şifreler eşleşmiyor" : null,
      ),
      const SizedBox(height: 14),
      _field(
        controller: _pinController,
        label: "Dijital PIN ($_pinLength haneli)",
        icon: Icons.pin_outlined,
        obscure: _obscurePin,
        toggleObscure: () => setState(() => _obscurePin = !_obscurePin),
        keyboardType: TextInputType.number,
        maxLength: _pinLength,
        validator: _validatePin,
      ),
      const SizedBox(height: 14),
      _field(
        controller: _pinConfirmController,
        label: "Dijital PIN Tekrar",
        icon: Icons.pin_outlined,
        obscure: _obscurePin,
        keyboardType: TextInputType.number,
        maxLength: _pinLength,
        validator: (v) => v != _pinController.text ? "PIN'ler eşleşmiyor" : null,
      ),
    ];
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "E-posta zorunlu";
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
    if (!regex.hasMatch(v.trim())) return "Geçerli bir e-posta gir";
    return null;
  }

  String? _validatePin(String? v) {
    if (v == null || v.length != _pinLength) return "$_pinLength haneli olmalı";
    if (!RegExp(r'^\d+$').hasMatch(v)) return "Sadece rakam girilebilir";
    return null;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        counterText: "",
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white38,
                    size: 20),
                onPressed: toggleObscure,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
