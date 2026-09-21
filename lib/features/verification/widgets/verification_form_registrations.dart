import '../../../core/forms/form_view_registry.dart';
import '../../../models/form_card/form_card.dart';
import 'email_verification_card_view.dart';
import 'phone_verification_card_view.dart';
import 'national_document_card_view.dart';
import 'international_document_card_view.dart';
import 'full_access_request_card_view.dart';

void registerVerificationFormViews() {
  FormViewRegistry.register<EmailVerificationFormCard>(
    (context, form) => const EmailVerificationCardView(),
  );
  FormViewRegistry.register<PhoneVerificationFormCard>(
    (context, form) => const PhoneVerificationCardView(),
  );
  FormViewRegistry.register<NationalDocumentFormCard>(
    (context, form) => const NationalDocumentCardView(),
  );
  FormViewRegistry.register<InternationalDocumentFormCard>(
    (context, form) => const InternationalDocumentCardView(),
  );
  FormViewRegistry.register<FullAccessRequestFormCard>(
    (context, form) => const FullAccessRequestCardView(),
  );
}
