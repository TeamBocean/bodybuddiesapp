import 'package:apple_sign_in/scope.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/google_sign_in_btn.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

import '../services/authentication.dart';
import '../utils/colors.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Center(child: Logo(assetName: 'logo.png')),
                welcomeMessage(),
              ],
            ),
            signInForm(),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MediumTextWidget(
                      text: "New to BodyBuilders?",
                      fontSize: Dimensions.fontSize12,
                    ),
                    MediumTextWidget(
                      text: "Join Now",
                      fontSize: Dimensions.fontSize12,
                      color: Colors.teal,
                    ),
                  ],
                ),
                GoogleSignInBTN(),
                SignInButton(Buttons.AppleDark, onPressed: () {
                  Authentication.signInWithApple(context: context, scopes: []);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget signInForm() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width24 + Dimensions.width10),
      child: Form(
          child: Column(
        children: [
          textFormField("Email", Icons.email),
          SizedBox(
            height: Dimensions.height10,
          ),
          textFormField("Password", Icons.password),
          SizedBox(
            height: Dimensions.height14,
          ),
          MediumTextWidget(
            text: "Forgot Password?",
            fontSize: Dimensions.fontSize12,
            color: Colors.white,
          ),
          SizedBox(
            width: Dimensions.width10 * 20,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  primary: darkGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.width10))),
              child: MediumTextWidget(
                text: "Login",
              ),
            ),
          )
        ],
      )),
    );
  }

  Widget textFormField(String hint, IconData iconData) {
    return TextFormField(
      cursorColor: Colors.white,
      decoration: InputDecoration(
        prefixIcon: Icon(
          iconData,
          color: Colors.white,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: green,
          ),
        ),
        hintStyle: TextStyle(color: Colors.grey),
        hintText: hint,
      ),
    );
  }

  Widget welcomeMessage() {
    return Column(
      children: [
        MediumTextWidget(
          text: "Welcome to",
          fontSize: Dimensions.fontSize16,
        ),
        MediumTextWidget(text: "Body Buddies Health & Fitness"),
        SizedBox(
          height: Dimensions.height15,
        ),
        MediumTextWidget(
          text: "Plan your workout with Mark",
          fontSize: Dimensions.fontSize13,
          color: Colors.grey,
        ),
      ],
    );
  }
}
