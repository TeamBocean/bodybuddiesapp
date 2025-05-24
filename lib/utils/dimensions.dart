import 'package:flutter/material.dart';

class Dimensions {
  static late double screenHeight;
  static late double screenWidth;

  static void init(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }

  /// Height
  static double height1 = screenHeight / 852;
  static double height3 = screenHeight / 284;
  static double height5 = screenHeight / 170.4;
  static double height7 = screenHeight / 121.714;
  static double height8 = screenHeight / 106.5;
  static double height9 = screenHeight / 94.66;
  static double height10 = screenHeight / 85.2;
  static double height11 = screenHeight / 77.454;
  static double height12 = screenHeight / 71;
  static double height13p21 = screenHeight / 64.49;
  static double height14 = screenHeight / 60.857;
  static double height15 = screenHeight / 56.8;
  static double height16 = screenHeight / 53.25;
  static double height17 = screenHeight / 50.11;
  static double height18 = screenHeight / 47.33;
  static double height20 = screenHeight / 42.6;
  static double height21 = screenHeight / 40.57;
  static double height22 = screenHeight / 38.727;
  static double height23 = screenHeight / 37.04;
  static double height24 = screenHeight / 35.5;
  static double height25 = screenHeight / 34.08;
  static double height30 = screenHeight / 28.4;
  static double height31 = screenHeight / 27.483;
  static double height32 = screenHeight / 26.62;
  static double height35 = screenHeight / 24.34;
  static double height43 = screenHeight / 19.813;
  static double height46 = screenHeight / 18.52;
  static double height50 = screenHeight / 17.04;

  /// Width
  static double width0p5 = screenWidth / 786;
  static double width1 = screenWidth / 393;
  static double width5 = screenWidth / 78.6;
  static double width6 = screenWidth / 65.5;
  static double width8 = screenWidth / 49.125;
  static double width9 = screenWidth / 43.66;
  static double width10 = screenWidth / 39.3;
  static double width12 = screenWidth / 32.75;
  static double width13 = screenWidth / 30.23;
  static double width14 = screenWidth / 28.07;
  static double width15 = screenWidth / 26.2;
  static double width16 = screenWidth / 24.562;
  static double width17 = screenWidth / 23.117;
  static double width17p5 = screenWidth / 22.457;
  static double width18p5 = screenWidth / 21.24;
  static double width18 = screenWidth / 21.83;
  static double width20 = screenWidth / 19.65;
  static double width23 = screenWidth / 17.08;
  static double width24 = screenWidth / 16.375;
  static double width27 = screenWidth / 14.55;
  static double width35 = screenWidth / 11.23;
  static double width50 = screenWidth / 7.86;
  static double width60 = screenWidth / 6.55;
  static double width96 = screenWidth / 4.093;

  /// Font Size
  static double fontSize7 = screenHeight / 121.714;
  static double fontSize10 = screenHeight / 85.2;
  static double fontSize11 = screenHeight / 77.45;
  static double fontSize12 = screenHeight / 71;
  static double fontSize13 = screenHeight / 65.54;
  static double fontSize14 = screenHeight / 60.857;
  static double fontSize15 = screenHeight / 56.8;
  static double fontSize16 = screenHeight / 53.25;
  static double fontSize17 = screenHeight / 50.11;
  static double fontSize18 = screenHeight / 47.33;
  static double fontSize20 = screenHeight / 42.6;
  static double fontSize22 = screenHeight / 38.727;
  static double fontSize28 = screenHeight / 30.42;
  static double fontSize30 = screenHeight / 28.4;
  static double fontSize32 = screenHeight / 26.62;
  static double fontSize35 = screenHeight / 28.4;

  /// Icon Size
  static double iconSize11 = screenHeight / 77.454;
  static double iconSize20 = screenHeight / 42.6;
  static double iconSize13 = screenHeight / 65.54;
  static double iconSize15 = screenHeight / 56.8;
  static double iconSize16 = screenHeight / 53.25;
}
