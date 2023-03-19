import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: Dimensions.height30),
              child: Center(child: Logo(assetName: 'logo.png')),
            ),
            welcomeMessage()
          ],
        ),
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
          fontSize: Dimensions.fontSize12,
          color: Colors.grey,
        ),
      ],
    );
  }
}
