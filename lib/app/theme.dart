import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StratovaColors {
  const StratovaColors._();

  static const bg = Color(0xFFF4F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const glass = Color(0xE6FFFFFF);
  static const accent = Color(0xFF1D4ED8);
  static const accentSoft = Color(0xFFDDE8FF);
  static const accentMuted = Color(0xFF5B84F1);
  static const success = Color(0xFF0E9F6E);
  static const successSoft = Color(0xFFD9F5EA);
  static const warning = Color(0xFFB45309);
  static const warningSoft = Color(0xFFFCE8D5);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFADDDD);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const muted = Color(0xFFF8FAFC);
}

ThemeData buildStratovaTheme() {
  final baseTextTheme = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: StratovaColors.bg,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: StratovaColors.accent,
      primary: StratovaColors.accent,
      surface: StratovaColors.surface,
    ),
    textTheme: baseTextTheme.copyWith(
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: StratovaColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: StratovaColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: StratovaColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: StratovaColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: StratovaColors.textPrimary,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: StratovaColors.textSecondary,
      ),
    ),
    cardColor: StratovaColors.glass,
    dividerColor: StratovaColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: StratovaColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
