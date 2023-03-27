import 'package:bodybuddiesapp/pages/main_scaffold.dart';
import 'package:bodybuddiesapp/pages/profile_page.dart';
import 'package:bodybuddiesapp/pages/sign_in_page.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/bottom_nav_bar.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'bookings_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<Wrapper> {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(backgroundColor: background, fontFamily: 'Satoshi'),
      home: SignInPage(),
    );
  }
}
