import 'package:flutter/material.dart';

/// Centralized Color Palette for GroundZero
/// Meets WCAG standards and incorporates the core brand colors:
/// Emerald (#10B981), Deep Navy (#0F172A), Vibrant Lime (#A3E635), Slate (#F8FAFC)
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldContainer = Color(0xFFD1FAE5);

  static const Color navy = Color(0xFF0F172A);
  static const Color navyLight = Color(0xFF1E293B);
  static const Color navyLighter = Color(0xFF334155);

  static const Color lime = Color(0xFFA3E635);
  static const Color limeDark = Color(0xFF84CC16);
  static const Color limeContainer = Color(0xFFECFCCB);

  // Backgrounds & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondaryLight = Color(0xFFF1F5F9);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderLightFocus = Color(0xFF10B981);

  // Backgrounds & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceSecondaryDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderDarkFocus = Color(0xFF10B981);

  // Typography / Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient limeEmeraldGradient = LinearGradient(
    colors: [Color(0xFFA3E635), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
