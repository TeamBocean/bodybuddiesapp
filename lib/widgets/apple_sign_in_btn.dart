import 'package:bodybuddiesapp/pages/main_scaffold.dart';
import 'package:bodybuddiesapp/pages/on_boarding_page.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/authentication.dart';
import '../utils/colors.dart';

class AppleSignInBTN extends StatefulWidget {
  const AppleSignInBTN({Key? key}) : super(key: key);

  @override
  State<AppleSignInBTN> createState() => _AppleSignInBTNState();
}

class _AppleSignInBTNState extends State<AppleSignInBTN> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return _isSigningIn
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(bbAccent),
          )
        : FutureBuilder(
            future: Authentication.initializeFirebase(context: context),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error initializing Firebase',
                    style: GoogleFonts.plusJakartaSans(color: bbRed));
              } else if (snapshot.connectionState == ConnectionState.done) {
                return _buildEditorialButton();
              }
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(bbAccent),
              );
            },
          );
  }

  Widget _buildEditorialButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => onSignInClicked(),
        icon: const Icon(Icons.apple, color: Colors.white, size: 22),
        label: Text(
          "Continue with Apple",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: bbText,
          side: BorderSide.none,
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
      User? user = await Authentication.signInWithApple(context: context);

      if (!mounted) return;

      if (user != null) {
        print('Apple sign-in successful for: ${user.email}');
        
        final userExists = await CloudFirestore().isUserExists();
        
        if (!mounted) return;
        
        if (userExists) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScaffold(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnBoardingPage(),
            ),
          );
        }
      }
    } catch (e) {
      print('Error during Apple sign-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed. Please try again.',
                style: GoogleFonts.plusJakartaSans()),
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
