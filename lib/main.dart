import 'package:bodybuddiesapp/pages/wrapper.dart';
import 'package:bodybuddiesapp/providers/theme_provider.dart';
import 'package:bodybuddiesapp/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_live_51MubfEEgQfqRQxRaOcN3vULxR3iYBu8fuypsSi7MD84ZP0En6bwCgPxb7zggGBg6PiIOKZDNrXB0XrTxMpDw6X7q00GJ2evJgI";
  await Stripe.instance.applySettings();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
