class PaymentRuntimeConfig {
  static bool usesStripeTestMode = false;
  static bool isTestFlightDistribution = false;
  static String publishableKey = '';
  static String paymentIntentEndpoint = '';

  static void initialize({required bool isTestFlight}) {
    isTestFlightDistribution = isTestFlight;
    const paymentModeOverride = String.fromEnvironment('PAYMENT_MODE');
    final normalizedOverride = paymentModeOverride.trim().toLowerCase();
    usesStripeTestMode = normalizedOverride == 'sandbox' ||
        normalizedOverride == 'test' ||
        ((normalizedOverride.isEmpty || normalizedOverride == 'auto') &&
            isTestFlight);

    const livePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
    const testPublishableKey =
        String.fromEnvironment('STRIPE_TEST_PUBLISHABLE_KEY');
    publishableKey =
        usesStripeTestMode ? testPublishableKey : livePublishableKey;

    const liveEndpoint = String.fromEnvironment('PAYMENT_INTENT_ENDPOINT');
    const testEndpoint = String.fromEnvironment('PAYMENT_INTENT_TEST_ENDPOINT');
    paymentIntentEndpoint = usesStripeTestMode ? testEndpoint : liveEndpoint;
  }
}
