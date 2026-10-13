import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized Material 3 Theme for GroundZero
/// Incorporates Plus Jakarta Sans, 20px rounded cards,
/// custom soft elevation, and calibrated Light & Dark palettes.
class AppTheme {
  AppTheme._();

  // Card Border Radius standard across the app
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double inputRadius = 14.0;

  // Soft atmospheric shadows
  static List<BoxShadow> get softShadowLight => [
    BoxShadow(
      color: AppColors.navy.withValues(alpha: 0.04),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.navy.withValues(alpha: 0.02),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get softShadowDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // Elevated card shadow for floating elements (e.g. Floating Bottom Nav)
  static List<BoxShadow> get floatingShadowLight => [
    BoxShadow(
      color: AppColors.navy.withValues(alpha: 0.08),
      offset: const Offset(0, 8),
      blurRadius: 28,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get floatingShadowDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      offset: const Offset(0, 8),
      blurRadius: 28,
      spreadRadius: -4,
    ),
  ];

  // Light Theme
  static ThemeData get lightTheme {
    final fontName = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontName,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.emerald,
        onPrimary: Colors.white,
        primaryContainer: AppColors.emeraldContainer,
        onPrimaryContainer: AppColors.navy,
        secondary: AppColors.navy,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.limeContainer,
        onSecondaryContainer: AppColors.navy,
        tertiary: AppColors.lime,
        onTertiary: AppColors.navy,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.surfaceSecondaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: AppColors.borderLight,
        outlineVariant: AppColors.borderLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.015,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: AppColors.textMutedLight,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontName,
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.textMutedLight,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.textSecondaryLight,
        suffixIconColor: AppColors.textSecondaryLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.emerald, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSecondaryLight,
        disabledColor: AppColors.borderLight,
        selectedColor: AppColors.emerald,
        secondarySelectedColor: AppColors.emeraldContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: Colors.transparent),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final fontName = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontName,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.emerald,
        onPrimary: AppColors.navy,
        primaryContainer: AppColors.navyLighter,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.lime,
        onSecondary: AppColors.navy,
        secondaryContainer: AppColors.navyLight,
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.lime,
        onTertiary: AppColors.navy,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.surfaceSecondaryDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: AppColors.borderDark,
        outlineVariant: AppColors.borderDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.015,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: AppColors.textMutedDark,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontName,
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondaryDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.textMutedDark,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.textSecondaryDark,
        suffixIconColor: AppColors.textSecondaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.emerald, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSecondaryDark,
        disabledColor: AppColors.borderDark,
        selectedColor: AppColors.emerald,
        secondarySelectedColor: AppColors.emeraldContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: Colors.transparent),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
