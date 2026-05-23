import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary gradient colors - black and green theme
  static const primary = Color(0xFF00E676);
  static const primaryDark = Color(0xFF00B248);
  static const primaryLight = Color(0xFF66FFA6);
  static const primaryContainer = Color(0xFF001A0D);
  static const onPrimaryFixed = Color(0xFF000000);
  
  // Accent colors - green/teal
  static const secondary = Color(0xFF1DE9B6);
  static const secondaryDark = Color(0xFF00BFA5);
  static const tertiary = Color(0xFF76FF03);
  
  // Background - pure black
  static const background = Color(0xFF000000);
  static const onBackground = Color(0xFFFFFFFF);
  
  // Surface - darker with green accent
  static const surface = Color(0xFF050A07);
  static const onSurface = Color(0xFFE8FFEA);
  static const surfaceVariant = Color(0xFF0A1F14);
  static const onSurfaceVariant = Color(0xFF9AE6B4);
  
  // Surface containers - all very dark with minimal variation
  static const surfaceContainerLowest = Color(0xFF000000);
  static const surfaceContainerLow = Color(0xFF050A07);
  static const surfaceContainer = Color(0xFF0A1410);
  static const surfaceContainerHigh = Color(0xFF0F1F18);
  static const surfaceContainerHighest = Color(0xFF1A3028);
  
  // Borders and outlines
  static const outline = Color(0xFF58D68D);
  static const outlineVariant = Color(0xFF051108);
  static const error = Color(0xFFEF4444);
  
  // Additional accent colors
  static const success = Color(0xFF22C55E);
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
