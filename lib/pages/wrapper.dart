import 'package:bodybuddiesapp/pages/main_scaffold.dart';
import 'package:bodybuddiesapp/pages/settings_page.dart';
import 'package:bodybuddiesapp/pages/sign_in_page.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/bottom_nav_bar.dart';
import 'package:bodybuddiesapp/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bodybuddiesapp/providers/theme_provider.dart';
import 'package:bodybuddiesapp/utils/app_theme.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';

import 'bookings_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    Dimensions.init(context);
    return SignInPage();
  }
}
