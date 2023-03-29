import 'package:bodybuddiesapp/pages/nutrients_page.dart';
import 'package:bodybuddiesapp/pages/profile_page.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../widgets/bottom_nav_bar.dart';
import 'bookings_page.dart';
import 'home_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<MainScaffold> {

  List<Widget> pages = [];
  int currentIndex = 0;
  PageController? _controller;

  @override
  void initState() {
    pages = [
      HomePage(),
      BookingsPage(),
      NutrientsPage(),
      ProfilePage(),
    ];
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          PageView(
            physics: NeverScrollableScrollPhysics(),
            children: pages,
            controller: _controller,
            onPageChanged: (page) {
              setState(() {
                currentIndex = page;
              });
            },
          ),
          BottomNavBar(
            currentIndex: currentIndex,
            controller: _controller,
          )
        ],
      ),
    );
  }
}
