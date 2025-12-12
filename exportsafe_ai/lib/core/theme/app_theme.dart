<<<<<<< HEAD
﻿import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryNavyBlue = Color(0xFF0A2342);
  static const Color secondaryEmeraldGreen = Color(0xFF2CA58D);
  static const Color errorCrimsonRed = Color(0xFFD72638);
  static const Color backgroundOffWhite = Color(0xFFF4F4F9);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textDisabled = Color(0xFFCCCCCC);
=======
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primaryColor = Color(0xFFFF3B3B); // Brand Red
  static const Color secondaryColor = Color(0xFF2CA58D); // Emerald Green
  static const Color errorColor = Color(0xFFD72638); // Crimson Red
  static const Color backgroundColor = Color(0xFFF4F4F9); // Off-White
  static const Color surfaceColor = Colors.white;
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
<<<<<<< HEAD
      colorScheme: ColorScheme.light(
        primary: primaryNavyBlue,
        secondary: secondaryEmeraldGreen,
        error: errorCrimsonRed,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundOffWhite,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textDisabled,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavyBlue,
=======
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: Colors.black87,
        displayColor: primaryColor,
      ),
      
      // Component Styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
<<<<<<< HEAD
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavyBlue,
          side: const BorderSide(color: primaryNavyBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
=======
      
      cardTheme: CardThemeData(
        color: surfaceColor,
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
<<<<<<< HEAD
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryNavyBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorCrimsonRed),
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: textDisabled,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryNavyBlue,
=======
        margin: const EdgeInsets.all(8),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
<<<<<<< HEAD
          fontWeight: FontWeight.bold,
=======
          fontWeight: FontWeight.w600,
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
          color: Colors.white,
        ),
      ),
    );
  }
}
