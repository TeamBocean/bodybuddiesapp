import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/authentication.dart';
import '../utils/colors.dart';

class GoogleSignInBTN extends StatefulWidget {
  const GoogleSignInBTN({Key? key}) : super(key: key);

  @override
  State<GoogleSignInBTN> createState() => _GoogleSignInBTNState();
}

class _GoogleSignInBTNState extends State<GoogleSignInBTN> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return _isSigningIn
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(bbAccent),
          )
        : _buildEditorialButton();
  }

  Widget _buildEditorialButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => onSignInClicked(),
        icon: Image.network(
          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
          width: 20,
          height: 20,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.g_mobiledata, color: bbText, size: 22),
        ),
        label: Text(
          "Continue with Google",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: bbText,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: bbSurface,
          side: const BorderSide(color: bbBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void onSignInClicked() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      User? user = await Authentication.signInWithGoogle(context: context);

      if (!mounted) return;

      if (user != null) {
        print('Google sign-in successful for: ${user.email}');
      }
    } catch (e) {
      print('Error during Google sign-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed. Please try again.',
                style: GoogleFonts.inter()),
            backgroundColor: bbCard,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }
}
