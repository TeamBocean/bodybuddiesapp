import 'package:bodybuddiesapp/config/payment_runtime_config.dart';
import 'package:bodybuddiesapp/pages/wrapper.dart';
import 'package:bodybuddiesapp/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    final isTestFlight = await _isTestFlight();
    PaymentRuntimeConfig.initialize(isTestFlight: isTestFlight);
    final publishableKey = PaymentRuntimeConfig.publishableKey;
    _validateReleasePaymentConfiguration();
    if (publishableKey.isEmpty) {
      throw Exception(
        'Missing Stripe publishable key. Supply STRIPE_PUBLISHABLE_KEY '
        'as a Dart define.',
      );
    }

    // Initialize Stripe
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();

    // Initialize Firebase
    await Firebase.initializeApp();
    const useFirestoreEmulator = bool.fromEnvironment('USE_FIRESTORE_EMULATOR');
    if (useFirestoreEmulator) {
      FirebaseFirestore.instance.useFirestoreEmulator(
        const String.fromEnvironment(
          'FIRESTORE_EMULATOR_HOST',
          defaultValue: '127.0.0.1',
        ),
        const int.fromEnvironment('FIRESTORE_EMULATOR_PORT',
            defaultValue: 8080),
      );
    }

    runApp(const MyApp());
  } catch (e) {
    print('Initialization error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
}

Future<bool> _isTestFlight() async {
  if (defaultTargetPlatform != TargetPlatform.iOS) return false;

  try {
    const channel = MethodChannel('bodybuddies/runtime');
    return await channel.invokeMethod<bool>('isTestFlight') ?? false;
  } catch (_) {
    return false;
  }
}

void _validateReleasePaymentConfiguration() {
  if (!kReleaseMode) return;

  final publishableKey = PaymentRuntimeConfig.publishableKey;
  final endpoint = PaymentRuntimeConfig.paymentIntentEndpoint;
  const usesFirestoreEmulator = bool.fromEnvironment('USE_FIRESTORE_EMULATOR');
  final pointsAtLocalhost = endpoint.contains('localhost') ||
      endpoint.contains('127.0.0.1') ||
      endpoint.contains('10.0.2.2');
  final usesStripeTestMode = PaymentRuntimeConfig.usesStripeTestMode;

  if (!PaymentRuntimeConfig.isTestFlightDistribution && usesStripeTestMode) {
    throw Exception(
      'App Store distributions cannot use Stripe test mode.',
    );
  }

  if (pointsAtLocalhost || usesFirestoreEmulator) {
    throw Exception(
      'Release payment configuration is not production-safe. '
      'Use a deployed payment endpoint and disable Firestore emulator mode.',
    );
  }

  if (usesStripeTestMode && !publishableKey.startsWith('pk_test_')) {
    throw Exception(
      'Sandbox payment configuration must use a Stripe test publishable key.',
    );
  }

  if (!usesStripeTestMode && !publishableKey.startsWith('pk_live_')) {
    throw Exception(
      'Live payment configuration must use a Stripe live publishable key.',
    );
  }

  if (!PaymentRuntimeConfig.isTestFlightDistribution &&
      (endpoint.toLowerCase().contains('sandbox') ||
          endpoint.toLowerCase().contains('test'))) {
    throw Exception(
      'App Store distributions cannot use a sandbox payment endpoint.',
    );
  }

  if (endpoint.isEmpty) {
    throw Exception('Missing payment endpoint in release configuration.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const Wrapper(),
    );
  }
}
