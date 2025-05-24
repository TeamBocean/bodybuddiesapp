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
          scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          onTap: onTabTapped,
          currentIndex: widget.currentIndex,
          selectedLabelStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
          unselectedLabelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSize12),
          selectedItemColor: Theme.of(context).colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Theme.of(context).textTheme.bodyLarge?.color,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              icon: Image.asset(
                ASSETS + "home.png",
                color: widget.currentIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyLarge?.color,
                height: Dimensions.height25,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              icon: Image.asset(
                ASSETS + "bookings.png",
                color: widget.currentIndex == 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyLarge?.color,
                height: Dimensions.height25,
              ),
              label: "Bookings",
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              icon: Image.asset(
                ASSETS + "account.png",
                color: widget.currentIndex == 2
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyLarge?.color,
                height: Dimensions.height25,
              ),
              label: "Settings",
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
