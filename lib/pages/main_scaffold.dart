import 'package:bodybuddiesapp/pages/nutrients_page.dart';
import 'package:bodybuddiesapp/pages/settings_page.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../widgets/bottom_nav_bar.dart';
import 'bookings_page.dart';
import 'home_page.dart';
import 'my_sessions_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final List<Widget> _pages = [
    const HomePage(),
    const BookingsPage(),
    const MySessionsPage(),
    const SettingsPage(),
  ];
  
  int _currentIndex = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
              controller: _controller,
              onPageChanged: (page) {
                setState(() {
                  _currentIndex = page;
                });
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                currentIndex: _currentIndex,
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
