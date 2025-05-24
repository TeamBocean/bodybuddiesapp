import 'package:bodybuddiesapp/pages/bookings_page.dart';
import 'package:bodybuddiesapp/pages/main_scaffold.dart';
import 'package:bodybuddiesapp/pages/on_boarding_page.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

import '../services/authentication.dart';

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
                  Buttons.Apple,
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

    User? user = await Authentication.signInWithApple(context: context);

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
        } else {
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
