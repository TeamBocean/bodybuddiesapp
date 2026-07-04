import 'package:bodybuddiesapp/config/payment_runtime_config.dart';
import 'package:bodybuddiesapp/pages/wrapper.dart';
import 'package:bodybuddiesapp/providers/theme_provider.dart';
import 'package:bodybuddiesapp/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load();
    final isTestFlight = await _isTestFlight();
    PaymentRuntimeConfig.initialize(isTestFlight: isTestFlight);
    final publishableKey = PaymentRuntimeConfig.publishableKey;
    _validateReleasePaymentConfiguration();
    if (publishableKey.isEmpty) {
      throw Exception(
        'Missing Stripe publishable key in .env. '
        'See README for setup instructions.',
      );
    }

    // Initialize Stripe
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();

    // Initialize Firebase
    await Firebase.initializeApp();
    if (dotenv.env['USE_FIRESTORE_EMULATOR'] == 'true') {
      FirebaseFirestore.instance.useFirestoreEmulator(
        dotenv.env['FIRESTORE_EMULATOR_HOST'] ?? '127.0.0.1',
        int.tryParse(dotenv.env['FIRESTORE_EMULATOR_PORT'] ?? '') ?? 8080,
      );
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );
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
  final usesFirestoreEmulator = dotenv.env['USE_FIRESTORE_EMULATOR'] == 'true';
  final pointsAtLocalhost = endpoint.contains('localhost') ||
      endpoint.contains('127.0.0.1') ||
      endpoint.contains('10.0.2.2');
  final usesStripeTestMode = PaymentRuntimeConfig.usesStripeTestMode;

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

  if (endpoint.isEmpty) {
    throw Exception('Missing payment endpoint in release configuration.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const Wrapper(),
        );
      },
    );
  }
}
