import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData get darkTheme => _buildFigmaTheme();

  // The current Figma system is dark-only, so light mode intentionally resolves
  // to the same token set until a light companion system exists in Figma.
  static ThemeData get lightTheme => _buildFigmaTheme();

  static ThemeData _buildFigmaTheme() {
    const colorScheme = ColorScheme.dark(
      primary: bbAccent,
      secondary: bbAccentAlt,
      surface: bbSurface,
      onPrimary: bbOnAccent,
      onSecondary: bbBackground,
      onSurface: bbText,
      outline: bbBorder,
      error: bbRed,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: bbBackground,
      canvasColor: bbBackground,
      cardColor: bbCard,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: bbBackground,
        foregroundColor: bbText,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: bbText, size: 22),
        titleTextStyle: GoogleFonts.inter(
          color: bbText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
      ),
      cardTheme: CardTheme(
        color: bbCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: bbBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bbAccent,
          foregroundColor: bbOnAccent,
          disabledBackgroundColor: bbCard,
          disabledForegroundColor: bbTextMuted,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: bbText,
          side: const BorderSide(color: bbBorder, width: 1),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: bbAccent,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bbSurface,
        selectedItemColor: bbAccent,
        unselectedItemColor: bbTextMuted,
        elevation: 0,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bbSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: bbBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: bbBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: bbAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: bbRed, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: bbTextMuted,
          fontSize: 14,
          letterSpacing: 0,
        ),
        labelStyle: GoogleFonts.inter(
          color: bbTextSecondary,
          fontSize: 14,
          letterSpacing: 0,
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: bbOnAccent,
        unselectedLabelColor: bbTextSecondary,
        indicator: BoxDecoration(
          color: bbAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bbSurface,
        disabledColor: bbCard,
        selectedColor: bbAccent,
        secondarySelectedColor: bbAccent,
        labelStyle: GoogleFonts.inter(
          color: bbTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          color: bbOnAccent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        side: const BorderSide(color: bbBorder, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: bbSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          color: bbText,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: bbTextSecondary,
          height: 1.45,
          letterSpacing: 0,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: bbBorder,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bbCard,
        contentTextStyle: GoogleFonts.inter(
          color: bbText,
          fontSize: 14,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: bbAccent,
      ),
      iconTheme: const IconThemeData(color: bbTextSecondary, size: 22),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: bbAccent),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? bbOnAccent : bbTextMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? bbAccent : bbCard,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        color: bbText,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 30,
        color: bbText,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        color: bbText,
        height: 1.16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        color: bbText,
        height: 1.16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        color: bbText,
        height: 1.22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        color: bbText,
        height: 1.24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: bbText,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: bbText,
        letterSpacing: 0,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: bbAccentAlt,
        letterSpacing: 0,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 14,
        color: bbText,
        height: 1.45,
        letterSpacing: 0,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 12,
        color: bbTextSecondary,
        height: 1.45,
        letterSpacing: 0,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 10,
        color: bbTextMuted,
        height: 1.35,
        letterSpacing: 0,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: bbText,
        letterSpacing: 0,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: bbAccentAlt,
        letterSpacing: 0,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        color: bbTextSecondary,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
