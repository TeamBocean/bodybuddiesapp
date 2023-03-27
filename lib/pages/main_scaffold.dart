import 'package:bodybuddiesapp/pages/home_page.dart';
import 'package:bodybuddiesapp/pages/profile_page.dart';
import 'package:bodybuddiesapp/pages/sign_in_page.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/bottom_nav_bar.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'bookings_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  List<Widget> pages = [];
  int currentIndex = 0;
  PageController? _controller;

  @override
  void initState() {
    pages = [
      HomePage(),
      BookingsPage(),
      HomePage(),
      ProfilePage(),
    ];
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(backgroundColor: background, fontFamily: 'Satoshi'),
        home: SignInPage(),
        // home: Scaffold(
        //   backgroundColor: background,
        //   body: Stack(
        //     children: [
        //       PageView(
        //         physics: NeverScrollableScrollPhysics(),
        //         children: pages,
        //         controller: _controller,
        //         onPageChanged: (page) {
        //           setState(() {
        //             currentIndex = page;
        //           });
        //         },
        //       ),
        //       BottomNavBar(
        //         currentIndex: currentIndex,
        //         controller: _controller,
        //       )
        //     ],
        //   ),
        // )
    );
  }
}
