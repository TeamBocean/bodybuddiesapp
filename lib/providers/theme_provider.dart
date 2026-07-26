import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode get themeMode => ThemeMode.dark;

  bool get isDarkMode => true;
}
