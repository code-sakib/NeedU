import 'package:flutter/material.dart';
import 'package:needu/utilis/size_config.dart';

class AppColors {
  static const primary = Color(0xFF00FF88);
  static const secondary = Color(0xFF00CC6A);
  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1E1E1E);
  static const border = Color(0xFF333333);
  static const text = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFCCCCCC);
  static const textErr = Color(0xFFC56363);
  static const textMuted = Color(0xFF888888);

  // Icon colors from the UI
  // static const iconPrimary = Color(0xFF00CC6A); // Green (active/selected)
  static const iconSecondary = Color(0xFF000000); // Black (inactive)
  static const iconMuted = Color(0xFFB0B0B0); // Grey (disabled/muted)
}

class AppTypography {
  static TextTheme textTheme() {
    return TextTheme(
      // Large Title
      titleLarge: TextStyle(
        fontSize: SizeConfig.blockWidth * 8,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      // Medium Title
      titleMedium: TextStyle(
        fontSize: SizeConfig.blockWidth * 4,
        fontWeight: FontWeight.w300,
        color: AppColors.text,
      ),
      // Subtitle
      titleSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
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
        error: Colors.red
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

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.text,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
