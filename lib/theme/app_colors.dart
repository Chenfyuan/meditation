import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFB8865F);
  static const Color primaryLight = Color(0xFFE0BD97);
  static const Color primaryDark = Color(0xFFC49A72);
  static const Color background = Color(0xFFEFE8DE);
  static const Color backgroundLight = Color(0xFFFAF6EF);
  static const Color cardBackground = Color(0xFFF3ECE2);
  static const Color dark = Color(0xFF3A3127);
  static const Color textPrimary = Color(0xFF3A3127);
  static const Color textSecondary = Color(0xFF8B8173);
  static const Color textTertiary = Color(0xFFA89E8F);
  static const Color textMuted = Color(0xFFB1A797);
  static const Color accentGreen = Color(0xFF94A07A);
  static const Color accentGreenLight = Color(0xFFC1C4A2);
  static const Color accentRose = Color(0xFFD8AA98);
  static const Color accentRoseDark = Color(0xFFB67F6B);
  static const Color white = Color(0xFFF3ECE2);

  // Dark mode colors (player/sleep screens)
  static const Color darkBg = Color(0xFF33271F);
  static const Color darkBgDeep = Color(0xFF241B15);
  static const Color darkBgSleep = Color(0xFF1B1512);
  static const Color sleepAccent = Color(0xFFDCAE9E);

  static List<Color> meditationGradientFor(String themeKey) {
    switch (themeKey) {
      case 'rose':
        return const [accentRose, accentRoseDark];
      case 'sage':
        return const [accentGreenLight, accentGreen];
      case 'bronze':
        return const [primaryLight, primary];
      case 'twilight':
        return const [Color(0xFFB89A8A), accentGreen];
      case 'sand':
      default:
        return const [primaryLight, primaryDark];
    }
  }

  static Color accentForTheme(String themeKey) {
    switch (themeKey) {
      case 'rose':
        return accentRose;
      case 'sage':
        return accentGreen;
      case 'bronze':
        return primary;
      case 'sand':
        return primaryDark;
      default:
        return textMuted;
    }
  }

  static List<Color> sleepGradientFor(String themeKey) {
    switch (themeKey) {
      case 'moss':
        return const [Color(0xFF7A8A6A), Color(0xFF4D5A40)];
      case 'ocean':
        return const [Color(0xFF7A92A0), Color(0xFF4A5D68)];
      case 'fire':
        return const [Color(0xFFC08D62), Color(0xFF8A5E3E)];
      case 'violet':
        return const [Color(0xFF6A5E7A), Color(0xFF3E3550)];
      case 'stone':
        return const [Color(0xFF8A8278), Color(0xFF56504A)];
      case 'cocoa':
      default:
        return const [Color(0xFF6A5444), Color(0xFF3C2D24)];
    }
  }
}
