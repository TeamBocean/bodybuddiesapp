import 'package:flutter/material.dart';

import '../utils/constants.dart';

class Logo extends StatelessWidget {
  String assetName;

  Logo({required this.assetName});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ASSETS + assetName,
      width: 300,
    );
  }
}
