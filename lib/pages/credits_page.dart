import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../models/user.dart';
import '../../services/cloud_firestore.dart';
import '../../services/email.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/medium_text_widget.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({Key? key}) : super(key: key);

  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  bool isBuddy = false;
  Map<String, dynamic>? paymentIntent;
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Credits'),
        backgroundColor: background,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: background,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                          onPressed: _isProcessingPayment ? null : () {
                            setState(() {
                              isBuddy = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: isBuddy ? darkGrey : darkGreen),
                          child: MediumTextWidget(
                            text: "Personal",
                            fontSize: Dimensions.fontSize14,
                          )),
                    ),
                    SizedBox(
                      width: Dimensions.width20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                          onPressed: _isProcessingPayment ? null : () {
                            setState(() {
                              isBuddy = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: !isBuddy ? darkGrey : darkGreen),
                          child: MediumTextWidget(
                            text: "Buddy",
                            fontSize: Dimensions.fontSize14,
                          )),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    paymentOptionWidget(isBuddy ? 500 : 400, "8", "8"),
                    paymentOptionWidget(isBuddy ? 650 : 550, "12", "12"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    paymentOptionWidget(isBuddy ? 1200 : 1000, "24", "24"),
                    paymentOptionWidget(isBuddy ? 1800 : 1500, "36", "36"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget paymentOptionWidget(double price, String credits, String session) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height12),
      child: Container(
        width: MediaQuery.of(context).size.width / 2.1,
        height: Dimensions.height12 * 22,
        color: darkGrey,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width12, vertical: Dimensions.height12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumTextWidget(
                    text: "$credits Credits",
                    fontSize: Dimensions.fontSize18,
                  ),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                ],
              ),
              MediumTextWidget(
                text: "$session Sessions",
                fontSize: Dimensions.fontSize14,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumTextWidget(
                    text: "€${price.toStringAsFixed(0)}",
                    fontSize: Dimensions.fontSize28,
                    color: darkGreen,
                  ),
                  StreamBuilder<UserModel?>(
                      stream: CloudFirestore().streamUserData(
                          FirebaseAuth.instance.currentUser!.uid),
                      builder: (context, snapshot) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              onPressed: (_isProcessingPayment || snapshot.data == null)
                                  ? null
                                  : () {
                                      makePayment(price, int.parse(credits));
                                    },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: background),
                              child: _isProcessingPayment
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: darkGreen,
                                      ),
                                    )
                                  : MediumTextWidget(
                                      text: "Purchase",
                                      fontSize: Dimensions.fontSize14,
                                    )),
                        );
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePayment(double price, int credits) async {
    if (_isProcessingPayment) return; // Prevent double-tap
    
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Create payment intent
      final result = await createPaymentIntent(price.toStringAsFixed(0), 'EUR');
      
      if (result == null) {
        throw Exception('Failed to create payment intent');
      }
      
      // Check for Stripe API errors
      if (result['error'] != null) {
        throw Exception(result['error']['message'] ?? 'Payment failed');
      }
      
      paymentIntent = result;
      
      // Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'BodyBuddies',
        ),
      );

      // Display Payment Sheet and handle result
      await displayPaymentSheet(credits, price);
      
    } catch (e) {
      print('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Future<void> displayPaymentSheet(int credits, double price) async {
    try {
      // Present the payment sheet - this throws if cancelled
      await Stripe.instance.presentPaymentSheet();
      
      // If we get here, payment was successful!
      // Now add credits to the user's account
      final userId = FirebaseAuth.instance.currentUser!.uid;
      
      // Add credits and verify it succeeded
      final creditsAdded = await CloudFirestore().addCredits(
        credits,
        userId,
        isBuddy ? "2:1" : "1:1",
      );
      
      if (!creditsAdded) {
        // CRITICAL: Payment succeeded but credits failed to add
        // Log this for manual resolution
        print('CRITICAL: Payment succeeded but credits failed to add for user $userId');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment received but there was an issue adding credits. Please contact support."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 10),
            ),
          );
        }
        return;
      }
      
      CloudFirestore().addUserSubscription(
        userId,
        credits,
        isBuddy ? "2:1" : "1:1",
        price,
      );
      
      EmailService().sendSubscriptionConfirmationToUser();
      
      // Clear the payment intent
      paymentIntent = null;
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: darkGrey,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$credits credits have been added to your account.",
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "OK",
                  style: TextStyle(color: darkGreen),
                ),
              ),
            ],
          ),
        );
      }
      
    } on StripeException catch (e) {
      // User cancelled the payment sheet
      print('Payment cancelled: ${e.error.localizedMessage}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment cancelled"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow; // Re-throw to be caught by the outer try-catch
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    final secretKey = dotenv.env['STRIPE_SECRET_KEY'];
    if (secretKey == null || secretKey.isEmpty) {
      throw Exception(
        'Missing STRIPE_SECRET_KEY in .env. '
        'This key must be provided by the backend.',
      );
    }

    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      
      print('Payment Intent Response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        print('Stripe API Error: ${errorBody}');
        return errorBody; // Return error to be handled
      }
      
      return jsonDecode(response.body);
    } catch (err) {
      print('Error creating payment intent: ${err.toString()}');
      return null;
    }
  }

  String calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }
}
