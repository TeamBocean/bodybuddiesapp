import 'dart:convert';
import 'package:bodybuddiesapp/config/payment_runtime_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user.dart';
import '../../services/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../widgets/stamp_seal_painter.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({Key? key}) : super(key: key);

  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  bool isBuddy = false;
  Map<String, dynamic>? paymentIntent;
  bool _isProcessingPayment = false;
  int _pendingCredits = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bbBackground,
      appBar: AppBar(
        title: Text(
          'Training Credits',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: bbText,
          ),
        ),
        backgroundColor: bbBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: bbText),
      ),
      body: StreamBuilder<UserModel?>(
        stream: CloudFirestore()
            .streamUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, userSnapshot) {
          final currentCredits = userSnapshot.data?.credits ?? 0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRewardCard(
                    credits: currentCredits,
                    rewardStamps: userSnapshot.data?.rewardStamps ?? 0,
                  ),
                  SizedBox(height: Dimensions.height20 + Dimensions.height10),

                  // ─── Subtitle ──────────────────────────────────────────
                  Text(
                    "INVEST IN YOURSELF.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: bbTextSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Choose your plan.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: bbTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),

                  // ─── Session Type Toggle ────────────────────────────────
                  _buildSessionToggle(),
                  SizedBox(height: Dimensions.height20 + Dimensions.height10),

                  // ─── Session Packs ────────────────────────────────────
                  _buildSessionPack(
                    credits: 8,
                    label: "Eight Sessions",
                    price: isBuddy ? 560 : 440,
                    description: "A thoughtful start to your journey.",
                  ),
                  SizedBox(height: Dimensions.height15),
                  _buildSessionPack(
                    credits: 12,
                    label: "Twelve Sessions",
                    price: isBuddy ? 720 : 600,
                    description: "The most popular choice.",
                    isHighlighted: true,
                  ),
                  SizedBox(height: Dimensions.height15),
                  _buildSessionPack(
                    credits: 36,
                    label: "Thirty-Six Sessions",
                    price: isBuddy ? 1800 : 1620,
                    description: "For the deeply committed.",
                  ),
                  SizedBox(height: Dimensions.height35),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REWARD CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRewardCard({
    required int credits,
    required int rewardStamps,
  }) {
    final maxDisplay = 12;
    final displayStamps = rewardStamps.clamp(0, maxDisplay);
    final stampsRemaining = maxDisplay - displayStamps;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: bbSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bbBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: bbBorder.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "REWARD CARD",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: bbTextSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                ),
              ),
              Text(
                "$credits credits",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: bbTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stamp circles grid — 3 rows × 4 cols
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(maxDisplay, (i) {
                final isFilled = i < displayStamps;
                return SizedBox(
                  width: 40,
                  height: 40,
                  child: StampSeal(
                    size: 40,
                    color: isFilled ? bbAccent : bbBorder,
                    progress: isFilled ? 1.0 : 0.25,
                    isFilled: isFilled,
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Thin divider
          Container(height: 0.5, color: bbBorder),
          const SizedBox(height: 16),

          // Footer message
          Center(
            child: Text(
              stampsRemaining == 0
                  ? "Your next booked session unlocks a free credit."
                  : "$stampsRemaining more stamps unlocks 1 free session.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: bbTextMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION TOGGLE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSessionToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bbCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleOption("Personal", !isBuddy)),
          Expanded(child: _buildToggleOption("Buddy", isBuddy)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isActive) {
    return GestureDetector(
      onTap: _isProcessingPayment
          ? null
          : () {
              setState(() {
                isBuddy = label == "Buddy";
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? bbSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: bbBorder.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? bbText : bbTextMuted,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION PACK — Tapping opens the bottom sheet
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSessionPack({
    required int credits,
    required String label,
    required double price,
    required String description,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: _isProcessingPayment
          ? null
          : () => _showSessionPackSheet(
                credits: credits,
                label: label,
                price: price,
                description: description,
                isHighlighted: isHighlighted,
              ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isHighlighted ? bbAccent.withOpacity(0.06) : bbSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted ? bbAccent.withOpacity(0.3) : bbBorder,
            width: isHighlighted ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: bbBorder.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isHighlighted)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bbAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "MOST POPULAR",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: bbText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: bbTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "€${price.toStringAsFixed(0)}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: bbAccent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "€${(price / credits).toStringAsFixed(0)} per session",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: bbTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tap to view indicator
            Center(
              child: Text(
                "Tap to view →",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: bbTextMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM SHEET — "The Session Pack" detail
  // ═══════════════════════════════════════════════════════════════════════════
  void _showSessionPackSheet({
    required int credits,
    required String label,
    required double price,
    required String description,
    required bool isHighlighted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: bbSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: bbBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Sheet title
              Text(
                "The Session Pack",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: bbTextMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),

              // Pack name
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  color: bbText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: bbTextSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Preview: what you'll receive
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bbCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Stamp circle preview
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: List.generate(credits.clamp(0, 12), (i) {
                        return StampSeal(
                          size: 28,
                          color: bbAccent,
                          progress: 1.0,
                          isFilled: true,
                        );
                      }),
                    ),
                    if (credits > 12) ...[
                      const SizedBox(height: 8),
                      Text(
                        "+ ${credits - 12} more stamps",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: bbTextMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      "$credits sessions · ${isBuddy ? '2:1' : '1:1'}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: bbTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Price
              Text(
                "€${price.toStringAsFixed(0)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40,
                  color: bbAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "€${(price / credits).toStringAsFixed(0)} per session",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: bbTextMuted,
                ),
              ),
              const SizedBox(height: 28),

              // Purchase button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment
                      ? null
                      : () {
                          Navigator.pop(sheetContext);
                          makePayment(price, credits);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bbAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessingPayment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Purchase Pack",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT LOGIC (unchanged)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> makePayment(double price, int credits) async {
    if (_isProcessingPayment) return;

    setState(() {
      _isProcessingPayment = true;
      _pendingCredits = credits;
    });

    try {
      final result = await createPaymentIntent(
        price.toStringAsFixed(0),
        'EUR',
        credits: credits,
        creditType: isBuddy ? "2:1" : "1:1",
      );

      if (result == null) {
        throw Exception('Failed to create payment intent');
      }

      final error = result['error'];
      if (error != null) {
        throw Exception(_paymentErrorMessage(error));
      }

      paymentIntent = result;
      final clientSecret = paymentIntent!['client_secret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Stripe did not return a payment client secret');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          merchantDisplayName: 'BodyBuddies',
        ),
      );

      await displayPaymentSheet(credits, price);
    } catch (e) {
      print('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyPaymentError(e),
                style: GoogleFonts.plusJakartaSans()),
            backgroundColor: bbRed,
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
      await Stripe.instance.presentPaymentSheet();

      paymentIntent = null;

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: bbSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // Stamp seal checkmark
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      StampSeal(
                        size: 64,
                        color: bbAccent,
                        progress: 1.0,
                        isFilled: true,
                      ),
                      Icon(
                        Icons.check_rounded,
                        color: bbAccent,
                        size: 28,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome to your\nnext chapter.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    color: bbText,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$credits sessions are being\nadded to your credits.",
                  style: GoogleFonts.plusJakartaSans(
                    color: bbTextSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.plusJakartaSans(
                      color: bbAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } on StripeException catch (e) {
      print('Payment cancelled: ${e.error.localizedMessage}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Payment cancelled", style: GoogleFonts.plusJakartaSans()),
            backgroundColor: bbCard,
          ),
        );
      }
    } catch (e) {
      print('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyPaymentError(e),
                style: GoogleFonts.plusJakartaSans()),
            backgroundColor: bbRed,
          ),
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
    String amount,
    String currency, {
    required int credits,
    required String creditType,
  }) async {
    final endpoint = PaymentRuntimeConfig.paymentIntentEndpoint;
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception(
        'Missing payment endpoint in .env. '
        'Stripe PaymentIntents must be created by the backend.',
      );
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userId = user.uid;
      final idToken = await user.getIdToken();
      final userEmail = user.email?.trim();
      final body = {
        'amount': int.parse(calculateAmount(amount)),
        'currency': currency,
        'userId': userId,
        'credits': credits,
        'creditType': creditType,
        if (userEmail != null && userEmail.isNotEmpty)
          'receiptEmail': userEmail,
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(body),
      );

      print('Payment Intent Response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        print('Stripe API Error: ${errorBody}');
        throw Exception(_paymentErrorMessage(errorBody is Map<String, dynamic>
            ? errorBody['error']
            : errorBody));
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final nestedPaymentIntent = decoded['paymentIntent'];
      if (nestedPaymentIntent is Map<String, dynamic>) {
        return nestedPaymentIntent;
      }
      return decoded;
    } catch (err) {
      print('Error creating payment intent: ${err.toString()}');
      return null;
    }
  }

  String calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  String _friendlyPaymentError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('api key') ||
        message.contains('payment_intent_endpoint') ||
        message.contains('client secret')) {
      return 'Payment setup failed. Please contact Body Buddies.';
    }
    return 'Payment failed. Please try again.';
  }

  String _paymentErrorMessage(Object? error) {
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    if (error is String && error.isNotEmpty) return error;
    return 'Payment failed';
  }
}
