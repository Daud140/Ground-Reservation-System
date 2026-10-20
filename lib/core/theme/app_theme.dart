import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Centralized Material 3 Theme for GroundZero ("Arena & Turf OS")
/// Features emerald-to-lime green gradients, 20px rounded cards,
/// soft shadows, pill chips, and custom GradientButton component.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // DESIGN TOKENS & DIMENSIONS
  // ---------------------------------------------------------------------------
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double inputRadius = 14.0;
  static const double pillRadius = 100.0;

  // ---------------------------------------------------------------------------
  // CORE BRAND COLORS
  // ---------------------------------------------------------------------------
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldDeep = Color(0xFF064E3B);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldContainer = Color(0xFFD1FAE5);

  static const Color lime = Color(0xFFA3E635);
  static const Color limeDark = Color(0xFF84CC16);
  static const Color limeContainer = Color(0xFFECFCCB);

  static const Color navy = Color(0xFF0F172A);
  static const Color navyLight = Color(0xFF1E293B);
  static const Color navyLighter = Color(0xFF334155);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondaryLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // GRADIENTS (Emerald to Lime & Deep Turf Sports Gradients)
  // ---------------------------------------------------------------------------
  /// Emerald-to-Lime vibrant gradient for primary actions and accents
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF047857), Color(0xFF10B981), Color(0xFF84CC16)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Dynamic emerald to lime diagonal gradient
  static const LinearGradient emeraldToLimeGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFFA3E635)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Deep forest to emerald header card gradient
  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      Color(0xFF064E3B), // Deepest forest pitch green
      Color(0xFF047857), // Mid emerald
      Color(0xFF059669),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Soft surface gradient with emerald tint
  static const LinearGradient surfaceTintGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF0FDF4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ---------------------------------------------------------------------------
  // SOFT SHADOWS
  // ---------------------------------------------------------------------------
  static List<BoxShadow> get softShadowLight => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      offset: const Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: emerald.withValues(alpha: 0.03),
      offset: const Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: emerald.withValues(alpha: 0.38),
      offset: const Offset(0, 6),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get softShadowDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // ---------------------------------------------------------------------------
  // REUSABLE CARD DECORATIONS
  // ---------------------------------------------------------------------------
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: borderLight, width: 1.2),
    boxShadow: softShadowLight,
  );

  static BoxDecoration get selectedCardDecoration => BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: emerald, width: 2),
    boxShadow: [
      BoxShadow(
        color: emerald.withValues(alpha: 0.15),
        offset: const Offset(0, 8),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // THEME DATA
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final fontName = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontName,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: emerald,
        onPrimary: Colors.white,
        primaryContainer: emeraldContainer,
        onPrimaryContainer: navy,
        secondary: navy,
        onSecondary: Colors.white,
        secondaryContainer: limeContainer,
        onSecondaryContainer: navy,
        tertiary: lime,
        onTertiary: navy,
        error: AppColors.error,
        onError: Colors.white,
        surface: surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: surfaceSecondaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: borderLight,
        outlineVariant: borderLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: borderLight, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMutedLight,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.textSecondaryLight,
        suffixIconColor: AppColors.textSecondaryLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: emerald, width: 2),
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
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSecondaryLight,
        disabledColor: borderLight,
        selectedColor: emerald,
        secondarySelectedColor: emeraldContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pillRadius),
          side: const BorderSide(color: Colors.transparent),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final fontName = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontName,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: emerald,
        onPrimary: navy,
        primaryContainer: navyLighter,
        onPrimaryContainer: Colors.white,
        secondary: lime,
        onSecondary: navy,
        secondaryContainer: navyLight,
        onSecondaryContainer: Colors.white,
        tertiary: lime,
        onTertiary: navy,
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
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE GRADIENT BUTTON WIDGET
// -----------------------------------------------------------------------------
/// A state-of-the-art emerald-to-lime gradient button with smooth
/// touch interactions, soft shadows, and loading state.
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double height;
  final double? width;
  final double borderRadius;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.height = 54,
    this.width = double.infinity,
    this.borderRadius = 16,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final effectiveGradient = isEnabled
        ? (gradient ?? AppTheme.primaryGradient)
        : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500]);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isEnabled ? AppTheme.buttonShadow : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[icon!, const SizedBox(width: 8)],
                        Flexible(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                textStyle ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          trailingIcon!,
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
