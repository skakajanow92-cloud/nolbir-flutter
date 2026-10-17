import '../../../core/forms/form_view_registry.dart';
import '../../../models/form_card/form_card.dart';
import 'admin_application_wizard_view.dart';

void registerAdminFormViews() {
  FormViewRegistry.register<AdminApplicationFormCard>(
    (context, form) => const AdminApplicationWizardView(),
  );
}
