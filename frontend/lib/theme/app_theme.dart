import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ── IPL Predictor Design System ──
/// Futuristic dark theme with neon accents, glassmorphism, and glow effects.

class AppColors {
  // ── Core darks ──
  static const Color background = Color(0xFF06060E);
  static const Color surface = Color(0xFF0D0D1A);
  static const Color surfaceLight = Color(0xFF141428);
  static const Color cardBg = Color(0xFF0F0F20);

  // ── Neon accents ──
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonCyan = Color(0xFF00FFE0);
  static const Color neonViolet = Color(0xFF8B5CF6);
  static const Color neonPurple = Color(0xFFBF40FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonOrange = Color(0xFFFF6F00);
  static const Color neonGold = Color(0xFFFFD700);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textMuted = Color(0xFF555577);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonBlue, neonViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF06060E),
      Color(0xFF0A0A20),
      Color(0xFF10103A),
      Color(0xFF06060E),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0x1500D4FF),
      Color(0x088B5CF6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Chart colors (unique per bowler) ──
  static const List<Color> chartPalette = [
    neonBlue,
    neonViolet,
    neonGreen,
    neonPink,
    neonOrange,
    neonCyan,
    neonGold,
    Color(0xFFFF4444),
    Color(0xFF44FF88),
    Color(0xFFFF88FF),
  ];
}

class AppShadows {
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.4}) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity),
        blurRadius: 20,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withOpacity(intensity * 0.5),
        blurRadius: 40,
        spreadRadius: 4,
      ),
    ];
  }

  static List<BoxShadow> subtleGlow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.15),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ];
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.neonBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonBlue,
        secondary: AppColors.neonViolet,
        surface: AppColors.surface,
        error: Color(0xFFFF4466),
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
            color: AppColors.textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.neonBlue,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF4466)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6)),
        floatingLabelStyle: const TextStyle(color: AppColors.neonBlue),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonBlue,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.textMuted.withOpacity(0.15),
        thickness: 1,
      ),
    );
  }
}
