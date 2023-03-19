import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';

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
          backgroundColor: background,
          splashColor: Colors.transparent,
        ),
        child: Container(
          height: 90,
          child: BottomNavigationBar(
            backgroundColor: Color(0xff2B2B2B),
            onTap: onTabTapped,
            currentIndex: widget.currentIndex,
            selectedLabelStyle: TextStyle(color: Colors.white),
            unselectedLabelStyle: TextStyle(color: Colors.white),
            selectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.white,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                backgroundColor: background,
                icon: Icon(
                  Icons.home,
                  color: Color(0xffC0FE6C),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                backgroundColor: background,
                icon: Icon(
                  Icons.calendar_month,
                  color: Color(0xffC0FE6C),
                ),
                label: "Bookings",
              ),
              BottomNavigationBarItem(
                backgroundColor: background,
                icon: Icon(
                  Icons.calendar_month,
                  color: Color(0xffC0FE6C),
                ),
                label: "Nutrition",
              ),
              BottomNavigationBarItem(
                backgroundColor: background,
                icon: Icon(
                  Icons.manage_accounts,
                  color: Color(0xffC0FE6C),
                ),
                label: "Account",
              ),
            ],
          ),
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
