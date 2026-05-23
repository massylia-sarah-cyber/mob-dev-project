import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary gradient colors - Modern vibrant purple to cyan
  static const primary = Color(0xFF7C3AED);
  static const primaryDark = Color(0xFF5B21B6);
  static const primaryLight = Color(0xA78BFA);
  static const primaryContainer = Color(0xFFDDD6FE);
  static const onPrimaryFixed = Color(0xFF1A0D4D);
  
  // Accent colors - Enhanced cyan and pink
  static const secondary = Color(0xFF06B6D4);
  static const secondaryDark = Color(0xFF0891B2);
  static const tertiary = Color(0xFFEC4899);
  
  // Background - Deep dark with blue tint
  static const background = Color(0xFF0F172A);
  static const onBackground = Color(0xFFF1F5F9);
  
  // Surface - Slightly lighter with more contrast
  static const surface = Color(0xFF1E293B);
  static const onSurface = Color(0xFFF1F5F9);
  static const surfaceVariant = Color(0xFF334155);
  static const onSurfaceVariant = Color(0xFFCBD5E1);
  
  // Surface containers
  static const surfaceContainerLowest = Color(0xFF0F172A);
  static const surfaceContainerLow = Color(0xFF1E293B);
  static const surfaceContainer = Color(0xFF334155);
  static const surfaceContainerHigh = Color(0xFF475569);
  static const surfaceContainerHighest = Color(0xFF64748B);
  
  // Borders and outlines
  static const outline = Color(0xFF94A3B8);
  static const outlineVariant = Color(0xFF475569);
  static const error = Color(0xFFEF4444);
  
  // Additional accent colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: const Color(0xFF003545),
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.poppins(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        displaySmall: GoogleFonts.poppins(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: GoogleFonts.poppins(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.poppins(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.poppins(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.poppins(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.normal,
          letterSpacing: 1.5,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        color: AppColors.surfaceContainerLow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
