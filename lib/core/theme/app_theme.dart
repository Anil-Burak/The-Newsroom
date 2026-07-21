import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary ink palette
  static const Color inkBlack = Color(0xFF0D0D0D);
  static const Color inkDeep = Color(0xFF1A1A2E);
  static const Color inkMid = Color(0xFF16213E);
  static const Color inkSurface = Color(0xFF1F2B47);

  // Accent - Press-gold
  static const Color gold = Color(0xFFD4A853);
  static const Color goldLight = Color(0xFFEEC97D);
  static const Color goldDark = Color(0xFFB8860B);

  // Semantic
  static const Color publishGreen = Color(0xFF2ECC71);
  static const Color rejectRed = Color(0xFFE74C3C);
  static const Color neutral = Color(0xFF95A5A6);

  // Text
  static const Color textPrimary = Color(0xFFF0EAD6); // Aged newsprint
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color textMuted = Color(0xFF757575);

  // Glassmorphism surface
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradients
  static const LinearGradient inkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [inkDeep, inkMid, Color(0xFF0F3460)],
  );
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold, goldLight],
  );
}

// ─── Typography ──────────────────────────────────────────────────────────────
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.unna(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.unna(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textPrimary,
        ),
      );
}

// ─── Main Theme ──────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.inkDeep,
        colorScheme: ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.goldLight,
          surface: AppColors.inkSurface,
          error: AppColors.rejectRed,
        ),
        textTheme: AppTypography.textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.inkSurface,
          elevation: 8,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.inkBlack,
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.glassBorder),
      );
}
