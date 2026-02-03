import 'package:bodybuddiesapp/pages/main_scaffold.dart';
import 'package:bodybuddiesapp/pages/on_boarding_page.dart';
import 'package:bodybuddiesapp/pages/settings_page.dart';
import 'package:bodybuddiesapp/pages/sign_in_page.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/bottom_nav_bar.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bodybuddiesapp/providers/theme_provider.dart';
import 'package:bodybuddiesapp/utils/app_theme.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'bookings_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    Dimensions.init(context);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const SignInPage();
          }
          // Check if user document exists before allowing access to main app
          return FutureBuilder<bool>(
            future: CloudFirestore().isUserExists(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (docSnapshot.data == true) {
                return const MainScaffold();
              }
              // User is authenticated but has no Firestore document - send to onboarding
              return const OnBoardingPage();
            },
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
