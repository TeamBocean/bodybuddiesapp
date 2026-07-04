import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentRuntimeConfig {
  static bool usesStripeTestMode = false;
  static String publishableKey = '';
  static String paymentIntentEndpoint = '';

  static void initialize({required bool isTestFlight}) {
    const paymentModeOverride = String.fromEnvironment('PAYMENT_MODE');
    final normalizedOverride = paymentModeOverride.trim().toLowerCase();
    usesStripeTestMode = normalizedOverride == 'sandbox' ||
        normalizedOverride == 'test' ||
        (normalizedOverride.isEmpty && isTestFlight);

    publishableKey = usesStripeTestMode
        ? dotenv.env['STRIPE_TEST_PUBLISHABLE_KEY'] ?? ''
        : dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

    paymentIntentEndpoint = usesStripeTestMode
        ? dotenv.env['PAYMENT_INTENT_TEST_ENDPOINT'] ?? ''
        : dotenv.env['PAYMENT_INTENT_ENDPOINT'] ?? '';
  }
}
