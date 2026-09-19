import 'package:flutter/material.dart';
import '../../models/form_card/form_card.dart';

typedef FormViewBuilder = Widget Function(BuildContext context, FormCard form);

/// `CardViewRegistry`'nin form kartları için karşılığı — aynı
/// registry + fallback felsefesi. Profil modülleriyle hiç karışmasın diye
/// bilinçli olarak ayrı bir klasörde (`core/forms/`) tutuluyor.
class FormViewRegistry {
  FormViewRegistry._();

  static final Map<Type, FormViewBuilder> _builders = {};

  static void register<T extends FormCard>(FormViewBuilder builder) {
    _builders[T] = builder;
  }

  static Widget build(BuildContext context, FormCard form) {
    final builder = _builders[form.runtimeType];
    if (builder != null) return builder(context, form);
    return UnknownFormView(form: form);
  }
}

/// Kayıtlı bir görünümü olmayan form türleri için fallback (bkz.
/// UnknownCardView'daki aynı gerekçe).
class UnknownFormView extends StatelessWidget {
  final FormCard form;
  const UnknownFormView({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Form görünümü kayıtlı değil: ${form.runtimeType}",
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
