import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PipBoyColors {
  static const Color primary = Color(0xFF0300FF);
  static const Color primaryDim = Color(0xFF0200B3);
  static const Color primaryBright = Color(0xFF4D52FF);
  static const Color background = Color(0xFF0A0A0E);
  static const Color surface = Color(0xFF0F0F1A);
  static const Color surfaceVariant = Color(0xFF0A0A14);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF0000);
}

class PipBoyTheme {
  static ThemeData get theme {
    final textTheme = GoogleFonts.courierPrimeTextTheme().apply(
      bodyColor: PipBoyColors.primary,
      displayColor: PipBoyColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: PipBoyColors.primary,
      scaffoldBackgroundColor: PipBoyColors.background,
      colorScheme: const ColorScheme.dark(
        primary: PipBoyColors.primary,
        onPrimary: PipBoyColors.background,
        secondary: PipBoyColors.primaryBright,
        onSecondary: PipBoyColors.background,
        surface: PipBoyColors.surface,
        onSurface: PipBoyColors.primary,
        error: PipBoyColors.error,
        onError: PipBoyColors.background,
        background: PipBoyColors.background,
        onBackground: PipBoyColors.primary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: PipBoyColors.background,
        foregroundColor: PipBoyColors.primary,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PipBoyColors.background,
          foregroundColor: PipBoyColors.primary,
          side: const BorderSide(color: PipBoyColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PipBoyColors.surfaceVariant,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: PipBoyColors.primary, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: PipBoyColors.primary, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: PipBoyColors.primaryBright, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: PipBoyColors.primaryDim,
          letterSpacing: 2,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: PipBoyColors.primaryDim,
        ),
      ),
      iconTheme: const IconThemeData(
        color: PipBoyColors.primary,
      ),
    );
  }
}
