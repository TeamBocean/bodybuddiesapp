import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(backgroundColor: background),
      home: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Logo(assetName: "logo.png"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
