import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';

import '../utils/constants.dart';

class BottomNavBar extends StatefulWidget {
  int currentIndex;
  PageController? controller;

  BottomNavBar({required this.currentIndex, required this.controller});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: background,
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Color(0xff2B2B2B),
          onTap: onTabTapped,
          currentIndex: widget.currentIndex,
          selectedLabelStyle: TextStyle(color: Colors.white),
          unselectedLabelStyle:
              TextStyle(color: Colors.white, fontSize: Dimensions.fontSize12),
          selectedItemColor: Colors.green,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              backgroundColor: background,
              icon: Image.asset(
                ASSETS + "home.png",
                color: widget.currentIndex == 0 ? darkGreen : Colors.white,
                height: Dimensions.height25,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              backgroundColor: background,
              icon: Image.asset(
                ASSETS + "bookings.png",
                color: widget.currentIndex == 1 ? darkGreen : Colors.white,
                height: Dimensions.height25,
              ),
              label: "Bookings",
            ),
            BottomNavigationBarItem(
              backgroundColor: background,
              icon: Image.asset(
                ASSETS + "account.png",
                color: widget.currentIndex == 3 ? darkGreen : Colors.white,
                height: Dimensions.height25,
              ),
              label: "Account",
            ),
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    if (mounted)
      setState(() {
        widget.currentIndex = index;
        widget.controller!.jumpToPage(index);
      });
  }

  Widget bottomNavBarContainer(
    Widget widget,
  ) {
    return Container(
      child: widget,
      height: 100,
    );
  }
}
