import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const _serifFamily = 'NotoSerifSC';
  static const _sansFamily = 'sans-serif';

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: _sansFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: _serifFamily,
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: _serifFamily,
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: _serifFamily,
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: _serifFamily,
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w300,
          color: AppColors.textSecondary,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        bodySmall: TextStyle(fontSize: 13, color: AppColors.textTertiary),
        labelMedium: TextStyle(
          fontSize: 12,
          letterSpacing: 2,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
