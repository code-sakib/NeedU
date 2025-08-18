import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF00FF88);
  static const secondary = Color(0xFFFF6B35);
  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1E1E1E);
  static const border = Color(0xFF333333);
  static const text = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFCCCCCC);
  static const textMuted = Color(0xFF888888);

  // Icon colors from the UI
  // static const iconPrimary = Color(0xFF00CC6A); // Green (active/selected)
  static const iconSecondary = Color(0xFF000000); // Black (inactive)
  static const iconMuted = Color(0xFFB0B0B0); // Grey (disabled/muted)
}

class AppTypography {
  static TextTheme textTheme() {
    return const TextTheme(
      // Large Title
      titleLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      // Subtitle
      titleSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      // Medium Title
      titleMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      // Label - Body text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
        height: 1.5,
      ),
      // Sub-label - Small text
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: Color(0xFF00CC6A),
        surface: AppColors.surface,

        background: AppColors.background,
      ),

      textTheme: AppTypography.textTheme(),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        elevation: 0,
      ),

      iconTheme: IconThemeData(
        color: AppColors.primary,
        size: 24,
        weight: 300, // Makes icon strokes thinner
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
    );
  }
}
