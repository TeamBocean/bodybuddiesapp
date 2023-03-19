import 'package:bodybuddiesapp/pages/bookings_page.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/bottom_nav_bar.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  List<Widget> pages = [];
  int currentIndex = 0;
  PageController? _controller;

  @override
  void initState() {
    pages = [
      BookingsPage(),
      BookingsPage(),
      BookingsPage(),
      BookingsPage(),
    ];
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(backgroundColor: background),
        home: Scaffold(
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
        ));
  }
}
