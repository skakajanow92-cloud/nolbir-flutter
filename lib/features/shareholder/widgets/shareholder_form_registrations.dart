import '../../../core/forms/form_view_registry.dart';
import '../../../models/form_card/form_card.dart';
import 'shareholder_application_wizard_view.dart';

void registerShareholderFormViews() {
  FormViewRegistry.register<ShareholderApplicationFormCard>(
    (context, form) => const ShareholderApplicationWizardView(),
  );
}
