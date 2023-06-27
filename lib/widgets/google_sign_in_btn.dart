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

    User? user = await Authentication.signInWithGoogle(context: context);

    setState(() {
      _isSigningIn = false;
    });

    if (user != null) {
      await CloudFirestore().isUserExists().then((userExists) {
        if (userExists) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScaffold(),
            ),
          );
        }else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnBoardingPage(),
            ),
          );
        }
      });
    }
  }
}
