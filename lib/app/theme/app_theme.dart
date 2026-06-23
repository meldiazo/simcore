import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimcoreColors {
  const SimcoreColors._();

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

ThemeData buildSimcoreTheme() {
  final baseTextTheme = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: SimcoreColors.bg,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: SimcoreColors.accent,
      primary: SimcoreColors.accent,
      surface: SimcoreColors.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SimcoreColors.muted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(
        fontSize: 14,
        color: SimcoreColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 14,
        color: SimcoreColors.accent,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: SimcoreColors.textTertiary,
      ),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return SimcoreColors.accent;
        }
        return SimcoreColors.textTertiary;
      }),
      suffixIconColor: SimcoreColors.textTertiary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SimcoreColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SimcoreColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SimcoreColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SimcoreColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SimcoreColors.danger, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SimcoreColors.border),
      ),
    ),
    textTheme: baseTextTheme.copyWith(
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: SimcoreColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: SimcoreColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: SimcoreColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: SimcoreColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: SimcoreColors.textPrimary,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: SimcoreColors.textSecondary,
      ),
    ),
    cardColor: SimcoreColors.glass,
    dividerColor: SimcoreColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: SimcoreColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
