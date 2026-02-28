import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/apple_sign_in_btn.dart';
import 'package:bodybuddiesapp/widgets/google_sign_in_btn.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../utils/colors.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bbBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20 * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),

                // ─── Logo (understated) ──────────────────────────────────
                Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Logo(assetName: 'logo.png'),
                  ),
                ),
                SizedBox(height: Dimensions.height35),

                // ─── Editorial Headline ──────────────────────────────────
                Text(
                  "Your studio\nawaits.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 42,
                    color: bbText,
                    height: 1.1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: Dimensions.height15),

                // ─── Subtitle ────────────────────────────────────────────
                Text(
                  "Personal training, reimagined.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: bbTextSecondary,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 2),

                // ─── Sign-in Buttons ─────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      GoogleSignInBTN(),
                      SizedBox(height: Dimensions.height10),
                      Visibility(
                        visible: Platform.isIOS,
                        child: AppleSignInBTN(),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // ─── Footer ──────────────────────────────────────────────
                Center(child: _buildFooter()),
                SizedBox(height: Dimensions.height20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "Developed by",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: bbTextMuted,
          ),
        ),
        SizedBox(height: Dimensions.height5),
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse("https://blue-ocean.ie/"));
          },
          child: Text(
            "BlueOcean",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: bbAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
