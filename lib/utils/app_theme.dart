import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  // ─── Editorial Atelier Theme ──────────────────────────────────────────────
  // Bone canvas · Playfair Display serif · Plus Jakarta Sans geometric sans
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bbBackground,
      colorScheme: const ColorScheme.light(
        primary: bbAccent,
        secondary: bbAccentAlt,
        surface: bbSurface,
        background: bbBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: bbText,
        onBackground: bbText,
        outline: bbBorder,
        error: bbRed,
        onError: Colors.white,
      ),

      // ─── Typography ─────────────────────────────────────────────────────
      textTheme: TextTheme(
        // Display – Playfair Display (editorial serif headlines)
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 56, color: bbText, height: 1.05, fontWeight: FontWeight.w400,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 44, color: bbText, height: 1.08, fontWeight: FontWeight.w400,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 36, color: bbText, height: 1.1, fontWeight: FontWeight.w400,
        ),
        // Headlines – Playfair Display
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32, color: bbText, height: 1.1, fontWeight: FontWeight.w500,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 26, color: bbText, height: 1.15, fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 20, color: bbText, height: 1.2, fontWeight: FontWeight.w500,
        ),
        // Titles – Plus Jakarta Sans (geometric, wide-spaced)
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: bbText, letterSpacing: 0.2,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: bbText, letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: bbTextSecondary, letterSpacing: 0.1,
        ),
        // Body – Plus Jakarta Sans (clean, readable)
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, color: bbText, height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: bbTextSecondary, height: 1.5,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12, color: bbTextMuted, height: 1.4,
        ),
        // Labels
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: bbText, letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w500, color: bbTextSecondary, letterSpacing: 0.4,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 10, color: bbTextMuted, letterSpacing: 1.2, fontWeight: FontWeight.w500,
        ),
      ),

      // ─── Cards ──────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: bbSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: bbBorder, width: 0.5),
        ),
      ),

      // ─── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bbBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: bbText),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: bbText,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),

      // ─── Buttons ────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bbAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: bbText,
          side: const BorderSide(color: bbBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ─── Bottom Nav ─────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bbBackground,
        selectedItemColor: bbAccent,
        unselectedItemColor: bbTextMuted,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // ─── Input Fields ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bbSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bbBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bbBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bbAccent, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: bbTextMuted, fontSize: 14),
        labelStyle: GoogleFonts.plusJakartaSans(color: bbTextSecondary, fontSize: 14),
      ),

      // ─── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: bbSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22, color: bbText, fontWeight: FontWeight.w500,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: bbTextSecondary, height: 1.5,
        ),
      ),

      // ─── Misc ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: bbBorder,
        thickness: 0.5,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bbCard,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: bbText, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: bbAccent,
      ),
      iconTheme: const IconThemeData(color: bbTextSecondary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: bbAccent,
      ),
    );
  }

  // ─── Light Theme (alias to editorial theme) ───────────────────────────────
  static ThemeData get lightTheme {
    return darkTheme; // The editorial theme IS light — unified
  }
}
