import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary surface palette (Light / Newspaper)
  static const Color inkBlack = Color(0xFF1A1A1A);
  static const Color inkDeep = Color(0xFFF9F9F9);      // Kırık Beyaz arka plan
  static const Color inkMid = Color(0xFFF0F0F0);       // Açık Gri arka plan
  static const Color inkSurface = Color(0xFFFFFFFF);    // Kart arka planı — Tam Beyaz

  // Accent - Bayrak Kırmızısı
  static const Color gold = Color(0xFFCC0000);          // Bayrak Kırmızısı (primary)
  static const Color goldLight = Color(0xFFE53935);     // Açık Kırmızı
  static const Color goldDark = Color(0xFF8B0000);      // Bordo

  // Semantic
  static const Color publishGreen = Color(0xFF2ECC71);
  static const Color rejectRed = Color(0xFFE74C3C);
  static const Color neutral = Color(0xFF95A5A6);

  // Text (Koyu temelden açık arka plana uyumlu)
  static const Color textPrimary = Color(0xFF1A1A1A);   // Koyu Füme
  static const Color textSecondary = Color(0xFF555555);  // Orta Gri
  static const Color textMuted = Color(0xFF999999);      // Açık Gri

  // Surface tints (glassmorphism yerine solid açık yüzeyler)
  static const Color glassSurface = Color(0xFFF5F5F5);  // Açık Gri Yüzey
  static const Color glassBorder = Color(0xFFE0E0E0);   // İnce Gri Kenarlık

  // Gradients
  static const LinearGradient inkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9F9F9), Color(0xFFF0F0F0)],
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
          fontSize: 24,
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
          fontSize: 15,
          color: AppColors.textSecondary,
          height: 1.45,
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.inkDeep,
        colorScheme: ColorScheme.light(
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
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.glassBorder, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.glassBorder),
      );
}
