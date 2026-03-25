import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Shared Colors
  static const Color primary = Color(0xFFC7A56E); // Gold/Beige accent
  static const Color onPrimary = Colors.black;
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0F2218);
  static const Color darkSurface = Color(0xFF162D1F);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF9EABA2);
  static const Color darkDivider = Color(0xFF233A2C);
  static const Color darkInputBg = Color(0xFF162D1F);
  static const Color darkCardBg = Color(0xFF1E3528);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8F9F8);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF66706B);
  static const Color lightDivider = Color(0xFFE0E5E2);
  static const Color lightInputBg = Colors.white;
  static const Color lightCardBg = Colors.white;

  // Legacy/Deprecated (Mapping to Dark for compatibility during transition)
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color divider = darkDivider;
  static const Color inputBg = darkInputBg;
  static const Color cardBg = darkCardBg;
  static const Color bottomNavBg = darkBackground;
}

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
}
