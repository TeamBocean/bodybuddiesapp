import 'package:bodybuddiesapp/pages/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
  "pk_test_51HjpItIZd5hDXDsaYk7G5v2OJVS7N1LOTVE5KkODhr22789MAUgG86g4MqyS9CZ72pohcgAMc4IsY3cXpojsSxOc00CqLmIfkz";
  await Stripe.instance.applySettings();
  await Firebase.initializeApp();
  runApp(const Wrapper());
}
