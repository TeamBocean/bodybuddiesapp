import 'package:bodybuddiesapp/pages/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
  "pk_live_51MubfEEgQfqRQxRaOcN3vULxR3iYBu8fuypsSi7MD84ZP0En6bwCgPxb7zggGBg6PiIOKZDNrXB0XrTxMpDw6X7q00GJ2evJgI";
  await Stripe.instance.applySettings();
  await Firebase.initializeApp();
  runApp(const Wrapper());
}
