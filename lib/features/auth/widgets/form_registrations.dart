import '../../../core/forms/form_view_registry.dart';
import '../../../models/form_card/form_card.dart';
import 'login_register_card_view.dart';

/// `registerProfileCardViews()`'in form karşılığı. Yeni bir form
/// eklerken buraya aynı ikili satırı ekle: `FormViewRegistry.register`.
void registerFormViews() {
  FormViewRegistry.register<LoginRegisterFormCard>(
    (context, form) => const LoginRegisterCardView(),
  );
}
