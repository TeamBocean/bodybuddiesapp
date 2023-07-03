import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/apple_sign_in_btn.dart';
import 'package:bodybuddiesapp/widgets/google_sign_in_btn.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
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

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: Dimensions.height20),
              child: Column(
                children: [
                  Center(child: Logo(assetName: 'logo.png')),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                  welcomeMessage(),
                ],
              ),
            ),
            // signInForm(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GoogleSignInBTN(),
                  Visibility(visible: Platform.isIOS, child: AppleSignInBTN()),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Center(child: blueOceanMessage()),
                ],
              ),
            ),
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

  Widget blueOceanMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MediumTextWidget(
          text: "Developed by",
          fontSize: Dimensions.fontSize16,
        ),
        // SizedBox(
        //   height: Dimensions.height5,
        // ),
        // MediumTextWidget(text: "BlueOcean", fontSize: Dimensions.fontSize28,),
        SizedBox(
          height: Dimensions.height5,
        ),
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse("https://blue-ocean.ie/"));
          },
          child: Text(
            "BlueOcean",
            style: GoogleFonts.candal(
              fontSize: Dimensions.fontSize20,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget welcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          fontSize: Dimensions.fontSize14,
          color: Colors.grey,
        ),
      ],
    );
  }
}
