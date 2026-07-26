import 'package:bodybuddiesapp/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme provider always enforces dark mode', () {
    final provider = ThemeProvider();

    expect(provider.themeMode, ThemeMode.dark);
    expect(provider.isDarkMode, isTrue);
  });
}
