import 'package:bodybuddiesapp/pages/bookings_page.dart';
import 'package:bodybuddiesapp/pages/main_scaffold.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

import '../pages/on_boarding_page.dart';
import '../services/authentication.dart';

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
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
        : FutureBuilder(
            future: Authentication.initializeFirebase(context: context),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error initializing Firebase');
              } else if (snapshot.connectionState == ConnectionState.done) {
                return SignInButton(
                  Buttons.GoogleDark,
                  onPressed: () => onSignInClicked(),
                );
              }
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange,
                ),
              );
            },
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
        
        // Check if user document exists
        final userExists = await CloudFirestore().isUserExists();
        
        if (!mounted) return;
        
        if (userExists) {
          print('User document exists, navigating to main app');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScaffold(),
            ),
          );
        } else {
          print('User document does not exist, navigating to onboarding');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnBoardingPage(),
            ),
          );
        }
      } else {
        print('Google sign-in returned null user');
      }
    } catch (e) {
      print('Error during Google sign-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed. Please try again.'),
            backgroundColor: Colors.red.shade700,
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
